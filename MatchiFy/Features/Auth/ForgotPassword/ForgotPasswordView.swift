import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Header Title
                Text("Reset your password")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                // MARK: - Subtitle
                Text("Please enter your email and we will send an OTP code in the next step to reset your password")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
                
                // MARK: - Email Label
                Text("Email Address")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                // MARK: - Email TextField
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                    
                    TextField("", text: $viewModel.email, prompt:
                        Text("Enter your email")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.system(size: 14))
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                )
                
                
                // MARK: - Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                        .padding(.top, -10)
                }
                
                Spacer()
                
                // MARK: - Continue Button
                Button {
                    viewModel.sendCode()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(30)
                    } else {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
                .disabled(viewModel.isButtonDisabled || viewModel.isLoading)
                .opacity(viewModel.isButtonDisabled ? 0.4 : 1)
                .padding(.bottom, 30)
                
            }
            .padding(.horizontal, 24)
            .navigationDestination(isPresented: $viewModel.goNext) {
                VerificationCodeView(email: viewModel.email)
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
