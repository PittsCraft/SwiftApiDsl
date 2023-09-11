import Foundation

public extension RequestModifier {

    static func timeoutInterval(_ timeoutInterval: TimeInterval) -> RequestModifier {
        .init { $0.timeoutInterval = timeoutInterval }
    }
}

public extension RequestModifiable {

    func timeoutInterval(_ timeoutInterval: TimeInterval) -> Self {
        modifier(.timeoutInterval(timeoutInterval))
    }
}
