//
//  Product.swift
//  hermes-vip-concept
//
//

import Foundation

/// A merchandising badge highlighted on a product.
nonisolated enum ProductBadge: String, Codable, Hashable, Sendable {
    case preview

    var label: String {
        switch self {
        case .preview: "Avant-première"
        }
    }
}

/// A maison product, shown in the curated home grid and on the detail screen.
nonisolated struct Product: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let material: String
    let color: String
    let description: String
    let advisorNote: String?
    let badge: ProductBadge?
    /// Gallery asset names; nil/empty falls back to the leather placeholder.
    let imageAssets: [String]
    let isFavorite: Bool

    init(
        id: String,
        name: String,
        category: String,
        material: String,
        color: String,
        description: String,
        advisorNote: String?,
        badge: ProductBadge? = nil,
        imageAssets: [String],
        isFavorite: Bool
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.material = material
        self.color = color
        self.description = description
        self.advisorNote = advisorNote
        self.badge = badge
        self.imageAssets = imageAssets
        self.isFavorite = isFavorite
    }
}

nonisolated extension Product {
    static let sample = samples[0]

    static let samples: [Product] = [
        Product(
            id: "prd-001",
            name: "Sac Hermès Geta",
            category: "Maroquinerie",
            material: "Veau Togo",
            color: "Orange",
            description:
                "Une silhouette structurée en veau Togo, rehaussée du fermoir "
                + "signature de la maison. Le format idéal pour accompagner vos "
                + "journées d'été.",
            advisorNote: "Un format idéal pour l'été, il complète votre Roulis.",
            imageAssets: ["geta-0"],
            isFavorite: true
        ),
        Product(
            id: "prd-002",
            name: "Carré 90 Grand Galop",
            category: "Soie",
            material: "Twill de soie",
            color: "Bleu",
            description:
                "Le motif équestre emblématique de la maison, imprimé sur twill "
                + "de soie et roulotté à la main.",
            advisorNote: "Le motif équestre signature, parfait avec votre garde-robe.",
            imageAssets: ["carre-90-grand-galop-0"],
            isFavorite: false
        ),
        Product(
            id: "prd-003",
            name: "Sac Faubourg Express",
            category: "Maroquinerie",
            material: "Veau Swift",
            color: "Beige/Naturel",
            description:
                "Notre nouveau format voyage en veau Swift — léger, élégant, "
                + "pensé pour les escapades.",
            advisorNote: "Notre nouveauté, un format voyage élégant.",
            imageAssets: ["faubourg-express-0"],
            isFavorite: false
        ),
        Product(
            id: "prd-004",
            name: "Bracelet Clic Clou de Selle",
            category: "Bijouterie fantaisie",
            material: "Émail/Palladium",
            color: "Orange",
            description:
                "Émail et palladium réinterprètent le clou de selle, icône du "
                + "vocabulaire équestre Hermès.",
            advisorNote: "Se porte seul ou en accumulation avec votre Clic H.",
            imageAssets: ["bracelet-clic-clou-de-selle-0"],
            isFavorite: false
        ),
        Product(
            id: "prd-005",
            name: "Sandales Izmir",
            category: "Chaussures",
            material: "Veau",
            color: "Naturel",
            description:
                "La sandale incontournable en veau naturel, façonnée pour la "
                + "belle saison.",
            advisorNote: "Incontournables pour la saison.",
            imageAssets: ["sandales-izmir-0"],
            isFavorite: true
        ),
        Product(
            id: "prd-009",
            name: "Apple Watch Hermès Series 11",
            category: "Horlogerie",
            material: "Bracelet Simple Tour Kilim",
            color: "Orange",
            description:
                "Boîtier 46 mm en acier, animé du cadran Hermès Paris. Le "
                + "bracelet Simple Tour Kilim en caoutchouc orange, à boucle "
                + "déployante, signe une allure sportive et raffinée.",
            advisorNote: "L'alliance du savoir-faire Hermès et de la technologie.",
            imageAssets: [
                "boitier-series11-bracelet-apple-watch-hermes-simple-tour-46mm-boucle-deployante-kilim-0"
            ],
            isFavorite: false
        ),

        // MARK: Avant-premières — early-access drops (badge `.preview`).

        Product(
            id: "prd-006",
            name: "Carré 140 Le Pégase d'Hermès",
            category: "Soie",
            material: "Twill de soie plissé",
            color: "Bleu",
            description:
                "Un grand carré 140 en twill de soie plissé, où Pégase déploie "
                + "ses ailes.",
            advisorNote: nil,
            badge: .preview,
            imageAssets: ["carre-140-le-pegase-d-hermes-0"],
            isFavorite: false
        ),
        Product(
            id: "prd-007",
            name: "Sac Hermès Della Cavalleria Élan",
            category: "Maroquinerie",
            material: "Veau Swift",
            color: "Blanc",
            description:
                "Une ligne épurée en veau Swift blanc, héritière de l'art "
                + "équestre de la maison.",
            advisorNote: nil,
            badge: .preview,
            imageAssets: ["sac-hermes-della-cavalleria-elan-0"],
            isFavorite: false
        ),
        Product(
            id: "prd-008",
            name: "Carré 90 brodé Cavalier en Formes",
            category: "Soie",
            material: "Twill de soie brodé",
            color: "Multicolore",
            description:
                "Le savoir-faire de la broderie sublime ce carré 90, pièce "
                + "d'exception multicolore.",
            advisorNote: nil,
            badge: .preview,
            imageAssets: ["carre-90-brode-cavalier-en-formes-0"],
            isFavorite: false
        )
    ]
}
