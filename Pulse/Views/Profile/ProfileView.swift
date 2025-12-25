import SwiftUI

struct ProfileView: View {
    private enum ProfileRoute: Hashable {
        case addFunds
    }

    @StateObject private var authService = AuthService.shared
    @State private var userProfile: UserProfile?
    @State private var memberSince: String = "Pulse trader"
    @State private var balance: Double = 0
    @State private var path: [ProfileRoute] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var requiresAuth = false

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    VStack(spacing: 0) {
                        Spacer(minLength: 8)
                        if !requiresAuth {
                            header
                                .padding(.horizontal, 16)
                                .padding(.bottom, 6)
                        } else {
                            simpleHeader
                                .padding(.horizontal, 16)
                                .padding(.bottom, 6)
                        }
                        content
                    }
                }
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                Group {
                    switch route {
                    case .addFunds:
                        AddFundsScreen(balance: $balance, handleSubmit: handleOnramp)
                            .transition(.slideFromTrailing)
                    }
                }
            }
        }
        .task {
            await loadProfileFast()
        }
    }

    private var simpleHeader: some View {
        PageIntroHeader(
            title: "Profile",
            subtitle: "Manage your account and preferences"
        )
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            PageIntroHeader(
                title: "Profile",
                subtitle: "Manage your account and preferences"
            )
            balanceCard
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Current Balance")
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(formattedCurrency(balance))
                    .font(.dmMonoMedium(size: 30))
                    .foregroundColor(AppColors.primaryText)
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.cardBackground(opacity: 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColors.border(opacity: 0.08))
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current Balance")
        .accessibilityValue(formattedCurrency(balance))
    }

    private var userCard: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.cardBackground(opacity: 0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.9))
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(userProfile?.name ?? "Trader")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(AppColors.primaryText)
                Text(userProfile?.email ?? "--")
                    .font(.dmMonoRegular(size: 15))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                Text(memberSince)
                    .font(.dmMonoRegular(size: 13))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.6))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.cardBackground(opacity: 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppColors.border(opacity: 0.08))
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("User Info")
        .accessibilityValue("\(userProfile?.name ?? "Trader"), \(userProfile?.email ?? "--")")
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            actionRow(
                title: "Add Funds",
                subtitle: "Deposit to trading balance",
                icon: "plus.circle.fill",
                tint: AppColors.primaryText
            ) {
                withAnimation(.slideTransition) {
                    path.append(.addFunds)
                }
            }

            actionRow(
                title: "Transaction History",
                subtitle: "View deposits and withdrawals",
                icon: "clock.fill",
                tint: AppColors.primaryText
            ) {}

            actionRow(
                title: "Help & Support",
                subtitle: "FAQs and contact us",
                icon: "questionmark.circle.fill",
                tint: AppColors.primaryText
            ) {}

            Button {
                handleLogout()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.red.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logout")
                            .font(.dmMonoMedium(size: 17))
                            .foregroundColor(.red)
                        Text("Sign out of your account")
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.cardBackground(opacity: 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppColors.border(opacity: 0.08))
                        )
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Logout")
        }
    }

    private func actionRow(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppColors.cardBackground(opacity: 0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.9))
                }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.dmMonoMedium(size: 17))
                            .foregroundColor(AppColors.primaryText)
                        Text(subtitle)
                            .font(.dmMonoRegular(size: 13))
                            .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                    }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.cardBackground(opacity: 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColors.border(opacity: 0.08))
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            FullScreenLoadingView(message: "Loading profile...")
        } else if requiresAuth {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppColors.cardBackground(opacity: 0.08))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 36))
                        .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                }
                .padding(.bottom, 4)
                
                Text("Sign in to view your profile")
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Access your account details, balance, and manage your trading preferences.")
                    .font(.dmMonoRegular(size: 14))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button {
                    handleLogout()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Sign In")
                            .font(.dmMonoMedium(size: 16))
                    }
                    .foregroundColor(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 48)
                .padding(.top, 8)
                .accessibilityLabel("Sign In")
                .accessibilityHint("Redirects to the sign in screen")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text("Unable to load profile")
                    .font(.dmMonoMedium(size: 17))
                    .foregroundColor(AppColors.primaryText)
                Text(errorMessage)
                    .font(.dmMonoRegular(size: 15))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Button("Retry") {
                    Task { await loadProfileFast() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            }
        } else {
            ScrollView {
                VStack(spacing: 14) {
                    userCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    actionSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
            .background(AppColors.background)
        }
    }

    private func loadProfileFast() async {
        guard let userId = authService.session?.user.id else {
            await MainActor.run {
                isLoading = false
                requiresAuth = true
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
            requiresAuth = false
        }

        if let sessionUser = authService.session?.user {
            await MainActor.run {
                userProfile = UserProfile(id: sessionUser.id, email: sessionUser.email, name: sessionUser.name, balance: sessionUser.balance)
                memberSince = "Member since \(Calendar.current.component(.year, from: Date()))"
            }
        }

        do {
            async let profileTask = UserService.shared.getUser(by: Int64(userId))
            async let balanceTask = UserService.shared.getBalance()

            let profile = try await profileTask
            let balanceResponse = try await balanceTask

            await MainActor.run {
                userProfile = profile
                memberSince = "Member since \(Calendar.current.component(.year, from: Date()))"
                balance = Double(balanceResponse.balance ?? profile.balance ?? 0)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                let message = error.localizedDescription
                if message.lowercased().contains("jwt") || message.lowercased().contains("unauthorized") {
                    errorMessage = "Session expired. Please sign in again."
                } else {
                    errorMessage = message
                }
            }
        }
    }

    private func handleOnramp(amount: Int64) async throws {
        let response = try await UserService.shared.onramp(amount: amount)
        if let updatedBalance = response.data?.balance {
            await MainActor.run {
                balance = Double(updatedBalance)
            }
        } else {
            let balanceResponse = try await UserService.shared.getBalance()
            await MainActor.run {
                balance = Double(balanceResponse.balance ?? 0)
            }
        }
    }

    private func handleLogout() {
        AuthService.shared.signOut()
        userProfile = nil
        balance = 0
    }
}

#Preview {
    ProfileView()
}

