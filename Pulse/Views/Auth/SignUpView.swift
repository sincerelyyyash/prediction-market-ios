import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        AuthScreenContainer(
            title: "Create Account",
            actionTitle: "Sign Up",
            handleAction: handleSignUp
        ) {
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
        }
    }

    private func handleSignUp() {
        // TODO: register user
    }
}

#Preview {
    SignUpView()
        .preferredColorScheme(.dark)
}
