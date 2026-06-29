//
//  ProductDetailScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct ProductDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BookingCoordinator.self) private var booking
    @State private var viewModel: ViewModel

    init(productID: String, viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel(productID: productID))
    }

    var body: some View {
        ScrollView {
            AsyncStateView(
                state: viewModel.state,
                skeletonData: .sample,
                onRetry: { Task { await viewModel.load() } }
            ) { product in
                ProductDetailContent(
                    product: product,
                    isToggling: viewModel.isTogglingFavorite,
                    onToggleFavorite: { Task { await viewModel.toggleFavorite() } },
                    onBack: { dismiss() }
                )
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .hermesBackground()
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            if let product = viewModel.state.data {
                Button {
                    booking.present(for: [product])
                } label: {
                    Text("Voir en boutique")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Theme.Spacing.screen)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, Theme.Spacing.xs)
                .background(Color(.backgroundBase).opacity(0.92))
            }
        }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
    }
}

/// Pure presentational body for the product detail screen.
private struct ProductDetailContent: View {
    let product: Product
    let isToggling: Bool
    let onToggleFavorite: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            hero

            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(spacing: Theme.Spacing.sm) {
                        EyebrowLabel(text: product.category)
                        if let badge = product.badge {
                            ProductBadgeTag(badge: badge)
                        }
                    }
                    Text(product.name)
                        .font(Theme.Font.display(30, weight: .light))
                        .foregroundStyle(Color(.textPrimary))
                }

                Text(product.description)
                    .font(Theme.Font.body(15))
                    .foregroundStyle(Color(.textSecondary))
                    .lineSpacing(4)

                specs

                if let note = product.advisorNote {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        EyebrowLabel(text: "Le mot de votre conseillère")
                        Text("« \(note) »")
                            .font(Theme.Font.displayItalic(16))
                            .foregroundStyle(Color(.gold))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardSurface()
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.bottom, Theme.Spacing.screen)
        }
    }

    /// Matière / Couleur spec rows, separated by hairlines.
    private var specs: some View {
        VStack(spacing: 0) {
            specRow(label: "Matière", value: product.material)
            Divider().overlay(Color(.hairline))
            specRow(label: "Couleur", value: product.color)
        }
    }

    private func specRow(label: String, value: String) -> some View {
        HStack {
            EyebrowLabel(text: label, color: Color(.textMuted), size: 10)
            Spacer(minLength: Theme.Spacing.md)
            Text(value)
                .font(Theme.Font.body(14))
                .foregroundStyle(Color(.textPrimary))
        }
        .padding(.vertical, Theme.Spacing.sm)
    }

    private static let heroHeight: CGFloat = 480

    /// Full-bleed product hero with the back and favorite controls overlaid.
    /// Stretches to cover any overscroll gap so the background never shows above it.
    private var hero: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .scrollView(axis: .vertical)).minY
            let stretch = max(0, minY)
            heroImage
                .frame(width: geo.size.width, height: Self.heroHeight + stretch)
                .clipped()
                .offset(y: -stretch)
        }
        .frame(height: Self.heroHeight)
    }

    private var heroImage: some View {
        ProductImageView(
            assets: product.imageAssets,
            cornerRadius: 0,
            label: "Produit · \(product.category)"
        )
            .overlay(alignment: .topLeading) {
                circleControl(systemImage: "chevron.left", action: onBack)
                    .accessibilityLabel("Retour")
            }
            .overlay(alignment: .topTrailing) {
                Group {
                    if isToggling {
                        ProgressView().tint(Color(.accent))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                            .padding(.top, 54)
                            .padding(.horizontal, Theme.Spacing.screen)
                    } else {
                        circleControl(
                            systemImage: product.isFavorite ? "heart.fill" : "heart",
                            tint: Color(.accent),
                            action: onToggleFavorite
                        )
                    }
                }
                .accessibilityLabel(product.isFavorite ? "Retirer de ma wishlist" : "Enregistrer")
            }
    }

    /// A 40pt glass circle button used for the hero overlay controls.
    private func circleControl(
        systemImage: String,
        tint: Color = Color(.textPrimary),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
        .padding(.top, 54)
        .padding(.horizontal, Theme.Spacing.screen)
    }
}

#Preview {
    NavigationStack {
        ProductDetailScreen(
            productID: Product.sample.id,
            viewModel: ProductDetailScreen.ViewModel(
                productID: Product.sample.id,
                catalogRepository: APICatalogRepository(client: MockAPIClient())
            )
        )
    }
    .environment(BookingCoordinator())
    .preferredColorScheme(.dark)
}
