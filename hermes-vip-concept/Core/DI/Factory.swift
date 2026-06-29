//
//  Factory.swift
//  hermes-vip-concept
//
//

import Foundation

/// A lazily-resolved registration for a dependency of type `T`.
///
/// Resolve by calling it: `let client = AppContainer.shared.apiClient()`.
/// Replace for tests/previews: `AppContainer.shared.apiClient.register { Stub() }`.
@MainActor
final class Factory<T> {
    private let base: () -> T
    private var override: (() -> T)?
    private var cached: T?
    private var isSingleton = false

    init(_ base: @escaping () -> T) {
        self.base = base
    }

    /// Mark this registration as a process-wide singleton (one shared instance).
    @discardableResult
    func singleton() -> Factory<T> {
        isSingleton = true
        return self
    }

    /// Resolve the dependency, honouring overrides and singleton caching.
    func callAsFunction() -> T {
        if let cached { return cached }
        let value = (override ?? base)()
        if isSingleton { cached = value }
        return value
    }

    /// Override the registration (tests/previews inject stubs/mocks here).
    func register(_ factory: @escaping () -> T) {
        override = factory
        cached = nil
    }

    /// Remove any override and drop the singleton cache.
    func reset() {
        override = nil
        cached = nil
    }
}
