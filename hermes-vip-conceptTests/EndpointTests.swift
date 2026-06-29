//
//  EndpointTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

final class EndpointTests: XCTestCase {

    func testProductEndpointPath() {
        let endpoint = Endpoint.Catalog.product(id: "prd-001")
        XCTAssertEqual(endpoint.path, "catalog/products/prd-001")
        XCTAssertEqual(endpoint.method, .get)
    }

    func testToggleFavoriteIsPut() {
        let endpoint = Endpoint.Catalog.toggleFavorite(id: "prd-001")
        XCTAssertEqual(endpoint.path, "catalog/products/prd-001/favorite")
        XCTAssertEqual(endpoint.method, .put)
    }

    func testValidateEndpointEncodesBody() throws {
        let endpoint = Endpoint.Invitation.validate(code: "HERMES")
        XCTAssertEqual(endpoint.method, .post)
        let body = try XCTUnwrap(endpoint.body)
        let decoded = try JSONDecoder.api.decode([String: String].self, from: body)
        XCTAssertEqual(decoded["code"], "HERMES")
    }

    func testSlotsEndpointHasMonthQuery() {
        let endpoint = Endpoint.Booking.slots(month: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(endpoint.path, "booking/slots")
        XCTAssertEqual(endpoint.queryItems.first?.name, "month")
        XCTAssertNotNil(endpoint.queryItems.first?.value)
    }

    func testURLRequestBuildsAbsoluteURL() throws {
        let endpoint = Endpoint.Catalog.product(id: "x")
        let request = try XCTUnwrap(endpoint.urlRequest(baseURL: APIConfig.baseURL))
        XCTAssertEqual(request.url?.path, "/v1/catalog/products/x")
    }
}
