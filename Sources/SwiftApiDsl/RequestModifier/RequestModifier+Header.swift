import Foundation

public extension RequestModifier {

    static func header(value: String?, headerField: String) -> RequestModifier {
        .init { $0.setValue(value, forHTTPHeaderField: headerField) }
    }

    func header(value: String?, headerField: String) -> RequestModifier {
        compose(with: .header(value: value, headerField: headerField))
    }
}
