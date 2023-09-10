import Foundation

public extension RequestModifier {

    static func timeoutInterval(_ timeoutInterval: TimeInterval) -> RequestModifier {
        .init { $0.timeoutInterval = timeoutInterval }
    }

    func timeoutInterval(_ timeoutInterval: TimeInterval) -> RequestModifier {
        compose(with: .timeoutInterval(timeoutInterval))
    }
}
