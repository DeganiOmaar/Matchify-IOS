import Foundation
import UIKit
import Combine

final class EditTalentProfileViewModel: ObservableObject {

    // Champs visibles dans la vue
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var location: String = ""
    @Published var talent: String = ""
    @Published var description: String = ""
    @Published var portfolioLink: String = ""
    @Published var skillInput: String = ""
    @Published var skills: [String] = []
    @Published var selectedImage: UIImage? = nil

    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false

    private let service: TalentProfileService

    init(service: TalentProfileService = .shared) {
        self.service = service

        // Pré-remplissage depuis l'utilisateur stocké
        if let user = AuthManager.shared.user {
            self.name = user.fullName
            self.email = user.email
            self.phone = user.phone ?? ""
            self.location = user.location ?? ""
            self.talent = user.talent ?? ""
            self.description = user.description ?? ""
            self.portfolioLink = user.portfolioLink ?? ""
            self.skills = user.skills ?? []
        }
    }
    
    // MARK: - Skills Management
    func addSkill() {
        let trimmed = skillInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, skills.count < 10 else { return }
        
        if !skills.contains(trimmed) {
            skills.append(trimmed)
            skillInput = ""
        }
    }
    
    func removeSkill(_ skill: String) {
        skills.removeAll { $0 == skill }
    }

    // MARK: - Update profile
    func updateProfile() {
        errorMessage = nil
        
        // Validation
        if name.isEmpty || email.isEmpty {
            errorMessage = "Le nom et l'email sont requis."
            return
        }
        
        if skills.count > 10 {
            errorMessage = "Vous ne pouvez pas avoir plus de 10 compétences."
            return
        }
        
        if !portfolioLink.isEmpty {
            guard URL(string: portfolioLink) != nil else {
                errorMessage = "Veuillez fournir une URL de portfolio valide."
                return
            }
        }
        
        isSaving = true

        Task { @MainActor in
            do {
                let response = try await service.updateTalentProfile(
                    fullName: name,
                    email: email,
                    phone: phone.isEmpty ? nil : phone,
                    location: location.isEmpty ? nil : location,
                    talent: talent.isEmpty ? nil : talent,
                    skills: skills.isEmpty ? nil : skills,
                    description: description.isEmpty ? nil : description,
                    portfolioLink: portfolioLink.isEmpty ? nil : portfolioLink,
                    profileImage: selectedImage
                )

                // Mise à jour locale dans AuthManager
                AuthManager.shared.persistUpdatedUser(response.user)

                isSaving = false
                saveSuccess = true

            } catch {
                isSaving = false
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .profileUpdate)
            }
        }
    }
}

