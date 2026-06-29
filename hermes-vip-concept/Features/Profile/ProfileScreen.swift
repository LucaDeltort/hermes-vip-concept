//
//  ProfileScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// The preference rows that open a presented sheet.
private enum ProfileSheet: String, Identifiable {
    case notifications, privacy, membership
    var id: String { rawValue }
}

struct ProfileScreen: View {
    @Environment(\.appStateManager) private var appState
    @Environment(ConversationCoordinator.self) private var conversation
    @State private var viewModel: ViewModel
    @State private var activeSheet: ProfileSheet?

    init(viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    var body: some View {
        ScrollView {
            AsyncStateView(
                state: viewModel.state,
                skeletonData: .sample,
                onRetry: { Task { await viewModel.load() } }
            ) { profile in
                content(profile)
            }
        }
        .hermesBackground()
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .notifications: NotificationsSheet()
            case .privacy: PrivacySheet()
            case .membership: MembershipDetailView()
            }
        }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
    }

    private func content(_ profile: MemberProfile) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            header(profile)
            if let advisor = profile.advisor {
                advisorCard(advisor)
            }

            VStack(spacing: 0) {
                PreferenceToggleRow(
                    icon: "faceid",
                    label: "Verrouillage \(BiometricAuthenticator.biometryLabel)",
                    isOn: Binding(
                        get: { appState.isBiometricLockEnabled },
                        set: { appState.isBiometricLockEnabled = $0 }
                    )
                )
                Divider().overlay(Color(.hairline))
                PreferenceRow(icon: "bell", label: "Notifications") {
                    activeSheet = .notifications
                }
                Divider().overlay(Color(.hairline))
                PreferenceRow(icon: "lock", label: "Confidentialité") {
                    activeSheet = .privacy
                }
                Divider().overlay(Color(.hairline))
                PreferenceRow(icon: "doc.text", label: "Conditions d'adhésion") {
                    activeSheet = .membership
                }
            }
            .cardSurface(padding: 0)

            Button("Se déconnecter") { appState.signOut() }
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(Theme.Spacing.screen)
    }

    // MARK: - Header

    private func header(_ profile: MemberProfile) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            VStack(spacing: Theme.Spacing.xxs) {
                Text(profile.name)
                    .font(Theme.Font.display(28, weight: .light))
                    .foregroundStyle(Color(.textPrimary))
                EyebrowLabel(text: profile.tier)
                Text("depuis \(memberSince(profile.memberSince))")
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Color(.textMuted))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Advisor

    private func advisorCard(_ advisor: Advisor) -> some View {
        Button {
            conversation.present()
        } label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                EyebrowLabel(text: "Votre conseillère")
                HStack(spacing: Theme.Spacing.md) {
                    ProductImageView(
                        assets: [advisor.portraitAsset].compactMap { $0 },
                        cornerRadius: 24
                    )
                    .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(advisor.name)
                            .font(Theme.Font.display(17))
                            .foregroundStyle(Color(.textPrimary))
                        Text(advisor.boutique)
                            .font(Theme.Font.mono(10))
                            .tracking(Theme.Tracking.wide(10))
                            .foregroundStyle(Color(.textMuted))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Color(.textMuted))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
        }
        .buttonStyle(.plain)
    }

    private func memberSince(_ date: Date) -> String {
        date.formatted(.dateTime.year().locale(.maison))
    }
}

/// A single preference row. Tappable when an `action` is provided; the rows
/// without one are decorative in this concept.
private struct PreferenceRow: View {
    let icon: String
    let label: String
    var action: (() -> Void)?

    init(icon: String, label: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.label = label
        self.action = action
    }

    var body: some View {
        if let action {
            Button(action: action) { rowContent }
                .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color(.gold))
                .frame(width: 22)
            Text(label)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textPrimary))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color(.textMuted))
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: Theme.Metrics.preferenceRowHeight)
        .contentShape(Rectangle())
    }
}

/// A preference row carrying an inline toggle instead of a disclosure chevron.
/// Used for the Face ID lock, which is a live setting (not a sheet).
private struct PreferenceToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color(.gold))
                .frame(width: 22)
            Text(label)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textPrimary))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(.accent))
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: Theme.Metrics.preferenceRowHeight)
    }
}

/// Shared chrome for the profile sheets: "Hermès VIP" eyebrow, large title, a
/// scrolling body and a "Fermer" button. Keeps the three sheets consistent.
private struct ProfileSheetScaffold<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    EyebrowLabel(text: "Hermès VIP")
                    Text(title)
                        .font(Theme.Font.display(30, weight: .light))
                        .foregroundStyle(Color(.textPrimary))
                }

                content

                Button("Fermer") { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            .padding(Theme.Spacing.screen)
        }
        .hermesBackground()
        .preferredColorScheme(.dark)
    }
}

