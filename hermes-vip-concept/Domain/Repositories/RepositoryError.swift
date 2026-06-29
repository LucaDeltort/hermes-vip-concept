//
//  RepositoryError.swift
//  hermes-vip-concept
//
//

import Foundation

/// Errors a repository may throw, translated by view models into a
/// user-facing `AsyncUIState.error`.
enum RepositoryError: Error, Equatable {
    case network
    case decoding
    case notFound
    case resourceMissing(String)
}

extension RepositoryError {
    var localizedDescription: String {
        switch self {
        case .network:
            return "La connexion à la maison a échoué. Veuillez réessayer."
        case .decoding, .resourceMissing:
            return "Une erreur est survenue. Veuillez réessayer."
        case .notFound:
            return "Élément introuvable."
        }
    }
}