private struct AddFundsScreen: View {
    @Binding var balance: Double
    @State private var amountText: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    let handleSubmit: (Int64) async throws -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                ScrollView {
                    VStack(spacing: 14) {
                        Spacer(minLength: 8)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Deposit to your trading balance")
                                .font(.dmMonoRegular(size: 14))
                                .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                        }
                        .padding(.horizontal, 16)

                        amountCard
                            .padding(.horizontal, 16)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.dmMonoRegular(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                        }

                        primaryButton(title: isSubmitting ? "Processing..." : "Add Funds", action: handleAdd)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 16)
                }
                if isSubmitting {
                    InlineLoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.overlayBackground(opacity: 0.3))
                }
            }
        }
        .navigationTitle("Add Funds")
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount (USD)")
                .font(.dmMonoRegular(size: 15))
                .foregroundColor(AppColors.secondaryText(opacity: 0.75))
            HStack(spacing: 10) {
                Text("$")
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.85))
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.primaryText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.cardBackground(opacity: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppColors.border(opacity: 0.08))
                    )
            )
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.dmMonoMedium(size: 17))
                .foregroundColor(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func handleAdd() {
        let cleaned = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Double(cleaned), amount > 0 else {
            errorMessage = "Enter a valid amount."
            return
        }

        errorMessage = nil
        isSubmitting = true

        Task {
            do {
                try await handleSubmit(Int64(amount))
                await MainActor.run {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        amountText = ""
                    }
                }
                isSubmitting = false
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

private struct WithdrawFundsScreen: View {
    @Binding var balance: Double
    @State private var amountText: String = ""

    var body: some View {
        GeometryReader { geo in
            ZStack {
                backgroundGradient(for: geo)
                ScrollView {
                    VStack(spacing: 14) {
                        Spacer(minLength: 8)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Transfer funds to your bank")
                                .font(.dmMonoRegular(size: 14))
                                .foregroundColor(AppColors.secondaryText(opacity: 0.75))
                        }
                        .padding(.horizontal, 16)

                        amountCard
                            .padding(.horizontal, 16)

                        primaryButton(title: "Withdraw Funds", action: handleWithdraw)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("Withdraw")
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount (USD)")
                .font(.dmMonoRegular(size: 15))
                .foregroundColor(AppColors.secondaryText(opacity: 0.75))
            HStack(spacing: 10) {
                Text("$")
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.secondaryText(opacity: 0.85))
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.dmMonoMedium(size: 20))
                    .foregroundColor(AppColors.primaryText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.cardBackground(opacity: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppColors.border(opacity: 0.08))
                    )
            )
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.dmMonoMedium(size: 17))
                .foregroundColor(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func handleWithdraw() {
        let cleaned = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Double(cleaned), amount > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            balance = max(0, balance - amount)
            amountText = ""
        }
    }

    private func backgroundGradient(for geo: GeometryProxy) -> some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: AppColors.gradientStart, location: 0.0),
                    .init(color: AppColors.gradientMiddle, location: 0.15),
                    .init(color: AppColors.gradientEnd, location: 0.4)
                ]),
                center: .top,
                startRadius: 0,
                endRadius: max(geo.size.width, geo.size.height) * 0.9
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

