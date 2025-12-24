import SwiftUI

struct SignUpView: View {
    let onAuthSuccess: () -> Void
    let navigateToSignIn: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AuthScreenContainer(
                title: "Create Account",
                actionTitle: isLoading ? "Creating..." : "Sign Up",
                handleAction: handleSignUp
            ) {
                AuthTextField(
                    placeholder: "Full Name",
                    text: $name,
                    keyboardType: .default
                )
                AuthTextField(
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress
                )
                AuthSecureField(
                    placeholder: "Password",
                    text: $password
                )
                AuthSecureField(
                    placeholder: "Confirm Password",
                    text: $confirmPassword
                )
                if let errorMessage {
                    Text(errorMessage)
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                
                Button(action: navigateToSignIn) {
                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .foregroundColor(AppColors.secondaryText(opacity: 0.8))
                        Text("Sign In")
                            .foregroundColor(AppColors.primaryText)
                    }
                    .font(.dmMonoRegular(size: 15))
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .disabled(isLoading)

            if isLoading {
                InlineLoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.overlayBackground(opacity: 0.3))
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private func handleSignUp() {
        guard !isLoading else { return }
        guard !name.isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email."
            return
        }
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        errorMessage = nil
        isLoading = true

        Task {
            do {
                _ = try await AuthService.shared.signUp(name: name, email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    onAuthSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(
            onAuthSuccess: {},
            navigateToSignIn: {}
        )
    }
}
