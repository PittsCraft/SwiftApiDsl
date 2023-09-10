import Foundation

extension RequestModifier {
    static func methodAndPath(_ httpMethod: HttpMethod, _ path: String?) -> RequestModifier {
        var result = RequestModifier.httpMethod(httpMethod)
        if let path {
            result = result.path(path)
        }
        return result
    }
}

public extension RequestModifier {
    static func delete(path: String? = nil) -> RequestModifier { methodAndPath(.delete, path) }
    static func head(path: String? = nil) -> RequestModifier { methodAndPath(.head, path) }
    static func options(path: String? = nil) -> RequestModifier { methodAndPath(.options, path) }
    static func get(path: String? = nil) -> RequestModifier { methodAndPath(.delete, path) }
    static func patch(path: String? = nil) -> RequestModifier { methodAndPath(.patch, path) }
    static func post(path: String? = nil) -> RequestModifier { methodAndPath(.post, path) }
    static func put(path: String? = nil) -> RequestModifier { methodAndPath(.put, path) }
}
