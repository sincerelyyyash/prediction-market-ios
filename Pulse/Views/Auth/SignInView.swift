//
//  SignInView.swift
//  Pulse
//
//  Created by Yash Thakur on 26/11/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        AuthScreenContainer(
            title: "Welcome Back",
            actionTitle: "Sign In",
            handleAction: handleSignIn
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
        }
    }

    private func handleSignIn() {
        // TODO: authenticate user
    }
}

#Preview {
    SignInView()
        .preferredColorScheme(.dark)
}
