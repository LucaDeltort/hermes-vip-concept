//
//  ConversationViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension ConversationScreen {
    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let repository: ConversationRepository

        var state: AsyncUIState<Conversation> = .idle
        var draft: String = ""
        var isSending = false

        init(repository: ConversationRepository? = nil) {
            self.repository = repository ?? AppContainer.shared.conversationRepository()
        }

        var canSend: Bool {
            !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
        }

        func load() async {
            state = .loading
            do {
                let conversation = try await repository.conversation()
                state = .data(conversation)
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }

        func send() async {
            let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty, !isSending else { return }
            isSending = true
            draft = ""
            defer { isSending = false }
            do {
                let updated = try await repository.send(text: text)
                state = .data(updated)
            } catch {
                // Restore the draft so the member doesn't lose their message.
                draft = text
            }
        }
    }
}
