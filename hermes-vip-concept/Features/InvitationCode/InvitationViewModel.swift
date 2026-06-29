//
//  InvitationViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension InvitationScreen {
    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let repository: InvitationRepository

        var code: String = ""
        var isLoading = false
        /// Non-nil when validation failed or the code was rejected.
        var errorMessage: LocalizedStringKey?

        var canSubmit: Bool { !code.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading }

        init(repository: InvitationRepository? = nil) {
            self.repository = repository ?? AppContainer.shared.invitationRepository()
        }

        /// Validate the entered code, calling `onSuccess` when accepted.
        func submit(onSuccess: @escaping () -> Void) async {
            guard canSubmit else { return }
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                let result = try await repository.validate(code: code)
                if result.isValid {
                    onSuccess()
                } else {
                    errorMessage = "Ce code d'invitation n'est pas reconnu."
                }
            } catch let error as RepositoryError {
                errorMessage = LocalizedStringKey(error.localizedDescription)
            } catch {
                errorMessage = "Une erreur est survenue."
            }
        }
    }
}
