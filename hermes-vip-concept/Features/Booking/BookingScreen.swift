//
//  BookingScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct BookingScreen: View {
    /// The member's favorited pieces this visit is booked for (Wishlist).
    let products: [Product]
    /// Called with the confirmed appointment once the reservation succeeds.
    let onConfirmed: (Appointment) -> Void

    @State private var viewModel: ViewModel

    init(
        products: [Product],
        viewModel: ViewModel? = nil,
        onConfirmed: @escaping (Appointment) -> Void
    ) {
        self.products = products
        self.onConfirmed = onConfirmed
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    var body: some View {
        ScrollView {
            AsyncStateView(
                state: viewModel.state,
                onRetry: { Task { await viewModel.load() } }
            ) { data in
                content(for: data)
            }
        }
        .hermesBackground()
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { confirmBar }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
    }

    // MARK: - Content

    private var headerTitle: String {
        products.count == 1 ? products[0].name : "Vos pièces favorites"
    }

    private func content(for data: ViewData) -> some View {
        let calendar = Calendar.maison
        let month = data.slots.first?.date ?? Date()
        let availableDays = Set(
            data.slots.filter(\.isAvailable).map { calendar.startOfDay(for: $0.date) }
        )
        let daySlots = data.slots.filter { slot in
            guard let day = viewModel.selectedDay else { return false }
            return calendar.isDate(slot.date, inSameDayAs: day)
        }

        return VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                EyebrowLabel(text: "Réserver une visite")
                Text(headerTitle)
                    .font(Theme.Font.display(26, weight: .light))
                    .foregroundStyle(Color(.textPrimary))
                Text("Hermès — 24 Faubourg")
                    .font(Theme.Font.body(14))
                    .foregroundStyle(Color(.textSecondary))
            }

            if !products.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    EyebrowLabel(text: "Pour vos pièces", color: Color(.textMuted))
                    ForEach(products) { product in
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

            MonthCalendarView(
                month: month,
                availableDays: availableDays,
                selectedDay: viewModel.selectedDay,
                onSelectDay: { viewModel.selectDay($0) }
            )

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                EyebrowLabel(text: "Horaires disponibles")
                if daySlots.isEmpty {
                    Text("Sélectionnez une date marquée pour voir les horaires.")
                        .font(Theme.Font.body(14))
                        .foregroundStyle(Color(.textMuted))
                } else {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.sm), count: 3),
                        spacing: Theme.Spacing.sm
                    ) {
                        ForEach(daySlots) { slot in
                            Chip(
                                title: slot.label,
                                isSelected: slot.id == viewModel.selectedSlot?.id,
                                isEnabled: slot.isAvailable
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { viewModel.select(slot) }
                        }
                    }
                }
            }
        }
        .padding(Theme.Spacing.screen)
    }

    // MARK: - Confirm bar

    @ViewBuilder
    private var confirmBar: some View {
        if viewModel.state.data != nil {
            VStack(spacing: Theme.Spacing.xs) {
                if let error = viewModel.bookingError {
                    Text(error)
                        .font(Theme.Font.body(13))
                        .foregroundStyle(Color(.accent))
                }
                Button {
                    Task {
                        if let appointment = await viewModel.book() {
                            onConfirmed(appointment)
                        }
                    }
                } label: {
                    if viewModel.isBooking {
                        ProgressView().tint(Color(.backgroundBase))
                    } else {
                        Text("Confirmer la visite")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canConfirm))
                .disabled(!viewModel.canConfirm)
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.top, Theme.Spacing.sm)
            .padding(.bottom, Theme.Spacing.xs)
            .background(Color(.backgroundBase).opacity(0.92))
        }
    }
}

// MARK: - Month calendar

/// A single-month grid. Days with availability are tappable and gold-dotted;
/// the selected day is filled with the accent color.
private struct MonthCalendarView: View {
    let month: Date
    let availableDays: Set<Date>
    let selectedDay: Date?
    let onSelectDay: (Date) -> Void

    private let calendar = Calendar.maison
    private let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text(monthTitle)
                .font(Theme.Font.mono(12, weight: .medium))
                .tracking(Theme.Tracking.wider(12))
                .foregroundStyle(Color(.textSecondary))
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(Theme.Font.mono(11))
                        .foregroundStyle(Color(.textMuted))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: Theme.Spacing.sm
            ) {
                ForEach(Array(calendar.monthGrid(for: month).enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .cardSurface()
    }

    private func dayCell(_ day: Date) -> some View {
        let startOfDay = calendar.startOfDay(for: day)
        let isAvailable = availableDays.contains(startOfDay)
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: day) } ?? false

        return Button {
            onSelectDay(startOfDay)
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: day))")
                    .font(Theme.Font.body(15))
                    .foregroundStyle(textColor(isAvailable: isAvailable, isSelected: isSelected))
                Circle()
                    .fill(isAvailable && !isSelected ? Color(.gold) : .clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color(.accent) : .clear)
                    .frame(width: 40, height: 40)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }

    private func textColor(isAvailable: Bool, isSelected: Bool) -> Color {
        if isSelected { return Color(.backgroundBase) }
        return isAvailable ? Color(.textPrimary) : Color(.textMuted)
    }

    private var monthTitle: String {
        month.formatted(.dateTime.month(.wide).year().locale(.maison)).uppercased()
    }
}

#Preview {
    NavigationStack {
        BookingScreen(
            products: Array(Product.samples.prefix(3)),
            viewModel: BookingScreen.ViewModel(
                bookingRepository: APIBookingRepository(client: MockAPIClient())
            ),
            onConfirmed: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
