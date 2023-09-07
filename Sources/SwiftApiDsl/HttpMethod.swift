import Foundation

/// Struct encapsulating HTTP method
public struct HttpMethod {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension HttpMethod {
    static let get = HttpMethod("GET")
    static let post = HttpMethod("POST")
    static let put = HttpMethod("PUT")
    static let patch = HttpMethod("PATCH")
    static let delete = HttpMethod("DELETE")
    static let head = HttpMethod("HEAD")
    static let options = HttpMethod("OPTIONS")
}
