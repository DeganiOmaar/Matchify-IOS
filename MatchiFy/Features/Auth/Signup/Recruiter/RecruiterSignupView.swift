import SwiftUI

struct RecruiterSignupView: View {
    @StateObject private var viewModel = RecruiterSignupViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sign Up Recruiter")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    Text("Create your recruiter profile")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                
                // MARK: - Input Fields
                VStack(spacing: 20) {
                    
                    textFieldWithIcon(
                        icon: "person",
                        placeholder: "Full Name",
                        text: $viewModel.fullName
                    )
                    
                    textFieldWithIcon(
                        icon: "envelope",
                        placeholder: "Email",
                        text: $viewModel.email
                    )
                    
                    passwordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        show: $viewModel.showPassword
                    )
                    
                    passwordField(
                        placeholder: "Confirm Password",
                        text: $viewModel.confirmPassword,
                        show: $viewModel.showConfirmPassword
                    )
                }
                
                
                // MARK: - ERROR MESSAGE
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                }
                
                
                // MARK: - Sign Up Button
                Button {
                    viewModel.signUp()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(AppTheme.Colors.primary.opacity(0.5))
                            .cornerRadius(30)
                    } else {
                        Text("Sign Up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(viewModel.isSignUpDisabled ? AppTheme.Colors.primary.opacity(0.4) : AppTheme.Colors.primary)
                            .cornerRadius(30)
                    }
                }
                .disabled(viewModel.isSignUpDisabled || viewModel.isLoading)
                
                
                // MARK: - Already have account?
                HStack(alignment: .center ,spacing: 5) {
                    Text("Already have an account?")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    NavigationLink("Login") {
                        LoginView()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -10)
                
                
                Spacer().frame(height: 40)
                
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: AuthManager.shared.isLoggedIn) { oldValue, newValue in
            // When signup succeeds, AppEntryView will automatically show MainTabView
            // No manual navigation needed
        }
    }
    
    
    // MARK: - TextField With Icon
    private func textFieldWithIcon(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.iconSecondary)
                .font(.system(size: 18))
            
            TextField("", text: text, prompt:
                        Text(placeholder)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .font(.system(size: 14))
            )
            .autocapitalization(.none)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 35)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
    
    
    // MARK: - Password Field
    private func passwordField(placeholder: String, text: Binding<String>, show: Binding<Bool>) -> some View {
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
        RecruiterSignupView()
    }
}
