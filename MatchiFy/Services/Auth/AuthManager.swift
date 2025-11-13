import Foundation
import Security
import Combine

final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    private init() {}

    @Published var token: String? = nil
    @Published var user: UserModel? = nil
    @Published var isLoggedIn: Bool = false
    @Published var role: String? = nil   // talent or recruiter

    // MARK: - Keychain config
    private let keychainService = "com.matchify.app"
    private let tokenAccount = "auth_token"

    // MARK: - Keychain helpers
    private func keychainSaveToken(_ token: String) {
        let tokenData = Data(token.utf8)

        // Delete any existing item first
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

    private func keychainDeleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: tokenAccount
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Save login session (with rememberMe)
    func saveLoginSession(from response: LoginResponse, rememberMe: Bool) {
        // Always set in-memory state
        token = response.token
        user = response.user
        role = response.role
        isLoggedIn = true

        if rememberMe {
            // Persist to Keychain + UserDefaults
            keychainSaveToken(response.token)

            if let encoded = try? JSONEncoder().encode(response.user) {
                UserDefaults.standard.set(encoded, forKey: "current_user")
            }
        } else {
            // Do NOT persist anything for this session
            keychainDeleteToken()
            UserDefaults.standard.removeObject(forKey: "current_user")
        }
    }

    // MARK: - Restore session on app launch
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

        // Logged in only if we have both token & user persisted
        isLoggedIn = (token != nil && user != nil)
    }

    // MARK: - Logout
    func logout() {
        token = nil
        user = nil
        role = nil
        isLoggedIn = false

        keychainDeleteToken()
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}
