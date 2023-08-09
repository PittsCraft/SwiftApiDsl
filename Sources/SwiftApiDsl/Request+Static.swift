import Foundation

public extension Request {

    init(_ httpMethod: HttpMethod,
         _ relativePath: String,
         queryItems: [String: String?]? = nil,
         modifiers: [RequestModifier] = []) {
        self.modifiers = [
            HttpMethodModifier(httpMethod: httpMethod),
            RelativePathModifier(relativePath: relativePath)
        ] + modifiers
        + (queryItems.map { [QueryItemsModifier(queryItems: $0)] } ?? [])
    }

    static func get(_ relativePath: String,
                    queryItems: [String: String?]? = nil,
                    modifiers: [RequestModifier] = []) -> Request {
        Self(.get, relativePath, queryItems: queryItems, modifiers: modifiers)
    }

    static func post(_ relativePath: String,
                     queryItems: [String: String?]? = nil,
                     modifiers: [RequestModifier] = []) -> Request {
        Self(.post, relativePath, queryItems: queryItems, modifiers: modifiers)
    }

    static func put(_ relativePath: String,
                    queryItems: [String: String?]? = nil,
                    modifiers: [RequestModifier] = []) -> Request {
        Self(.put, relativePath, queryItems: queryItems, modifiers: modifiers)
    }

    static func patch(_ relativePath: String,
                      queryItems: [String: String?]? = nil,
                      modifiers: [RequestModifier] = []) -> Request {
        Self(.patch, relativePath, queryItems: queryItems, modifiers: modifiers)
    }

    static func delete(_ relativePath: String,
                       queryItems: [String: String?]? = nil,
                       modifiers: [RequestModifier] = []) -> Request {
        Self(.delete, relativePath, queryItems: queryItems, modifiers: modifiers)
    }
}
