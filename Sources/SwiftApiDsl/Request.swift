import Foundation

public struct Request {
    public let modifiers: [RequestModifier]

    public init(_ modifiers: [RequestModifier] = []) {
        self.modifiers = modifiers
    }

    public init(_ modifiers: RequestModifier...) {
        self.init(modifiers)
    }

    public func toUrlRequest(baseUrl: URL) async throws -> URLRequest {
        var request = URLRequest(url: baseUrl)
        for modifier in modifiers { try await modifier.modify(&request) }
        return request
    }
}
