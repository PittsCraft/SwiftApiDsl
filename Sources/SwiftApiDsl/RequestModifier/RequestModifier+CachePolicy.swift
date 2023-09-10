import Foundation

public extension RequestModifier {

    static func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> RequestModifier {
        .init { $0.cachePolicy = cachePolicy }
    }

    func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> RequestModifier {
        compose(with: .cachePolicy(cachePolicy))
    }
}
