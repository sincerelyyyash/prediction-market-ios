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
        Group {
            if authService.isAuthenticated {
                ContentView()
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
        .task {
            await authService.restoreSessionIfNeeded()
        }
    }
}
