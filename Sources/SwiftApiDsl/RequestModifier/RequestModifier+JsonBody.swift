import Foundation

public extension RequestModifier {

    static func jsonBody<Body: Encodable>(body: Body, jsonEncoder: JSONEncoder) -> RequestModifier {
        .init {
            let data = try jsonEncoder.encode(body)
            $0.httpBody = data
            $0.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
