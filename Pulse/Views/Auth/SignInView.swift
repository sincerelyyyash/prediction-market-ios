//
//  SignInView.swift
//  Pulse
//
//  Created by Yash Thakur on 26/11/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AuthScreenContainer(
                title: "Welcome Back",
                actionTitle: isLoading ? "Signing In..." : "Sign In",
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

    private func handleSignIn() {
        guard !isLoading else { return }
        guard email.contains("@"), password.count >= 8 else {
            errorMessage = "Enter a valid email and password."
            return
        }

        errorMessage = nil
        isLoading = true

        Task {
            do {
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
    SignInView()
        .preferredColorScheme(.dark)
}
