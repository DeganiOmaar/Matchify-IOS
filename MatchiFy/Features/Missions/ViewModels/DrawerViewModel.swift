import Foundation
import Combine
import SwiftUI

/// ViewModel pour le Drawer (menu latéral)
final class DrawerViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager: AuthManager
    
    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
        
        // Charger l'utilisateur depuis AuthManager
        self.user = authManager.user
        
        // Observer les changements de l'utilisateur
        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
    
    /// Nom complet de l'utilisateur
    var fullName: String {
        user?.fullName ?? "Utilisateur"
    }
    
    /// Talent de l'utilisateur (si existe)
    var talent: String? {
        guard let talents = user?.talent,
              !talents.isEmpty else {
            return nil
        }
        // Retourner le premier talent ou une chaîne formatée
        return talents.first
    }
    
    /// URL de l'image de profil
    var profileImageURL: URL? {
        user?.profileImageURL
    }
    
    /// Indique si l'utilisateur a une image de profil
    var hasProfileImage: Bool {
        guard let profileImage = user?.profileImage,
              !profileImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
}

