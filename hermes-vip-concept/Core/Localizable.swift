//
//  Localizable.swift
//  hermes-vip-concept
//
//

import Foundation

enum Localizable {
    enum Global {
        static let somethingWentWrong = String(localized: "Une erreur est survenue. Veuillez réessayer.")
        static let retry = String(localized: "Réessayer")
        static let networkFailed = String(localized: "La connexion à la maison a échoué. Veuillez réessayer.")
    }

    enum Invitation {
        static let title = String(localized: "Sur invitation")
        static let enter = String(localized: "Entrer")
        static let codeRejected = String(localized: "Ce code d'invitation n'est pas reconnu.")
    }
}
