import Foundation

/// Struct encapsulating HTTP method
public struct HttpMethod {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension HttpMethod {
    static let get = HttpMethod(rawValue: "GET")
    static let post = HttpMethod(rawValue: "POST")
    static let put = HttpMethod(rawValue: "PUT")
    static let patch = HttpMethod(rawValue: "PATCH")
    static let delete = HttpMethod(rawValue: "DELETE")
}
