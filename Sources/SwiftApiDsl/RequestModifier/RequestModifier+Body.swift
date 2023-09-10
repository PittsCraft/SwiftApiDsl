import Foundation

public extension RequestModifier {

    static func body(_ data: Data) -> RequestModifier {
        .init { $0.httpBody = data }
    }

    func body(_ data: Data) -> RequestModifier {
        compose(with: .body(data))
    }
}
