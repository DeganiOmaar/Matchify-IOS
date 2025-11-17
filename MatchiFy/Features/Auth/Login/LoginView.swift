import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var rememberMe: Bool = false
    @State private var goToForgotPassword = false
    @State private var goToChooseRole = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // MARK: - Logo
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .padding(.top, 40)

                    // MARK: - App Phrase
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Connecting Talent With Opportunity")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Please sign in to continue")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    // MARK: - Email Field
                    textFieldWithIcon(
                        icon: "envelope",
                        placeholder: "Email",
                        text: $viewModel.email
                    )

                    // MARK: - Password Field
                    passwordField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        show: $viewModel.showPassword
                    )

                    // MARK: - Error Message
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal, 24)
                    }

                    // MARK: - Remember Me + Reset Password
                    HStack {
                        Button {
                            rememberMe.toggle()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? .blue : .gray)

                                Text("Remember Me")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }

                        Spacer()

                        Button {
                            goToForgotPassword = true
                        } label: {
                            Text("Reset Password")
                                .foregroundColor(.blue)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Login Button
                    Button {
                        viewModel.login(rememberMe: rememberMe) { response in
                            if response != nil {
                                // Navigation handled by AppEntryView based on role
                                // No need to navigate manually
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.blue.opacity(0.5))
                                .cornerRadius(30)
                        } else {
                            Text("Login")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(viewModel.isLoginButtonDisabled ? Color.blue.opacity(0.4) : Color.blue)
                                .cornerRadius(30)
                        }
                    }
                    .disabled(viewModel.isLoginButtonDisabled || viewModel.isLoading)
                    .padding(.horizontal, 24)

                    // MARK: - Sign Up Footer
                    HStack(spacing: 5) {
                        Text("Don’t have an account?")
                            .foregroundColor(.gray)

                        Button {
                            goToChooseRole = true
                        } label: {
                            Text("Sign Up")
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.top, -5)

                    Spacer(minLength: 20)
                }
            }
            .navigationDestination(isPresented: $goToForgotPassword) {
                ForgotPasswordView()
            }
            .navigationDestination(isPresented: $goToChooseRole) {
                ChooseRoleView()
            }
            .navigationBarHidden(true)
            .onChange(of: AuthManager.shared.isLoggedIn) { oldValue, newValue in
                // When login succeeds, AppEntryView will automatically show MainTabView
                // No manual navigation needed
            }
        }
    }

    // MARK: - TextField With Icon
    private func textFieldWithIcon(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .font(.system(size: 18))

            TextField("", text: text, prompt:
                Text(placeholder)
                    .foregroundColor(.black.opacity(0.7))
                    .font(.system(size: 14))
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.none)
            .autocorrectionDisabled()
            .submitLabel(.next)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 35)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Password Field
    private func passwordField(placeholder: String, text: Binding<String>, show: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .foregroundColor(.gray)
                .font(.system(size: 18))

            Group {
                if show.wrappedValue {
                    TextField("", text: text, prompt:
                        Text(placeholder)
                            .foregroundColor(.black.opacity(0.7))
                            .font(.system(size: 14))
                    )
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                } else {
                    SecureField("", text: text, prompt:
                        Text(placeholder)
                            .foregroundColor(.black.opacity(0.7))
                            .font(.system(size: 14))
                    )
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                }
            }

            Button {
                show.wrappedValue.toggle()
            } label: {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 35)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    LoginView()
}
