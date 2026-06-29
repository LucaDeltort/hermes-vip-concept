//
//  PiecesScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct PiecesScreen: View {
    @Environment(BookingCoordinator.self) private var booking
    @State private var viewModel: ViewModel
    @State private var tab: CollectionTab = .wishlist

    init(viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    /// The two segments of the Collection screen.
    enum CollectionTab: CaseIterable, Hashable {
        case wishlist, owned

        var title: String {
            switch self {
            case .wishlist: return "Wishlist"
            case .owned: return "Ma collection"
            }
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    EyebrowLabel(text: "Collection")
                    Text("Vos pièces")
                        .font(Theme.Font.display(32, weight: .light))
                        .foregroundStyle(Color(.textPrimary))
                }

                SegmentedControl(selection: $tab)

                AsyncStateView(
                    state: viewModel.state,
                    skeletonData: Self.skeleton,
                    onRetry: { Task { await viewModel.load() } }
                ) { data in
                    switch tab {
                    case .wishlist: wishlistGrid(data.wishlist)
                    case .owned: ownedGrid(data.owned)
                    }
                }
            }
            .padding(Theme.Spacing.screen)
        }
        .hermesBackground()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { bookingBar }
        .refreshable { await viewModel.load() }
        .onReceive(NotificationCenter.default.publisher(for: .catalogFavoritesDidChange)) { _ in
            Task { await viewModel.load() }
        }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
    }

    /// Sample used as the redacted loading skeleton.
    static let skeleton = ViewData(
        wishlist: Product.samples,
        owned: OwnedPiece.samples
    )

    // MARK: - Booking CTA

    @ViewBuilder
    private var bookingBar: some View {
        if tab == .wishlist, let wishlist = viewModel.state.data?.wishlist, !wishlist.isEmpty {
            Button {
                booking.present(for: wishlist)
            } label: {
                Text("Prendre rendez-vous")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.top, Theme.Spacing.sm)
            .padding(.bottom, Theme.Spacing.xs)
            .background(Color(.backgroundBase).opacity(0.92))
        }
    }

    // MARK: - Grids

    @ViewBuilder
    private func wishlistGrid(_ products: [Product]) -> some View {
        if products.isEmpty {
            emptyState(
                icon: "heart",
                message: "Vous n'avez pas encore de pièce en favori."
            )
        } else {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                ForEach(products) { product in
                    NavigationLink(value: AppRoute.productDetail(productID: product.id)) {
                        WishlistCell(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func ownedGrid(_ pieces: [OwnedPiece]) -> some View {
        if pieces.isEmpty {
            emptyState(
                icon: "square.grid.2x2",
                message: "Votre collection est encore vide."
            )
        } else {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                ForEach(pieces) { piece in
                    OwnedCell(piece: piece)
                }
            }
        }
    }

    private func emptyState(icon: String, message: String) -> some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(Color(.gold))
            Text(message)
                .font(Theme.Font.body(14))
                .foregroundStyle(Color(.textMuted))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Theme.Spacing.xxl)
    }
}

// MARK: - Segmented control

private struct SegmentedControl: View {
    @Binding var selection: PiecesScreen.CollectionTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PiecesScreen.CollectionTab.allCases, id: \.self) { segment in
                let isSelected = selection == segment
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { selection = segment }
                } label: {
                    Text(segment.title.uppercased())
                        .font(Theme.Font.mono(11, weight: .medium))
                        .tracking(Theme.Tracking.wide(11))
                        .foregroundStyle(isSelected ? Color(.backgroundBase) : Color(.textSecondary))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(isSelected ? Color(.accent) : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.inputSurface), in: Capsule())
        .overlay(Capsule().strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth))
    }
}

// MARK: - Cells

/// A Wishlist cell: thumbnail and name (favorited curated product).
private struct WishlistCell: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            ProductImageView(assets: product.imageAssets, label: product.category)
                .aspectRatio(1, contentMode: .fit)
            Text(product.name)
                .font(Theme.Font.display(15))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1)
        }
    }
}

/// A Ma-collection cell: thumbnail, name, métier and year — no price, no favorite.
private struct OwnedCell: View {
    let piece: OwnedPiece

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            ProductImageView(assets: piece.imageAssets, label: piece.category)
                .aspectRatio(1, contentMode: .fit)
            Text(piece.name)
                .font(Theme.Font.display(15))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1)
            EyebrowLabel(text: "\(piece.category) · \(piece.year)", color: Color(.textMuted), size: 9)
        }
    }
}

#Preview {
    NavigationStack {
        PiecesScreen(
            viewModel: PiecesScreen.ViewModel(
                catalogRepository: APICatalogRepository(client: MockAPIClient())
            )
        )
    }
    .environment(BookingCoordinator())
    .preferredColorScheme(.dark)
}
