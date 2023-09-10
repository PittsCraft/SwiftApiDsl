import Foundation

/// `URLRequest` functions
public extension ApiClient {


    @discardableResult
    func perform<RequestBody: Encodable>(
        _ urlRequest: URLRequest,
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        extraValidator: ResponseValidator = .empty
    ) async throws -> Response<Data> {
        let modifier = jsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        return try await perform(modifier: modifier, anonymous: anonymous, extraValidator: extraValidator).response
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ urlRequest: URLRequest,
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        extraValidator: ResponseValidator = .empty,
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> Response<ResponseBody> {
        let dataResponse = try await perform(urlRequest,
                                             anonymous: anonymous,
                                             body: body,
                                             jsonEncoder: jsonEncoder,
                                             extraValidator: extraValidator)
        let body: ResponseBody = try decode(request: urlRequest,
                                            dataResponse: dataResponse,
                                            jsonDecoder: jsonDecoder)
        return Response(body: body, httpResponse: dataResponse.httpResponse)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ urlRequest: URLRequest,
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        extraValidator: ResponseValidator = .empty,
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> ResponseBody {
        try await perform(urlRequest,
                          anonymous: anonymous,
                          body: body,
                          jsonEncoder: jsonEncoder,
                          jsonDecoder: jsonDecoder,
                          extraValidator: extraValidator,
                          responseBodyType: responseBodyType).body
    }

    @discardableResult
    func download<RequestBody: Encodable>(
        _ urlRequest: URLRequest,
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        destination: URL,
        extraValidator: ResponseValidator
    ) async throws -> HTTPURLResponse {
        let modifier = jsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        return try await download(modifier: modifier,
                                  anonymous: anonymous,
                                  destination: destination,
                                  extraValidator: extraValidator)
    }
}

/// `Request` functions
public extension ApiClient {

    @discardableResult
    func perform<RequestBody: Encodable>(
        _ request: Request = .get(),
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        extraValidator: ResponseValidator = .empty
    ) async throws -> Response<Data> {
        let jsonModifier = jsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        let modifier = request.compose(with: jsonModifier)
        return try await perform(modifier: modifier, anonymous: anonymous, extraValidator: extraValidator).response
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ request: Request = .get(),
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        extraValidator: ResponseValidator = .empty,
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> Response<ResponseBody> {
        let jsonModifier = jsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        let modifier = request.compose(with: jsonModifier)
        let (request, response) = try await perform(modifier: modifier,
                                                    anonymous: anonymous,
                                                    extraValidator: extraValidator)
        let body: ResponseBody = try decode(request: request, dataResponse: response, jsonDecoder: jsonDecoder)
        return Response(body: body, httpResponse: response.httpResponse)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ request: Request = .get(),
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        extraValidator: ResponseValidator = .empty,
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> ResponseBody {
        try await perform(request,
                          anonymous: anonymous,
                          body: body,
                          jsonEncoder: jsonEncoder,
                          jsonDecoder: jsonDecoder,
                          extraValidator: extraValidator).body
    }

    @discardableResult
    func download<RequestBody: Encodable>(
        _ request: Request = .get(),
        anonymous: Bool = false,
        body: RequestBody? = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        destination: URL,
        extraValidator: ResponseValidator = .empty
    ) async throws -> HTTPURLResponse {
        let jsonModifier = jsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        let modifier = request.compose(with: jsonModifier)
        return try await download(modifier: modifier,
                                  anonymous: anonymous,
                                  destination: destination,
                                  extraValidator: extraValidator)
    }
}
