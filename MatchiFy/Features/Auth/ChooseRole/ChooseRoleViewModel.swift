import SwiftUI
import Combine

enum UserRole: String {
    case talent = "talent"
    case recruiter = "recruiter"
}

final class ChooseRoleViewModel: ObservableObject {

    @Published var selectedRole: UserRole? = nil
    @Published var goNext = false

    func selectRole(_ role: UserRole) {
        selectedRole = role
    }

    @ViewBuilder
    var nextScreen: some View {
        switch selectedRole {
        case .talent:
            TalentSignupView()
        case .recruiter:
            RecruiterSignupView()
        case .none:
            EmptyView()
        }
    }

    func continueAction() {
        guard selectedRole != nil else { return }
        goNext = true
    }
}
