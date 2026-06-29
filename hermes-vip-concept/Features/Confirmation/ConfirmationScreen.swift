//
//  ConfirmationScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct ConfirmationScreen: View {
    let appointment: Appointment
    /// The favorited pieces this visit was booked for (the "Pièce" row).
    let products: [Product]
    /// Dismisses the whole booking flow back to the home root.
    let onDone: () -> Void

    @State private var calendarState: CalendarState = .idle

    private enum CalendarState {
        case idle, adding, added, failed
    }

    var body: some View {
        VStack(spacing: 0) {
            grabHandle
                .padding(.top, 18)
                .padding(.bottom, 34)

            AnimatedCheckmark()
                .frame(width: 76, height: 76)
                .padding(.top, Theme.Spacing.md)

            Text("C'est confirmé")
                .font(Theme.Font.display(28, weight: .regular))
                .foregroundStyle(Color(.textPrimary))
                .padding(.top, Theme.Spacing.md)

            Text("Nous vous attendons.")
                .font(Theme.Font.displayItalic(15, weight: .light))
                .foregroundStyle(Color(.textSecondary))
                .padding(.top, 10)

            recapCard
                .padding(.top, 34)

            Spacer(minLength: Theme.Spacing.lg)

            VStack(spacing: Theme.Spacing.sm) {
                Button(action: addToCalendar) {
                    HStack(spacing: Theme.Spacing.xs) {
                        if let icon = calendarButtonIcon {
                            Image(systemName: icon)
                                .font(.system(size: 13, weight: .medium))
                        }
                        Text(calendarButtonTitle)
                    }
                    .foregroundStyle(calendarState == .added ? Color(.accent) : Color(.textPrimary))
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(calendarState == .adding || calendarState == .added)
                .animation(.easeOut(duration: 0.2), value: calendarState)

                Button("Retour à l'accueil", action: onDone)
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Pieces

    private var grabHandle: some View {
        Capsule()
            .fill(Color(.textPrimary).opacity(0.18))
            .frame(width: 38, height: 4)
    }

    private var recapCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            metaRow(label: "Boutique", value: appointment.boutique)
            metaRow(label: "Date", value: formattedDate)
            metaRow(label: "Conseiller", value: appointment.advisorName)
            if let pieces = piecesValue {
                metaRow(label: "Pièce", value: pieces, isMono: true)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(
            Color(.backgroundBase).opacity(0.5),
            in: RoundedRectangle(cornerRadius: Theme.Radius.card)
        )
    }

    private func metaRow(label: String, value: String, isMono: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.md) {
            Text(label.uppercased())
                .font(Theme.Font.mono(10))
                .tracking(Theme.Tracking.wide(10))
                .foregroundStyle(Color(.textMuted))
            Spacer(minLength: 0)
            Text(value)
                .font(isMono ? Theme.Font.mono(12) : Theme.Font.display(16))
                .foregroundStyle(isMono ? Color(.textSecondary) : Color(.textPrimary))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Derived copy

    private var piecesValue: String? {
        let names = products.map(\.name)
        return names.isEmpty ? nil : names.joined(separator: ", ")
    }

    private var formattedDate: String {
        appointment.date.formatted(
            .dateTime.weekday(.wide).day().month(.wide).hour().minute().locale(.maison)
        )
        .capitalized(with: .maison)
    }

    private var calendarButtonTitle: String {
        switch calendarState {
        case .idle: "Ajouter au calendrier"
        case .adding: "Ajout en cours…"
        case .added: "Ajouté à votre calendrier"
        case .failed: "Calendrier indisponible"
        }
    }

    private var calendarButtonIcon: String? {
        switch calendarState {
        case .idle: "calendar.badge.plus"
        case .adding: nil
        case .added: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle"
        }
    }

    // MARK: - Actions

    private func addToCalendar() {
        calendarState = .adding
        Task {
            let event = Event(
                id: appointment.id,
                title: appointment.title,
                location: appointment.boutique,
                date: appointment.date,
                summary: "Avec \(appointment.advisorName)",
                eyebrow: "RENDEZ-VOUS",
                imageAsset: nil
            )
            let result = await CalendarService.add(event)
            calendarState = result == .added ? .added : .failed
        }
    }
}

// MARK: - Animated checkmark

/// A circle that draws itself, then a checkmark that draws inside it — the
/// mockup's `drawCircle` (1s) / `drawCheck` (0.5s, delayed 0.7s) animation.
private struct AnimatedCheckmark: View {
    @State private var circleProgress: CGFloat = 0
    @State private var checkProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(Color(.accent), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            CheckmarkShape()
                .trim(from: 0, to: checkProgress)
                .stroke(
                    Color(.accent),
                    style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                )
                .padding(22)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                circleProgress = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                checkProgress = 1
            }
        }
    }
}

// MARK: - Sheet glass

/// The frosted-glass backing for the confirmation sheet: a blurred material
/// tinted toward the card color (`rgba(36,32,25,.72)`) with a hairline top edge.
struct ConfirmationSheetBackground: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(Color(.card).opacity(0.72))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color(.textPrimary).opacity(0.12))
                    .frame(height: Theme.Metrics.hairlineWidth)
            }
    }
}

/// A checkmark path normalized to its bounding box.
private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            ConfirmationScreen(
                appointment: .sample,
                products: Array(Product.samples.prefix(1)),
                onDone: {}
            )
            .presentationDetents([.fraction(0.66)])
            .presentationCornerRadius(30)
            .presentationDragIndicator(.hidden)
            .presentationBackground {
                ConfirmationSheetBackground()
            }
        }
        .preferredColorScheme(.dark)
}
