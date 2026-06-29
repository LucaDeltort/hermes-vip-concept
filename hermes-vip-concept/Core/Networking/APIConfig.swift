//
//  APIConfig.swift
//  hermes-vip-concept
//
//

import Foundation

enum APIConfig {
    /// Base URL for the live client.
    static let baseURL = URL(string: "https://api.hermes-vip.example.com/v1")!

    /// Mock transport tuning.
    enum Mock {
        /// Lower/upper bound of simulated latency, in seconds.
        static let latencyRange: ClosedRange<Double> = 0.35...0.9

        /// Probability (0...1) that any given request fails with `.transport`.
        /// Set to 0 for deterministic demos; non-zero to exercise error states.
        static let failureRate: Double = 0.0
    }
}
