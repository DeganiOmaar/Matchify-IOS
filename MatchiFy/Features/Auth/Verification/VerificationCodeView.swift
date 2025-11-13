import SwiftUI

struct VerificationCodeView: View {
    @StateObject private var viewModel = VerificationCodeViewModel()
    @FocusState private var isKeyboardActive: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                Text("OTP code verification")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                // MARK: - Description
                Text(buildOTPMessage())
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                
                // MARK: - OTP Boxes
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        otpBox(index)
                    }
                }
                .padding(.top, 5)
                .onTapGesture { isKeyboardActive = true }
                
                // Hidden input
                hiddenCodeTextField
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .focused($isKeyboardActive)
                    .keyboardType(.numberPad)
                
                // MARK: - Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                }
                
                Spacer()
                
                // MARK: - Continue Button
                Button {
                    viewModel.verifyCode()
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
                            .background(viewModel.isButtonDisabled ? Color.blue.opacity(0.3) : Color.blue)
                            .cornerRadius(30)
                    }
                    
                }
                .disabled(viewModel.isButtonDisabled)
                .padding(.bottom, 25)
                
            }
            .padding(.horizontal, 24)
            .navigationDestination(isPresented: $viewModel.goNext) {
                ResetPasswordView()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isKeyboardActive = true
                }
            }
        }
    }
    
    // MARK: - OTP Text Message
    private func buildOTPMessage() -> AttributedString {
        var full = AttributedString("We have an OTP code to your email and ")
        
        var email = AttributedString("amroush123@gmail.com")
        email.foregroundColor = .blue
        email.font = .system(size: 15, weight: .semibold)
        
        let end = AttributedString(" Enter the OTP code below to verify")
        
        full.append(email)
        full.append(end)
        
        return full
    }
    
    // MARK: - OTP Box
    private func otpBox(_ index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 48, height: 55)
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                .frame(width: 48, height: 55)
            
            Text(currentDigit(at: index))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    private func currentDigit(at index: Int) -> String {
        if index < viewModel.code.count {
            let idx = viewModel.code.index(viewModel.code.startIndex, offsetBy: index)
            return String(viewModel.code[idx])
        }
        return ""
    }
    
    private var hiddenCodeTextField: some View {
        TextField("", text: $viewModel.code)
            .textContentType(.oneTimeCode)
    }
}

#Preview {
    VerificationCodeView()
}
