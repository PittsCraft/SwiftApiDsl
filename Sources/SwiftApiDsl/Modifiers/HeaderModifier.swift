import Foundation

public struct HeaderModifier: RequestModifier {

    public let value: String?
    public let headerField: String

    public init(value: String?, headerField: String) {
        self.value = value
        self.headerField = headerField
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.setValue(value, forHTTPHeaderField: headerField)
    }
}
