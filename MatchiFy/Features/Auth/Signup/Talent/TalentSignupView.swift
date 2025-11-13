import SwiftUI

struct TalentSignupView: View {
    @StateObject private var viewModel = TalentSignupViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sign Up Talent")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    Text("Create your talent profile")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                
                // MARK: - Form fields
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
                    
                    textFieldWithIcon(
                        icon: "phone",
                        placeholder: "Phone Number",
                        text: $viewModel.phone
                    )
                    
                    textFieldWithIcon(
                        icon: "mappin.and.ellipse",
                        placeholder: "Location",
                        text: $viewModel.location
                    )
                    
                    textFieldWithIcon(
                        icon: "star",
                        placeholder: "Talent (e.g. Photographer, Singer…)",
                        text: $viewModel.talent
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
                if let error = viewModel.errorMessage {
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
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(30)
                    } else {
                        Text("Sign Up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(viewModel.isSignUpDisabled ? Color.blue.opacity(0.4) : Color.blue)
                            .cornerRadius(30)
                    }
                }
                .disabled(viewModel.isSignUpDisabled || viewModel.isLoading)
                
                
                // MARK: - Already have an account?
                HStack(alignment: .center ,spacing: 5) {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink("Login") {
                        LoginView()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -10)
                
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .navigationDestination(isPresented: $viewModel.goToHome) {
            HomeView()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    // MARK: - TextField
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
            .autocapitalization(.none)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 35)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        )
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
                } else {
                    SecureField("", text: text, prompt:
                                    Text(placeholder)
                                        .foregroundColor(.black.opacity(0.7))
                                        .font(.system(size: 14))
                    )
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
    }
}

#Preview {
    NavigationStack {
        TalentSignupView()
    }
}
