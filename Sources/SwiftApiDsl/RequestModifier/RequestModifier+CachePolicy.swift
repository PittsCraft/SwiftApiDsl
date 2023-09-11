import Foundation

public extension RequestModifier {

    static func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> RequestModifier {
        .init { $0.cachePolicy = cachePolicy }
    }
}

public extension RequestModifiable {

    func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> Self {
        modifier(.cachePolicy(cachePolicy))
    }
}
