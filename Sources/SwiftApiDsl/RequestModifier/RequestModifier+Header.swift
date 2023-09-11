import Foundation

public extension RequestModifier {

    static func header(value: String?, headerField: String) -> RequestModifier {
        .init { $0.setValue(value, forHTTPHeaderField: headerField) }
    }
}

public extension RequestModifiable {

    func header(value: String?, headerField: String) -> Self {
        modifier(.header(value: value, headerField: headerField))
    }
}
