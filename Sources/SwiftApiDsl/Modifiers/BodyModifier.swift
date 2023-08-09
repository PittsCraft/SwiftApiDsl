import Foundation

public struct BodyModifier: RequestModifier {

    public let body: Data

    public init(body: Data) {
        self.body = body
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.httpBody = body
    }
}
