import SwiftUI

struct ChooseRoleView: View {
    @StateObject private var viewModel = ChooseRoleViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {

            // MARK: - Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Your Role")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)

                Text("Select the account type that suits you best.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }

            // MARK: - Talent Option
            roleCard(
                icon: "person.crop.circle",
                title: "Talent",
                subtitle: "For creators, artists, influencers, freelancers.",
                isSelected: viewModel.selectedRole == .talent
            ) {
                viewModel.selectRole(.talent)
            }

            // MARK: - Recruiter Option
            roleCard(
                icon: "briefcase",
                title: "Recruiter",
                subtitle: "For companies or individuals hiring talent.",
                isSelected: viewModel.selectedRole == .recruiter
            ) {
                viewModel.selectRole(.recruiter)
            }

            Spacer()

            // MARK: - Continue Button (same design)
            Button {
                viewModel.continueAction()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        viewModel.selectedRole == nil
                        ? Color.blue.opacity(0.3)
                        : Color.blue
                    )
                    .cornerRadius(30)
            }
            .disabled(viewModel.selectedRole == nil)
            .padding(.bottom, 25)
        }
        .padding(.horizontal, 24)

        // MARK: - Navigation
        .navigationDestination(isPresented: $viewModel.goNext) {
            viewModel.nextScreen
        }
    }

    // MARK: - Custom Role Card (unchanged)
    private func roleCard(icon: String, title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {

                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.blue)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
    }
}

#Preview {
    NavigationStack {
        ChooseRoleView()
    }
}
