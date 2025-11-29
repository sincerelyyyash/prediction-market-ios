import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

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
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
            }
            .disabled(isLoading)

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
        }
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
                _ = try await AuthService.shared.signIn(email: email, password: password)
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SignUpView()
        .preferredColorScheme(.dark)
}
