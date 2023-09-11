import Foundation

public extension RequestModifier {

    static func body(_ data: Data) -> RequestModifier {
        .init { $0.httpBody = data }
    }
}

public extension RequestModifier {

    func body(_ data: Data) -> Self {
        modifier(.body(data))
    }
}
