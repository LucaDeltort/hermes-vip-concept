//
//  ConversationScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct ConversationScreen: View {
    @State private var viewModel: ViewModel
    var onAdvisorLoaded: ((Advisor) -> Void)?

    init(viewModel: ViewModel? = nil, onAdvisorLoaded: ((Advisor) -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
        self.onAdvisorLoaded = onAdvisorLoaded
    }

    var body: some View {
        AsyncStateView(
            state: viewModel.state,
            onRetry: { Task { await viewModel.load() } }
        ) { conversation in
            thread(conversation)
        }
        .hermesBackground()
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
        .onChange(of: viewModel.state.data?.advisor) {
            if let advisor = viewModel.state.data?.advisor {
                onAdvisorLoaded?(advisor)
            }
        }
    }

    private func thread(_ conversation: Conversation) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.md) {
                    ForEach(conversation.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(Theme.Spacing.screen)
                .padding(.top, Theme.Spacing.sm)
            }
            .onChange(of: conversation.messages.count) {
                if let last = conversation.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onAppear {
                proxy.scrollTo(conversation.messages.last?.id, anchor: .bottom)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .safeAreaInset(edge: .bottom) { composeBar }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Compose bar

    private var composeBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            TextField("", text: $viewModel.draft, prompt: Text("Votre message"), axis: .vertical)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1...4)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(
                    Color(.inputSurface),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.input)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.input)
                        .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                )

            Button {
                Task { await viewModel.send() }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(.backgroundBase))
                    .frame(width: 40, height: 40)
                    .background(
                        Color(.accent).opacity(viewModel.canSend ? 1 : 0.35),
                        in: Circle()
                    )
            }
            .disabled(!viewModel.canSend)
        }
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.xs)
        .background(Color(.backgroundBase).opacity(0.92))
    }
}

// MARK: - Message bubble

private struct MessageBubble: View {
    let message: Message

    private var isOutgoing: Bool { message.sender == .member }

    var body: some View {
        HStack {
            if isOutgoing { Spacer(minLength: Theme.Spacing.xl) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(Theme.Font.body(15))
                        .foregroundStyle(Color(.textPrimary))
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(bubbleColor, in: bubbleShape)
                        .overlay(
                            bubbleShape
                                .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                        )
                }
                if let product = message.product {
                    ProductCardBubble(product: product)
                }
                Text(timestamp)
                    .font(Theme.Font.mono(9))
                    .foregroundStyle(Color(.textMuted))
            }

            if !isOutgoing { Spacer(minLength: Theme.Spacing.xl) }
        }
    }

    private var bubbleColor: Color {
        isOutgoing ? Color(.accent).opacity(0.15) : Color(.card)
    }

    /// 18pt rounded with the inner corner squared (bottom-trailing for outgoing,
    /// bottom-leading for incoming) — the mockup's bubble silhouette.
    private var bubbleShape: UnevenRoundedRectangle {
        let r = Theme.Radius.bubble
        let squared: CGFloat = 4
        return UnevenRoundedRectangle(
            topLeadingRadius: r,
            bottomLeadingRadius: isOutgoing ? r : squared,
            bottomTrailingRadius: isOutgoing ? squared : r,
            topTrailingRadius: r
        )
    }

    private var timestamp: String {
        message.timestamp.formatted(.dateTime.hour().minute().locale(.maison))
    }
}

// MARK: - Product card bubble

/// A product the advisor attached to the thread, shown as a tappable card that
/// pushes the detail screen (mirrors the chat card in the mockup).
private struct ProductCardBubble: View {
    let product: Product

    var body: some View {
        NavigationLink(value: AppRoute.productDetail(productID: product.id)) {
            VStack(spacing: 0) {
                ProductImageView(
                    assets: product.imageAssets,
                    cornerRadius: 4,
                    label: product.category
                )
                .frame(height: 150)

                HStack(alignment: .center, spacing: Theme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(Theme.Font.display(16))
                            .foregroundStyle(Color(.textPrimary))
                        EyebrowLabel(text: product.category, color: Color(.textSecondary), size: 10)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.textMuted))
                }
                .padding(.horizontal, 6)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, 4)
            }
            .padding(10)
            .frame(width: 240)
            .background(Color(.inputSurface), in: RoundedRectangle(cornerRadius: Theme.Radius.bubble))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.bubble)
                    .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConversationScreen(
        viewModel: ConversationScreen.ViewModel(
            repository: APIConversationRepository(client: MockAPIClient())
        )
    )
    .preferredColorScheme(.dark)
}
