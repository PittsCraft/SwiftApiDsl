import Foundation

public struct CachePolicyModifier: RequestModifier {

    public let cachePolicy: URLRequest.CachePolicy

    public init(cachePolicy: URLRequest.CachePolicy) {
        self.cachePolicy = cachePolicy
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.cachePolicy = cachePolicy
    }
}
