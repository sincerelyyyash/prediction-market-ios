import SwiftUI

struct ProfileView: View {
    private enum ProfileRoute: Hashable {
        case addFunds
        case withdraw
    }

    @StateObject private var authService = AuthService.shared
    @State private var userProfile: UserProfile?
    @State private var memberSince: String = "Pulse trader"
    @State private var balance: Double = 0
    @State private var path: [ProfileRoute] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
                    content
                }
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .addFunds:
                    AddFundsScreen(balance: $balance, handleSubmit: handleOnramp)
                case .withdraw:
                    WithdrawFundsScreen(balance: $balance)
                }
            }
        }
        .task {
            await refreshProfile()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Profile")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Manage your account and preferences")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Current Balance")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(formattedCurrency(balance))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
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
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
            }
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(userProfile?.name ?? "Trader")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Text(userProfile?.email ?? "--")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Text(memberSince)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
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
                tint: .green
            ) { path.append(.addFunds) }

            actionRow(
                title: "Withdraw Funds",
                subtitle: "Transfer funds to your bank",
                icon: "arrow.up.right.circle.fill",
                tint: .blue
            ) { path.append(.withdraw) }

            actionRow(
                title: "Transaction History",
                subtitle: "View deposits and withdrawals",
                icon: "clock.fill",
                tint: .yellow
            ) {}

            actionRow(
                title: "Settings",
                subtitle: "Security, notifications, preferences",
                icon: "gearshape.fill",
                tint: .gray
            ) {}

            actionRow(
                title: "Help & Support",
                subtitle: "FAQs and contact us",
                icon: "questionmark.circle.fill",
                tint: .purple
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
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.red)
                        Text("Sign out of your account")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08))
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
                        .fill(tint.opacity(0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08))
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
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
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
            ProgressView("Loading profile...")
                .progressViewStyle(.circular)
                .tint(.white)
        } else if let errorMessage {
            VStack(spacing: 12) {
                Text("Unable to load profile")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await refreshProfile() }
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            ScrollView {
                VStack(spacing: 14) {
                    Spacer(minLength: 8)
                    header
                        .padding(.horizontal, 16)
                        .padding(.bottom, 2)

                    balanceCard
                        .padding(.horizontal, 16)

                    userCard
                        .padding(.horizontal, 16)

                    actionSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
        }
    }

    private func refreshProfile() async {
        guard let userId = authService.session?.user.id else {
            await MainActor.run {
                errorMessage = "Please sign in to view your profile."
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            async let profileTask = UserService.shared.getUser(by: userId)
            async let balanceTask = UserService.shared.getBalance()
            let (profile, balanceResponse) = try await (profileTask, balanceTask)
            await MainActor.run {
                userProfile = profile
                memberSince = "Member since \(Calendar.current.component(.year, from: Date()))"
                balance = Double(balanceResponse.balance ?? 0)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
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
        .preferredColorScheme(.dark)
}

// MARK: - Inline Screens

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
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 16)

                        amountCard
                            .padding(.horizontal, 16)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
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
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
        }
        .navigationTitle("Add Funds")
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount (USD)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))
            HStack(spacing: 10) {
                Text("$")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.85))
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08))
                    )
            )
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
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
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    balance += amount
                    amountText = ""
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
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
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
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))
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
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))
            HStack(spacing: 10) {
                Text("$")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.85))
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08))
                    )
            )
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
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
            Color.black.ignoresSafeArea()
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: .white, location: 0.0),
                    .init(color: Color(red: 0.7, green: 0.7, blue: 0.75), location: 0.0),
                    .init(color: .black, location: 0.4)
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

