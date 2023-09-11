import Foundation

public extension RequestModifier {

    static func body(_ data: Data) -> RequestModifier {
        .init { $0.httpBody = data }
    }
}

public extension RequestModifiable {

    func body(_ data: Data) -> Self {
        modifier(.body(data))
    }
}
