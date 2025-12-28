import Foundation
import LocalAuthentication

enum BiometricError: Error, LocalizedError {
    case notAvailable
    case failed
    case canceled
    
    var errorDescription: String? {
        switch self {
        case .notAvailable: return "Biometric authentication is not available on this device."
        case .failed: return "Biometric authentication failed."
        case .canceled: return "Biometric authentication was canceled."
        }
    }
}

class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private init() {}
    
    func authenticate() async throws {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.notAvailable
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Confirm your identity to approve payment"
            )
            
            if !success {
                throw BiometricError.failed
            }
        } catch {
            if let laError = error as? LAError {
                switch laError.code {
                case .userCancel, .appCancel, .systemCancel:
                    throw BiometricError.canceled
                default:
                    throw BiometricError.failed
                }
            } else {
                throw BiometricError.failed
            }
        }
    }
}
