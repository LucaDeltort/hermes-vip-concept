//
//  EventsScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI
import UIKit

struct EventsScreen: View {
    @Environment(\.openURL) private var openURL
    @State private var viewModel: ViewModel
    /// Events the member has tapped "Confirmer ma présence" on (local concept state).
    @State private var confirmedEventIDs: Set<String> = []
    /// Confirmed events the member has also added to their device calendar.
    @State private var calendarAddedEventIDs: Set<String> = []
    /// Surfaced when adding a confirmed event to the calendar fails.
    @State private var calendarAlert: CalendarAlert?

    init(viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    /// Why an "add to calendar" attempt could not complete.
    private enum CalendarAlert: Identifiable {
        case accessDenied, saveFailed
        var id: Self { self }

        var message: String {
            switch self {
            case .accessDenied:
                return "Autorisez l'accès au calendrier dans les Réglages pour y ajouter vos événements."
            case .saveFailed:
                return "L'événement n'a pas pu être ajouté à votre calendrier."
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("Événements")
                    .font(Theme.Font.display(30, weight: .light))
                    .foregroundStyle(Color(.textPrimary))

                AsyncStateView(
                    state: viewModel.state,
                    skeletonData: Self.skeleton,
                    onRetry: { Task { await viewModel.load() } }
                ) { data in
                    content(data)
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.top, Theme.Spacing.sm)
            .padding(.bottom, 100)
        }
        .hermesBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
        .alert(
            "Calendrier",
            isPresented: isCalendarAlertPresented,
            presenting: calendarAlert
        ) { alert in
            if alert == .accessDenied {
                Button("Réglages") { openSettings() }
            }
            Button("OK", role: .cancel) {}
        } message: { alert in
            Text(alert.message)
        }
    }

    private var isCalendarAlertPresented: Binding<Bool> {
        Binding(
            get: { calendarAlert != nil },
            set: { if !$0 { calendarAlert = nil } }
        )
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    @ViewBuilder
    private func content(_ data: ViewData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            ForEach(data.events) { event in
                EventHeroCard(
                    event: event,
                    isConfirmed: confirmedEventIDs.contains(event.id),
                    isInCalendar: calendarAddedEventIDs.contains(event.id),
                    onConfirm: { confirm(event) },
                    onAddToCalendar: { addToCalendar(event) }
                )
            }

            if !data.souvenirs.isEmpty {
                souvenirsSection(data.souvenirs)
            }
        }
    }

    private func souvenirsSection(_ souvenirs: [Souvenir]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            EyebrowLabel(text: "Souvenirs", color: Color(.textSecondary))
            ForEach(souvenirs) { SouvenirCard(souvenir: $0) }
        }
    }

    /// Confirm (or undo) attendance. RSVP only — adding to the device calendar
    /// is a separate, opt-in action.
    private func confirm(_ event: Event) {
        if confirmedEventIDs.contains(event.id) {
            confirmedEventIDs.remove(event.id)
        } else {
            confirmedEventIDs.insert(event.id)
        }
    }

    /// Add a confirmed event to the member's device calendar on demand.
    private func addToCalendar(_ event: Event) {
        Task {
            switch await CalendarService.add(event) {
            case .added: calendarAddedEventIDs.insert(event.id)
            case .denied: calendarAlert = .accessDenied
            case .failed: calendarAlert = .saveFailed
            }
        }
    }

    /// Sample used as the redacted loading skeleton.
    static let skeleton = ViewData(events: Event.samples, souvenirs: Souvenir.samples)
}

// MARK: - Event hero card

/// A full-bleed upcoming-event card: image, "sur invitation" badge, title,
/// place · date and the "Confirmer ma présence" call to action.
private struct EventHeroCard: View {
    let event: Event
    let isConfirmed: Bool
    let isInCalendar: Bool
    let onConfirm: () -> Void
    let onAddToCalendar: () -> Void

    private var heroAssets: [String] { [event.imageAsset].compactMap { $0 } }

    var body: some View {
        ProductImageView(assets: heroAssets, cornerRadius: 0)
            .frame(height: 420)
            .overlay {
                LinearGradient(
                    colors: [Color(.backgroundBase).opacity(0.94), .clear],
                    startPoint: .bottom,
                    endPoint: .center
                )
            }
            .overlay(alignment: .topLeading) { badge.padding(18) }
            .overlay(alignment: .bottomLeading) { caption.padding(22) }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
            }
    }

    private var badge: some View {
        Text(event.eyebrow)
            .font(Theme.Font.mono(10, weight: .medium))
            .tracking(Theme.Tracking.wide(10))
            .foregroundStyle(Color(.gold))
            .padding(.horizontal, 14)
            .frame(height: 30)
            .overlay(Capsule().strokeBorder(Color(.gold), lineWidth: 1))
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(event.title)
                .font(Theme.Font.display(28, weight: .regular))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(event.location) · \(formattedDate)")
                .font(Theme.Font.mono(11))
                .tracking(11 * 0.08)
                .foregroundStyle(Color(.textSecondary))

            confirmButton
                .padding(.top, Theme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var confirmButton: some View {
        if isConfirmed {
            VStack(spacing: Theme.Spacing.sm) {
                Button(action: onConfirm) {
                    Label("Présence confirmée", systemImage: "checkmark")
                }
                .buttonStyle(SecondaryButtonStyle())

                Button(action: onAddToCalendar) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: isInCalendar ? "checkmark.circle.fill" : "calendar.badge.plus")
                            .font(.system(size: 13, weight: .medium))
                        Text(isInCalendar ? "Ajouté à votre calendrier" : "Ajouter au calendrier")
                    }
                    .foregroundStyle(isInCalendar ? Color(.accent) : Color(.textPrimary))
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(isInCalendar)
                .animation(.easeOut(duration: 0.2), value: isInCalendar)
            }
        } else {
            Button("Confirmer ma présence", action: onConfirm)
                .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var formattedDate: String {
        event.date.formatted(.dateTime.day().month(.wide).locale(.maison))
    }
}

// MARK: - Souvenir card

/// A past event kept as a small photo album: title, period caption and a
/// three-up photo grid.
private struct SouvenirCard: View {
    let souvenir: Souvenir

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 6),
        count: 3
    )

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(souvenir.title)
                    .font(Theme.Font.display(19))
                    .foregroundStyle(Color(.textPrimary))
                Text(souvenir.caption)
                    .font(Theme.Font.mono(10))
                    .tracking(Theme.Tracking.wide(10))
                    .textCase(.uppercase)
                    .foregroundStyle(Color(.textMuted))
            }

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(souvenir.photoAssets, id: \.self) { asset in
                    ProductImageView(assets: [asset], cornerRadius: 4)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: Theme.Spacing.lg)
    }
}

#Preview {
    NavigationStack {
        EventsScreen(
            viewModel: EventsScreen.ViewModel(
                repository: APIEventsRepository(client: MockAPIClient())
            )
        )
    }
    .preferredColorScheme(.dark)
}
