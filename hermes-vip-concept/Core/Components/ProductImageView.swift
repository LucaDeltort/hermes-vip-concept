//
//  ProductImageView.swift
//  hermes-vip-concept
//
//

import SwiftUI
import UIKit

/// Resolves and caches bundled product images by filename.
enum ProductImageStore {
    /// filename-stem → bundle URL, built once by scanning the bundle resources.
    private static let index: [String: URL] = {
        guard let resourceURL = Bundle.main.resourceURL else { return [:] }
        let extensions: Set<String> = ["webp", "jpg", "jpeg", "png", "heic"]
        var map: [String: URL] = [:]
        let enumerator = FileManager.default.enumerator(
            at: resourceURL,
            includingPropertiesForKeys: nil
        )
        while let url = enumerator?.nextObject() as? URL {
            guard extensions.contains(url.pathExtension.lowercased()) else { continue }
            map[url.deletingPathExtension().lastPathComponent] = url
        }
        return map
    }()

    private static var cache: [String: UIImage] = [:]

    /// Load the image for an asset reference (accepts a bare stem, a filename, or
    /// a full path — only the filename stem is used to look it up).
    static func image(for asset: String) -> UIImage? {
        let stem = ((asset as NSString).lastPathComponent as NSString).deletingPathExtension
        guard !stem.isEmpty else { return nil }
        if let cached = cache[stem] { return cached }
        guard let url = index[stem], let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        cache[stem] = image
        return image
    }
}

/// A bundled product image that fills its frame, falling back to the leather
/// placeholder (optionally captioned) when no matching asset exists.
struct ProductImageView: View {
    let assets: [String]
    var cornerRadius: CGFloat = Theme.Radius.card
    /// Caption shown on the placeholder fallback (mirrors `LeatherPlaceholder`).
    var label: String?

    var body: some View {
        if let image = assets.lazy.compactMap(ProductImageStore.image(for:)).first {
            // `Color.clear` adopts the proposed size exactly; the image fills it
            // via overlay so `scaledToFill`'s oversized intrinsic can't push the
            // frame wider than the container (which clipped content past the edges).
            Color.clear
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            LeatherPlaceholder(cornerRadius: cornerRadius, label: label)
        }
    }
}
