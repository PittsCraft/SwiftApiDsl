import Foundation

public extension RequestModifier {

    static func header(field: String, _ value: String?) -> RequestModifier {
        .init { $0.setValue(value, forHTTPHeaderField: field) }
    }

    static func header(_ field: HeaderField, _ value: String?) -> RequestModifier {
        header(field: field.rawValue, value)
    }

    enum HeaderField: String {
        case accept = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case authorization = "Authorization"
        case cacheControl = "Cache-Control"
        case contentLength = "Content-Length"
        case contentType = "Content-Type"
        case contentEncoding = "Content-Encoding"
        case contentLanguage = "Content-Language"
        case contentLocation = "Content-Location"
        case cookie = "Cookie"
        case pragma = "Pragma"
        case proxyAuthorization = "Proxy-Authorization"
        case userAgent = "User-Agent"
    }

    enum AuthorizationScheme: String {
        case basic = "Basic"
        case bearer = "Bearer"
        case digest = "Digest"
        case hoba = "HOBA"
        case mutual = "Mutual"
        case aws4HmacSha256 = "AWS4-HMAC-SHA256"
    }

    static func accept(_ value: String?) -> RequestModifier {
        header(.accept, value)
    }

    static func authorization(_ value: String?) -> RequestModifier {
        header(.authorization, value)
    }

    static func authorization(_ scheme: AuthorizationScheme, _ value: String?) -> RequestModifier {
        authorization(value.map { "\(scheme.rawValue) \($0)" })
    }

    static func basic(userId: String, password: String) -> RequestModifier {
        authorization(.basic, "\(userId):\(password)".data(using: .utf8)?.base64EncodedString())
    }

    static func bearer(_ token: String?) -> RequestModifier {
        authorization(.bearer, token)
    }

    static func userAgent(_ value: String?) -> RequestModifier {
        header(.userAgent, value)
    }
}

public extension RequestModifiable {

    func header(field: String, _ value: String?) -> Self {
        modifier(.header(field: field, value))
    }

    func header(_ field: RequestModifier.HeaderField, _ value: String?) -> Self {
        modifier(.header(field, value))
    }

    func accept(_ value: String?) -> Self {
        modifier(.accept(value))
    }

    func authorization(_ value: String?) -> Self {
        modifier(.authorization(value))
    }

    func authorization(_ scheme: RequestModifier.AuthorizationScheme, _ value: String?) -> Self {
        modifier(.authorization(scheme, value))
    }

    func basic(userId: String, password: String) -> Self {
        modifier(.basic(userId: userId, password: password))
    }

    func bearer(_ token: String?) -> Self {
        modifier(.bearer(token))
    }

    func userAgent(_ value: String?) -> Self {
        modifier(.userAgent(value))
    }
}
