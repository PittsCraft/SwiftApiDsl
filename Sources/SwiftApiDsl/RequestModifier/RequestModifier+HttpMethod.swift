import Foundation

public extension RequestModifier {

    static func httpMethod(_ httpMethod: HttpMethod) -> RequestModifier {
        .init { $0.httpMethod = httpMethod.rawValue }
    }
}
