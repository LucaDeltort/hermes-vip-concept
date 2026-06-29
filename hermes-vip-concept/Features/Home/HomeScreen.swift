//
//  HomeScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct HomeScreen: View {
    @Environment(BookingCoordinator.self) private var booking
    @State private var viewModel: ViewModel
    /// Drives the appointment-detail cover when an existing visit is tapped.
    @State private var selectedAppointment: AppointmentDetailRequest?

    init(viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    var body: some View {
        ScrollView {
            AsyncStateView(
                state: viewModel.state,
                skeletonData: Self.skeleton,
                onRetry: { Task { await viewModel.load() } }
            ) { data in
                HomeContent(data: data) { appointment in
                    selectedAppointment = AppointmentDetailRequest(
                        appointment: appointment,
                        products: data.curated.filter(\.isFavorite)
                    )
                }
            }
        }
        .hermesBackground()
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedAppointment) { request in
            AppointmentDetailFlowView(
                appointment: request.appointment,
                products: request.products,
                onClose: { selectedAppointment = nil },
                onCancelled: {
                    selectedAppointment = nil
                    Task { await viewModel.load() }
                }
            )
        }
        .onChange(of: booking.completedCount) {
            // A visit was just booked (from any tab) — refresh to surface it.
            Task { await viewModel.load() }
        }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
    }

    /// Sample used as the redacted loading skeleton.
    static let skeleton = ViewData(
        memberName: "Camille",
        nextAppointment: .sample,
        curated: Product.samples,
        editorial: EditorialMoment.samples
    )
}

/// Pure presentational body for the home screen.
private struct HomeContent: View {
    @Environment(ConversationCoordinator.self) private var conversation
    let data: HomeScreen.ViewData
    /// Tapped an existing appointment — open its detail (not the booking flow).
    let onSelectAppointment: (Appointment) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            header

            curatedSection

            if let appointment = data.nextAppointment {
                appointmentSection(appointment)
            }

            editorialSection
        }
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, 100) // clears the floating tab bar
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Bonjour \(data.memberName)")
                    .font(Theme.Font.display(30))
                    .foregroundStyle(Color(.textPrimary))
                Text("Faubourg Saint-Honoré")
                    .font(Theme.Font.mono(11))
                    .tracking(Theme.Tracking.wide(11))
                    .textCase(.uppercase)
                    .foregroundStyle(Color(.textMuted))
            }
            Spacer()
            Button {
                conversation.present()
            } label: {
                Image(systemName: "bubble.left")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color(.textSecondary))
                    .frame(width: 44, height: 44)
                    .background(Color(.card), in: Circle())
                    .overlay(
                        Circle().strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Messages")
        }
        .padding(.horizontal, Theme.Spacing.screen)
    }

    // MARK: - Sélectionné pour vous (horizontal scroll)

    private var curatedSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Sélectionné pour vous")
                .padding(.horizontal, Theme.Spacing.screen)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: Theme.Spacing.md) {
                    ForEach(data.curated) { product in
                        NavigationLink(value: AppRoute.productDetail(productID: product.id)) {
                            VStack(alignment: .leading, spacing: 14) {
                                ProductImageView(
                                    assets: product.imageAssets,
                                    cornerRadius: 4,
                                    label: product.category
                                )
                                .frame(width: 188, height: 224)
                                    .overlay(alignment: .topLeading) {
                                        if let badge = product.badge {
                                            ProductBadgeTag(badge: badge)
                                                .padding(10)
                                        }
                                    }

                                Text(product.name)
                                    .font(Theme.Font.display(18))
                                    .foregroundStyle(Color(.textPrimary))
                            }
                            .frame(width: 188, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screen)
            }
        }
    }

    // MARK: - Votre prochain rendez-vous

    private func appointmentSection(_ appointment: Appointment) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionTitle("Votre prochain rendez-vous")

            Button {
                onSelectAppointment(appointment)
            } label: {
                HStack(spacing: Theme.Spacing.md) {
                    Circle()
                        .fill(Color(.accent))
                        .frame(width: 7, height: 7)
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(Self.dateLabel(appointment.date))
                            .font(Theme.Font.display(19))
                            .foregroundStyle(Color(.textPrimary))
                        Text("\(appointment.advisorName) · \(appointment.boutique)")
                            .font(Theme.Font.mono(10.5))
                            .tracking(10.5 * 0.12)
                            .textCase(.uppercase)
                            .foregroundStyle(Color(.textMuted))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Color(.textMuted))
                }
                .cardSurface(padding: Theme.Spacing.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Spacing.screen)
    }

    // MARK: - Moments Hermès

    private var editorialSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionTitle("Moments Hermès")

            ForEach(data.editorial) { moment in
                VStack(spacing: 0) {
                    ProductImageView(
                        assets: [moment.imageAsset].compactMap { $0 },
                        cornerRadius: 0,
                        label: moment.eyebrow
                    )
                    .frame(height: 180)
                    .clipped()
                    VStack(alignment: .leading, spacing: 10) {
                        Text(moment.title)
                            .font(Theme.Font.display(22))
                            .foregroundStyle(Color(.textPrimary))
                        Text(moment.quote)
                            .font(Theme.Font.displayItalic(14, weight: .light))
                            .lineSpacing(5)
                            .foregroundStyle(Color(.textSecondary))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Spacing.lg)
                }
                .background(Color(.card))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            }
        }
        .padding(.horizontal, Theme.Spacing.screen)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        EyebrowLabel(text: text, color: Color(.textSecondary))
    }

    /// French long-form date, e.g. "Mardi 24 juin, 15h00".
    private static func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM, HH'h'mm"
        return formatter.string(from: date).prefix(1).uppercased() + formatter.string(from: date).dropFirst()
    }
}

#Preview {
    // Inject the mock client explicitly so the preview is hermetic.
    HomeScreen(
        viewModel: HomeScreen.ViewModel(
            catalogRepository: APICatalogRepository(client: MockAPIClient()),
            bookingRepository: APIBookingRepository(client: MockAPIClient()),
            profileRepository: APIProfileRepository(client: MockAPIClient())
        )
    )
    .environment(BookingCoordinator())
    .environment(ConversationCoordinator())
}
