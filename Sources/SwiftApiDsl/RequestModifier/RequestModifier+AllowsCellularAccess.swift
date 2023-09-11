import Foundation

public extension RequestModifier {

    static func allowsCellularAccess(_ allowsCellularAccess: Bool) -> RequestModifier {
        .init { $0.allowsCellularAccess = allowsCellularAccess }
    }
}

public extension RequestModifiable {

    func allowsCellularAccess(_ allowsCellularAccess: Bool) -> Self {
        modifier(.allowsCellularAccess(allowsCellularAccess))
    }
}
