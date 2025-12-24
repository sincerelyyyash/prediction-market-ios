//
//  PulseApp.swift
//  Pulse
//
//  Created by Yash Thakur on 26/11/25.
//

import SwiftUI

@main
struct PulseApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private struct RootView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        ZStack {
            if authService.isAuthenticated {
                ContentView()
                    .transition(.fadeTransition)
            } else {
                OnboardingView()
                    .transition(.fadeTransition)
            }
        }
        .animation(.fadeTransition, value: authService.isAuthenticated)
        .task {
            await authService.restoreSessionIfNeeded()
        }
    }
}
