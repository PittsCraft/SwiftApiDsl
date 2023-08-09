import Foundation

public struct JsonBodyModifier<Body: Encodable>: RequestModifier {

    public let body: Body
    public let jsonEncoder: JSONEncoder

    public init(body: Body, jsonEncoder: JSONEncoder) {
        self.body = body
        self.jsonEncoder = jsonEncoder
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        let data = try jsonEncoder.encode(body)
        urlRequest.httpBody = data
    }
}
