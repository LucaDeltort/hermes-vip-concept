//
//  AsyncUIState.swift
//  hermes-vip-concept
//
//

import SwiftUI

enum AsyncUIState<ViewData: Equatable>: Equatable {
    case idle
    case loading
    case data(ViewData)
    case error(LocalizedStringKey)

    var data: ViewData? {
        if case .data(let value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}
