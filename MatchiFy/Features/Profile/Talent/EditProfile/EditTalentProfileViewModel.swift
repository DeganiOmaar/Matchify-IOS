import Foundation
import UIKit
import Combine

final class EditTalentProfileViewModel: ObservableObject {

    // Champs visibles dans la vue
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var location: String = ""
    @Published var talentInput: String = ""
    @Published var talents: [String] = []
    @Published var description: String = ""
    @Published var selectedSkills: [SkillModel] = []
    @Published var selectedImage: UIImage? = nil

    @Published var isSaving: Bool = false
    @Published var isLoadingSkills: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false

    private let service: TalentProfileService
    private let skillService = SkillSuggestionService.shared

    init(service: TalentProfileService = .shared) {
        self.service = service

        // Pré-remplissage depuis l'utilisateur stocké
        if let user = AuthManager.shared.user {
            self.name = user.fullName
            self.email = user.email
            self.phone = user.phone ?? ""
            self.location = user.location ?? ""
            self.talents = user.talent ?? []
            self.description = user.description ?? ""
            
            // Load skills by IDs - user.skills contains skill IDs
            if let skillIds = user.skills, !skillIds.isEmpty {
                loadSkillsByIds(skillIds)
            }
        }
    }
    
    private func loadSkillsByIds(_ ids: [String]) {
        isLoadingSkills = true
        Task {
            do {
                let skills = try await skillService.getSkillsByIds(ids)
                await MainActor.run {
                    selectedSkills = skills
                    isLoadingSkills = false
                }
            } catch {
                await MainActor.run {
                    isLoadingSkills = false
                    print("❌ Error loading skills: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Talents Management
    func addTalent() {
        let trimmed = talentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if !talents.contains(trimmed) {
            talents.append(trimmed)
            talentInput = ""
        }
    }
    
    func removeTalent(_ talent: String) {
        talents.removeAll { $0 == talent }
    }
    
    // MARK: - Skills Management
    var skillNames: [String] {
        selectedSkills.map { $0.name }
    }
    
    var skillIds: [String] {
        selectedSkills.compactMap { skill in
            skill._id ?? skill.id ?? nil
        }
    }

    // MARK: - Update profile
    func updateProfile() {
        errorMessage = nil
        
        // Validation
        if name.isEmpty || email.isEmpty {
            errorMessage = "Le nom et l'email sont requis."
            return
        }
        
        isSaving = true

        Task { @MainActor in
            do {
                // Send skill names (backend will find or create them and convert to IDs)
                let response = try await service.updateTalentProfile(
                    fullName: name,
                    email: email,
                    phone: phone.isEmpty ? nil : phone,
                    location: location.isEmpty ? nil : location,
                    talent: talents.isEmpty ? nil : talents,
                    skills: skillNames.isEmpty ? nil : skillNames,
                    description: description.isEmpty ? nil : description,
                    profileImage: selectedImage
                )

                // Mise à jour locale dans AuthManager
                AuthManager.shared.persistUpdatedUser(response.user)

                isSaving = false
                saveSuccess = true

            } catch {
                isSaving = false
                // Log l'erreur détaillée pour le débogage
                print("❌ Erreur lors de la mise à jour du profil: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("   Code d'erreur: \(nsError.code)")
                    print("   Domaine: \(nsError.domain)")
                    if let userInfo = nsError.userInfo as? [String: Any] {
                        print("   Détails: \(userInfo)")
                    }
                }
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .profileUpdate)
            }
        }
    }
}

