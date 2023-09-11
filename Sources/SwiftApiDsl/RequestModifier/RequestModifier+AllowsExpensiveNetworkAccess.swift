import Foundation

public extension RequestModifier {

    static func allowsExpensiveNetworkAccess(_ allowsExpensiveNetworkAccess: Bool) -> RequestModifier {
        .init { $0.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess }
    }
}

public extension RequestModifiable {

    func allowsExpensiveNetworkAccess(_ allowsExpensiveNetworkAccess: Bool) -> Self {
        modifier(.allowsExpensiveNetworkAccess(allowsExpensiveNetworkAccess))
    }
}
