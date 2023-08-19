import XCTest
@testable import SwiftApiDsl

final class ApiClientTests: XCTestCase {
    let url = URL(string: "https://google.com")!

    @MainActor
    func test_modify_applies_default_modifiers_when_ignoreDefaultModifiers_false() async throws {
        let httpMethod = "EXPECTED"
        let modifier = BlockModifier {
            $0.httpMethod = httpMethod
        }
        let client = ApiClient(baseUrl: url, modifiers: [modifier])
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        try await client.modify(request: &urlRequest, extraModifiers: [], ignoreDefaultModifiers: false)
        XCTAssertEqual(urlRequest.httpMethod, httpMethod)
    }

    @MainActor
    func test_modify_doesnt_apply_default_modifiers_when_ignoreDefaultModifiers_true() async throws {
        let expectedHttpMethod = "EXPECTED"
        let modifier = BlockModifier {
            $0.httpMethod = "NOT_EXPECTED"
        }
        let client = ApiClient(baseUrl: url, modifiers: [modifier])
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        urlRequest.httpMethod = expectedHttpMethod
        try await client.modify(request: &urlRequest, extraModifiers: [], ignoreDefaultModifiers: true)
        XCTAssertEqual(urlRequest.httpMethod, expectedHttpMethod)
    }

    @MainActor
    func test_modify_applies_extra_modifiers_when_ignoreDefaultModifiers_false() async throws {
        let httpMethod = "EXPECTED"
        let modifier = BlockModifier {
            $0.httpMethod = httpMethod
        }
        let client = ApiClient(baseUrl: url)
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        try await client.modify(request: &urlRequest, extraModifiers: [modifier], ignoreDefaultModifiers: false)
        XCTAssertEqual(urlRequest.httpMethod, httpMethod)
    }

    @MainActor
    func test_modify_applies_extra_modifiers_when_ignoreDefaultModifiers_true() async throws {
        let httpMethod = "EXPECTED"
        let modifier = BlockModifier {
            $0.httpMethod = httpMethod
        }
        let client = ApiClient(baseUrl: url)
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        try await client.modify(request: &urlRequest, extraModifiers: [modifier], ignoreDefaultModifiers: true)
        XCTAssertEqual(urlRequest.httpMethod, httpMethod)
    }

    struct TestError: Error, Equatable {}

    @MainActor
    func test_modify_wraps_default_modifier_error() async throws {
        let modifier = BlockModifier { _ in
            throw TestError()
        }
        let client = ApiClient(baseUrl: url, modifiers: [modifier])
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        do {
            try await client.modify(request: &urlRequest, extraModifiers: [], ignoreDefaultModifiers: false)
            XCTFail("Expected modify to throw")
        } catch {
            let requestError = try XCTUnwrap(error as? RequestError, "Thrown error should be a RequestError")
            if case .requestModifierError(let wrapped) = requestError.error {
                _ = try XCTUnwrap(wrapped as? TestError, "Expected error to be equal to the one thrown by the modifier")
            } else {
                XCTFail("Expected wrapped error to be case requestModifierError")
            }
        }
    }

    @MainActor
    func test_modify_wraps_extra_modifier_error() async throws {
        let modifier = BlockModifier { _ in
            throw TestError()
        }
        let client = ApiClient(baseUrl: url)
        let request = Request()
        var urlRequest = try await request.toUrlRequest(baseUrl: url)
        do {
            try await client.modify(request: &urlRequest, extraModifiers: [modifier], ignoreDefaultModifiers: false)
            XCTFail("Expected modify to throw")
        } catch {
            let requestError = try XCTUnwrap(error as? RequestError, "Thrown error should be a RequestError")
            if case .requestModifierError(let wrapped) = requestError.error {
                _ = try XCTUnwrap(wrapped as? TestError, "Expected error to be equal to the one thrown by the modifier")
            } else {
                XCTFail("Expected wrapped error to be case requestModifierError")
            }
        }
    }
}