/// A labelled toggle row used inside the preference sheets (decorative state).
private struct SettingToggle: View {
    let label: String
    @State var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textPrimary))
        }
        .tint(Color(.accent))
    }
}

/// A gold-bullet list item used inside the preference sheets.
private struct BulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Color(.gold))
                .frame(width: 5, height: 5)
                .padding(.top, 7)
            Text(text)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textPrimary))
                .lineSpacing(4)
        }
    }
}

/// "Conditions d'adhésion" — sells the selectivity of the maison and the
/// privileges that come with membership.
private struct MembershipDetailView: View {
    private let privileges = [
        "Un conseiller personnel dédié, joignable à toute heure.",
        "L'accès anticipé aux nouvelles collections, avant leur présentation publique.",
        "Des invitations aux événements privés de la maison.",
        "La réservation prioritaire des pièces et de vos rendez-vous en boutique.",
        "Des pièces mises de côté, pensées rien que pour vous."
    ]

    var body: some View {
        ProfileSheetScaffold(title: "Conditions d'adhésion") {
            Text("Hermès VIP est un cercle privé, accessible uniquement par cooptation. Chaque candidature est étudiée puis validée par un conseiller de la maison. Le nombre de membres est volontairement limité, afin de préserver la rareté des pièces et la qualité de l'accompagnement.")
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textSecondary))
                .lineSpacing(5)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                EyebrowLabel(text: "Vos privilèges")
                ForEach(privileges, id: \.self) { BulletRow(text: $0) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()

            Text("Une relation, avant d'être une collection.")
                .font(Theme.Font.displayItalic(17))
                .foregroundStyle(Color(.gold))

            Text("Adhésion strictement personnelle et non transférable.")
                .font(Theme.Font.mono(10))
                .tracking(Theme.Tracking.wide(10))
                .foregroundStyle(Color(.textMuted))
        }
    }
}

/// "Notifications" — control which signals from the maison reach the member.
private struct NotificationsSheet: View {
    var body: some View {
        ProfileSheetScaffold(title: "Notifications") {
            Text("Choisissez les attentions que la maison vous adresse. Chaque notification est envoyée avec discrétion, jamais à des fins commerciales.")
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textSecondary))
                .lineSpacing(5)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                EyebrowLabel(text: "Vos préférences")
                SettingToggle(label: "Nouvelles collections", isOn: true)
                Divider().overlay(Color(.hairline))
                SettingToggle(label: "Rendez-vous & rappels", isOn: true)
                Divider().overlay(Color(.hairline))
                SettingToggle(label: "Messages de votre conseiller", isOn: true)
                Divider().overlay(Color(.hairline))
                SettingToggle(label: "Invitations aux événements privés", isOn: true)
                Divider().overlay(Color(.hairline))
                SettingToggle(label: "Pièces réservées disponibles", isOn: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()

            Text("Votre conseiller reste joignable à toute heure, quel que soit votre choix.")
                .font(Theme.Font.mono(10))
                .tracking(Theme.Tracking.wide(10))
                .foregroundStyle(Color(.textMuted))
        }
    }
}

/// "Confidentialité" — the maison's discretion commitments + data controls.
private struct PrivacySheet: View {
    private let commitments = [
        "Vos données ne sont jamais partagées ni revendues à des tiers.",
        "Vos échanges avec votre conseiller restent strictement confidentiels.",
        "Vos achats et préférences ne servent qu'à mieux vous accompagner.",
        "Vous pouvez demander la suppression de vos données à tout moment."
    ]

    var body: some View {
        ProfileSheetScaffold(title: "Confidentialité") {
            Text("La discrétion est au cœur de la maison. Ce que vous nous confiez vous appartient, et n'a d'autre usage que de rendre votre expérience plus juste.")
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textSecondary))
                .lineSpacing(5)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                EyebrowLabel(text: "Nos engagements")
                ForEach(commitments, id: \.self) { BulletRow(text: $0) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                EyebrowLabel(text: "Vos contrôles")
                SettingToggle(label: "Personnalisation des recommandations", isOn: true)
                Divider().overlay(Color(.hairline))
                SettingToggle(label: "Partage d'activité avec la boutique", isOn: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface()
        }
    }
}

#Preview {
    ProfileScreen(
        viewModel: ProfileScreen.ViewModel(
            repository: APIProfileRepository(client: MockAPIClient())
        )
    )
    .environment(\.appStateManager, AppStateManager())
    .environment(ConversationCoordinator())
    .preferredColorScheme(.dark)
}
