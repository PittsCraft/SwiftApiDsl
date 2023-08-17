import Foundation

public extension Request {

    func with(_ modifier: RequestModifier) -> Request {
        Request(modifiers + [modifier])
    }

    func with(_ modifiers: [RequestModifier]) -> Request {
        Request(self.modifiers + modifiers)
    }

    func with(block: @escaping (inout URLRequest) -> Void) -> Request {
        with(BlockModifier(block: block))
    }

    func with(body: Data) -> Request {
        with(BodyModifier(body: body))
    }

    func with(cachePolicy: URLRequest.CachePolicy) -> Request {
        with(CachePolicyModifier(cachePolicy: cachePolicy))
    }

    func with(headerField: String, value: String?) -> Request {
        with(HeaderModifier(value: value, headerField: headerField))
    }

    func with(httpMethod: HttpMethod) -> Request {
        with(HttpMethodModifier(httpMethod: httpMethod))
    }

    func with(queryItems: [String: String?]) -> Request {
        with(QueryItemsModifier(queryItems: queryItems))
    }

    func with(relativePath: String) -> Request {
        with(RelativePathModifier(relativePath: relativePath))
    }

    func with(timeoutInterval: TimeInterval) -> Request {
        with(TimeoutIntervalModifier(timeoutInterval: timeoutInterval))
    }

    func with(multipartFormData modifier: MultipartFormDataModifier) -> Request {
        with(modifier)
    }
}
