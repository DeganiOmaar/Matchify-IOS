import Foundation
import UIKit
import Combine

final class EditRecruiterProfileViewModel: ObservableObject {

    // Champs visibles dans la vue
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var location: String = ""
    @Published var description: String = ""
    @Published var selectedImage: UIImage? = nil

    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var saveSuccess: Bool = false

    private let service: RecruiterProfileService

    init(service: RecruiterProfileService = .shared) {
        self.service = service

        // Pré-remplissage depuis l'utilisateur stocké
        if let user = AuthManager.shared.user {
            self.name = user.fullName
            self.email = user.email
            self.phone = user.phone ?? ""
            self.location = user.location ?? ""
            self.description = user.description ?? ""
        }
    }

    // MARK: - Update profile
    func updateProfile() {
        errorMessage = nil
        isSaving = true

        Task { @MainActor in
            do {
                let response = try await service.updateRecruiterProfile(
                    fullName: name,
                    email: email,
                    phone: phone,
                    location: location,
                    profileImage: selectedImage,
                    description: description
                )

                // Mise à jour locale dans AuthManager
                AuthManager.shared.persistUpdatedUser(response.user)

                isSaving = false
                saveSuccess = true

            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
