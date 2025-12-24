//
//  SignInView.swift
//  Pulse
//
//  Created by Yash Thakur on 26/11/25.
//

import SwiftUI

struct SignInView: View {
    let onAuthSuccess: () -> Void
    let navigateToSignUp: () -> Void

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
                        .font(.dmMonoRegular(size: 13))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                
                Button(action: navigateToSignUp) {
                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .foregroundColor(AppColors.secondaryText(opacity: 0.8))
                        Text("Sign Up")
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
        SignInView(
            onAuthSuccess: {},
            navigateToSignUp: {}
        )
    }
}
