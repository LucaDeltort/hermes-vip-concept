//
//  AppointmentDetailScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct AppointmentDetailScreen: View {
    @State private var viewModel: ViewModel
    @State private var showCancelDialog = false

    /// Called after the visit is cancelled, so the host can dismiss + refresh home.
    let onCancelled: () -> Void

    init(
        appointment: Appointment,
        products: [Product],
        viewModel: ViewModel? = nil,
        onCancelled: @escaping () -> Void
    ) {
        self.onCancelled = onCancelled
        _viewModel = State(
            initialValue: viewModel ?? ViewModel(appointment: appointment, products: products)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                recapCard
                if !viewModel.products.isEmpty {
                    piecesSection
                }
            }
            .padding(Theme.Spacing.screen)
        }
        .hermesBackground()
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { actionBar }
        .alert("Annuler ce rendez-vous ?", isPresented: $showCancelDialog) {
            Button("Annuler le rendez-vous", role: .destructive) {
                Task {
                    if await viewModel.cancel() { onCancelled() }
                }
            }
            Button("Conserver", role: .cancel) {}
        } message: {
            Text("Cette action est définitive. Votre conseiller en sera informé.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            EyebrowLabel(text: "Votre rendez-vous")
            Text(formattedDate)
                .font(Theme.Font.display(26, weight: .light))
                .foregroundStyle(Color(.textPrimary))
            Text(viewModel.appointment.boutique)
                .font(Theme.Font.body(14))
                .foregroundStyle(Color(.textSecondary))
        }
    }

    // MARK: - Recap

    private var recapCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            metaRow(label: "Boutique", value: viewModel.appointment.boutique)
            metaRow(label: "Date", value: formattedDate)
            metaRow(label: "Conseiller", value: viewModel.appointment.advisorName)
        }
        .frame(maxWidth: .infinity)
        .cardSurface(padding: 22)
    }

    private func metaRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.md) {
            Text(label.uppercased())
                .font(Theme.Font.mono(10))
                .tracking(Theme.Tracking.wide(10))
                .foregroundStyle(Color(.textMuted))
            Spacer(minLength: 0)
            Text(value)
                .font(Theme.Font.display(16))
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Pieces

    private var piecesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            EyebrowLabel(text: "Vos pièces", color: Color(.textMuted))
            ForEach(viewModel.products) { product in
                HStack(spacing: Theme.Spacing.md) {
                    ProductImageView(
                        assets: product.imageAssets,
                        cornerRadius: Theme.Radius.input,
                        label: product.category
                    )
                    .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.name)
                            .font(Theme.Font.display(15))
                            .foregroundStyle(Color(.textPrimary))
                        EyebrowLabel(text: product.category, color: Color(.textMuted), size: 9)
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    // MARK: - Action bar

    private var actionBar: some View {
        VStack(spacing: Theme.Spacing.sm) {
            if let error = viewModel.cancelError {
                Text(error)
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Color(.accent))
            }

            Button(action: { Task { await viewModel.addToCalendar() } }) {
                HStack(spacing: Theme.Spacing.xs) {
                    if let icon = calendarButtonIcon {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .medium))
                    }
                    Text(calendarButtonTitle)
                }
                .foregroundStyle(viewModel.calendarState == .added ? Color(.accent) : Color(.textPrimary))
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(viewModel.calendarState == .adding || viewModel.calendarState == .added)
            .animation(.easeOut(duration: 0.2), value: viewModel.calendarState)

            Button(action: { showCancelDialog = true }) {
                if viewModel.isCancelling {
                    ProgressView().tint(Color(.textMuted))
                } else {
                    Text("Annuler le rendez-vous")
                        .font(Theme.Font.mono(12, weight: .medium))
                        .tracking(Theme.Tracking.wide(12))
                        .foregroundStyle(Color(.textMuted))
                }
            }
            .frame(height: 32)
            .disabled(viewModel.isCancelling)
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.xs)
        .background(Color(.backgroundBase).opacity(0.92))
    }

    // MARK: - Derived copy

    private var formattedDate: String {
        viewModel.appointment.date.formatted(
            .dateTime.weekday(.wide).day().month(.wide).hour().minute().locale(.maison)
        )
        .capitalized(with: .maison)
    }

    private var calendarButtonTitle: String {
        switch viewModel.calendarState {
        case .idle: "Ajouter au calendrier"
        case .adding: "Ajout en cours…"
        case .added: "Ajouté à votre calendrier"
        case .failed: "Calendrier indisponible"
        }
    }

    private var calendarButtonIcon: String? {
        switch viewModel.calendarState {
        case .idle: "calendar.badge.plus"
        case .adding: nil
        case .added: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle"
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentDetailScreen(
            appointment: .sample,
            products: Array(Product.samples.prefix(2)),
            viewModel: AppointmentDetailScreen.ViewModel(
                appointment: .sample,
                products: Array(Product.samples.prefix(2)),
                bookingRepository: APIBookingRepository(client: MockAPIClient())
            ),
            onCancelled: {}
        )
    }
    .preferredColorScheme(.dark)
}
