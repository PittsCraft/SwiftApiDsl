import Foundation

public extension RequestModifier {

    static func header(value: String?, field: String) -> RequestModifier {
        .init { $0.setValue(value, forHTTPHeaderField: field) }
    }
}

public extension RequestModifiable {

    func header(value: String?, field: String) -> Self {
        modifier(.header(value: value, field: field))
    }
}
