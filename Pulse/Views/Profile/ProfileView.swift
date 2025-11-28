import SwiftUI

struct ProfileView: View {
    private enum ProfileRoute: Hashable {
        case addFunds
        case withdraw
    }
    @State private var userName: String = "Yash Thakur"
    @State private var userEmail: String = "yash@example.com"
    @State private var memberSince: String = "Member since 2024"
    @State private var balance: Double = 2050.35
    @State private var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geo in
                ZStack {
                    backgroundGradient(for: geo)
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
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .addFunds:
                    AddFundsScreen(balance: $balance)
                case .withdraw:
                    WithdrawFundsScreen(balance: $balance)
                }
            }
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
                Text(userName)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Text(userEmail)
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
        .accessibilityValue("\(userName), \(userEmail)")
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
                // Placeholder logout action
                print("Logout tapped")
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
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}

// MARK: - Inline Screens

private struct AddFundsScreen: View {
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
                            Text("Deposit to your trading balance")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 16)

                        amountCard
                            .padding(.horizontal, 16)

                        primaryButton(title: "Add Funds", action: handleAdd)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("Add Funds")
        .navigationBarTitleDisplayMode(.inline)
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
        guard let amount = Double(cleaned), amount > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            balance += amount
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
        .navigationBarTitleDisplayMode(.inline)
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

