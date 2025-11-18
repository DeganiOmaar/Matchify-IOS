import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Title
                    Text("Create new password")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    // MARK: - Subtitle
                    Text("Create your new password. If you forget it, then you have to do forgot password")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.trailing, 20)
                    
                    
                    // MARK: - New Password Label
                    Text("New Password")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, 16)
                    
                    // MARK: - New Password Field
                    passwordField(
                        placeholder: "New Password",
                        text: $viewModel.newPassword,
                        show: $viewModel.showNewPassword
                    )
                    
                    
                    // MARK: - Confirm Password Label
                    Text("Confirm New Password")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.top, 16)
                    
                    // MARK: - Confirm Password Field
                    passwordField(
                        placeholder: "Confirm password",
                        text: $viewModel.confirmPassword,
                        show: $viewModel.showConfirmPassword
                    )
                    
                    
                    // MARK: - Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // MARK: - Continue Button
                    Button {
                        viewModel.resetPassword()
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .foregroundColor(AppTheme.Colors.buttonText)
                        .frame(height: 55)
                        .background(viewModel.isButtonDisabled ? AppTheme.Colors.primary.opacity(0.4) : AppTheme.Colors.primary)
                        .cornerRadius(30)
                    }
                    .disabled(viewModel.isButtonDisabled || viewModel.isLoading)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $viewModel.goToLogin) {
                LoginView()   // ✅ redirect to login when done
            }
        }
    }
    
    // MARK: - Reusable password field with pill style
    private func passwordField(
        placeholder: String,
        text: Binding<String>,
        show: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .foregroundColor(AppTheme.Colors.iconSecondary)
                .font(.system(size: 18))
            
            Group {
                if show.wrappedValue {
                    TextField("", text: text, prompt:
                                Text(placeholder)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .font(.system(size: 14))
                    )
                } else {
                    SecureField("", text: text, prompt:
                                    Text(placeholder)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .font(.system(size: 14))
                    )
                }
            }
            
            Button {
                show.wrappedValue.toggle()
            } label: {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(AppTheme.Colors.iconSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 35)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView()
    }
}
