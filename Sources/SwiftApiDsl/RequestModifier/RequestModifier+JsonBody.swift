import Foundation

public extension RequestModifier {

    static func jsonBody<Body: Encodable>(body: Body, jsonEncoder: JSONEncoder) -> RequestModifier {
        .init {
            let data = try jsonEncoder.encode(body)
            $0.httpBody = data
        }
    }

    func jsonBody<Body: Encodable>(body: Body, jsonEncoder: JSONEncoder) -> RequestModifier {
        compose(with: .jsonBody(body: body, jsonEncoder: jsonEncoder))
    }
}
