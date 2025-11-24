import Foundation
import Security
import Combine

final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {}

    // MARK: - Published properties
    @Published var token: String? = nil
    @Published var user: UserModel? = nil
    @Published var isLoggedIn: Bool = false
    @Published var role: String? = nil   // talent or recruiter

    // MARK: - Keychain config
    private let keychainService = "com.matchify.app"
    private let tokenAccount = "auth_token"

    // MARK: - Keychain Save
    private func keychainSaveToken(_ token: String) {
        let tokenData = Data(token.utf8)

        // Delete any existing token
        keychainDeleteToken()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenAccount,
            kSecValueData as String: tokenData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    // MARK: - Keychain Load
    private func keychainLoadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    // MARK: - Keychain Delete
    private func keychainDeleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenAccount
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Save Login Session
    @MainActor
    func saveLoginSession(from response: LoginResponse, rememberMe: Bool) {
        // In-memory
        token = response.token
        user = response.user
        role = response.role
        isLoggedIn = true

        if rememberMe {
            // Persist token -> Keychain
            keychainSaveToken(response.token)

            // Persist user -> UserDefaults
            if let encoded = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(encoded, forKey: "current_user")
            }
        } else {
            // Delete any stored session
            keychainDeleteToken()
            UserDefaults.standard.removeObject(forKey: "current_user")
        }
    }

    // MARK: - Save Signup Session (for Talent and Recruiter signup)
    @MainActor
    func saveSignupSession(token: String, user: UserModel, rememberMe: Bool) {
        // In-memory
        self.token = token
        self.user = user
        self.role = user.role  // Extract role from user
        self.isLoggedIn = true

        if rememberMe {
            // Persist token -> Keychain
            keychainSaveToken(token)

            // Persist user -> UserDefaults
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "current_user")
            }
        } else {
            // Delete any stored session
            keychainDeleteToken()
            UserDefaults.standard.removeObject(forKey: "current_user")
        }
    }

    // MARK: - Restore Session (on app launch)
    func restoreSession() {
        let storedToken = keychainLoadToken()
        token = storedToken

        if let data = UserDefaults.standard.data(forKey: "current_user"),
           let storedUser = try? JSONDecoder().decode(UserModel.self, from: data) {
            user = storedUser
            role = storedUser.role
        } else {
            user = nil
            role = nil
        }

        // User is logged in only if both token + user exist
        isLoggedIn = (token != nil && user != nil)
    }

    // MARK: - Logout
    @MainActor
    func logout() async {
        // 1. Call backend logout endpoint
        do {
            _ = try await AuthService.shared.logout()
        } catch {
            // Log but don't fail logout if backend call fails
            // The local cleanup is more important
            print("⚠️ Backend logout failed: \(error.localizedDescription)")
        }
        
        // 2. Clear in-memory state
        token = nil
        user = nil
        role = nil
        isLoggedIn = false

        // 3. Clear persisted auth data
        keychainDeleteToken()
        UserDefaults.standard.removeObject(forKey: "current_user")
        
        // IMPORTANT: Do NOT reset hasSeenOnboarding
        // This ensures user goes to Login screen after logout, not onboarding
    }
}

// MARK: - Update user after profile changes
extension AuthManager {
    func persistUpdatedUser(_ user: UserModel) {
        self.user = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "current_user")
        }
    }
}
