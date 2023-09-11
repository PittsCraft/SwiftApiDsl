import Foundation

public extension ApiClient {

    func request<RequestBody: Encodable>(_ httpMethod: HttpMethod = .get,
                                         _ path: String? = nil,
                                         anonymous: Bool = false,
                                         body: RequestBody? = nil as String?,
                                         jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        var modifier = RequestModifier.httpMethod(httpMethod)
        if let path {
            modifier = modifier.modifier(.path(path))
        }
        if let body {
            let jsonEncoder = jsonEncoder ?? self.jsonEncoder
            modifier = modifier.modifier(.jsonBody(body: body, jsonEncoder: jsonEncoder))
        }
        return .init(apiClient: self,
                     anonymous: anonymous,
                     extraValidator: .empty,
                     modifier: modifier)
    }

    func delete<RequestBody: Encodable>(_ path: String? = nil,
                                        anonymous: Bool = false,
                                        body: RequestBody? = nil as String?,
                                        jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.delete, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func head<RequestBody: Encodable>(_ path: String? = nil,
                                      anonymous: Bool = false,
                                      body: RequestBody? = nil as String?,
                                      jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.head, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func get<RequestBody: Encodable>(_ path: String? = nil,
                                     anonymous: Bool = false,
                                     body: RequestBody? = nil as String?,
                                     jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.get, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func options<RequestBody: Encodable>(_ path: String? = nil,
                                         anonymous: Bool = false,
                                         body: RequestBody? = nil as String?,
                                         jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.options, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func patch<RequestBody: Encodable>(_ path: String? = nil,
                                       anonymous: Bool = false,
                                       body: RequestBody? = nil as String?,
                                       jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.patch, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func post<RequestBody: Encodable>(_ path: String? = nil,
                                      anonymous: Bool = false,
                                      body: RequestBody? = nil as String?,
                                      jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.post, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }

    func put<RequestBody: Encodable>(_ path: String? = nil,
                                     anonymous: Bool = false,
                                     body: RequestBody? = nil as String?,
                                     jsonEncoder: JSONEncoder? = nil) -> RequestBuilder {
        request(.put, path, anonymous: anonymous, body: body, jsonEncoder: jsonEncoder)
    }
}
