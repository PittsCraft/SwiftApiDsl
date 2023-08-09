import Foundation

public struct HttpMethodModifier: RequestModifier {

    public let httpMethod: HttpMethod

    public init(httpMethod: HttpMethod) {
        self.httpMethod = httpMethod
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.httpMethod = httpMethod.rawValue
    }
}
