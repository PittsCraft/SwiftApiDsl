import Foundation

public class ApiClient {

    public let urlSession: URLSession
    private let baseUrl: URL
    private let modifiers: [RequestModifier]
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let validators: [ResponseValidator]

    public init(urlSession: URLSession = .shared,
                baseUrl: URL,
                modifiers: [RequestModifier] = [],
                jsonEncoder: JSONEncoder = JSONEncoder(),
                jsonDecoder: JSONDecoder = JSONDecoder(),
                validators: [ResponseValidator] = [HttpStatusCodeRangeValidator()]) {
        self.urlSession = urlSession
        self.baseUrl = baseUrl
        self.modifiers = modifiers
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.validators = validators
    }
}

private extension ApiClient {
    func modify(request: inout URLRequest,
                extraModifiers: [RequestModifier],
                ignoreDefaultModifiers: Bool) async throws {
        guard !ignoreDefaultModifiers else { return }
        for modifier in modifiers {
            do {
                try await modifier.modify(&request)
            } catch {
                throw RequestError(request: request, error: .requestModifierError(error))
            }
        }
    }

    func validate(request: URLRequest,
                  data: Data,
                  response: HTTPURLResponse,
                  ignoreDefaultValidators: Bool,
                  extraValidators: [ResponseValidator]) throws {
        var validators = ignoreDefaultValidators ? [] : self.validators
        validators += extraValidators
        for validator in validators {
            do {
                try validator.validate(data: data, response: response)
            } catch {
                throw RequestError(request: request, error: .validationError(data: data,
                                                                             response: response,
                                                                             error: error))
            }
        }
    }

    func jsonBodyModifiers<RequestBody: Encodable>(body: RequestBody?, jsonEncoder: JSONEncoder?) -> [RequestModifier] {
        guard let body else {
            return []
        }
        let jsonEncoder = jsonEncoder ?? self.jsonEncoder
        let bodyModifier = JsonBodyModifier(body: body, jsonEncoder: jsonEncoder)
        let headerModifier = HeaderModifier(value: "application/json", headerField: "Content-Type")
        return [bodyModifier, headerModifier]
    }

    func addJsonBody<RequestBody: Encodable>(to request: Request,
                                             body: RequestBody?,
                                             jsonEncoder: JSONEncoder?) -> Request {
        let modifiers = jsonBodyModifiers(body: body, jsonEncoder: jsonEncoder)
        return request.with(modifiers)
    }

    func decode<ResponseBody: Decodable>(data: Data, jsonDecoder: JSONDecoder?) throws -> ResponseBody {
        let jsonDecoder = jsonDecoder ?? self.jsonDecoder
        return try jsonDecoder.decode(ResponseBody.self, from: data)
    }

    // swiftlint:disable:next function_parameter_count
    func handleDownloadResult(request: URLRequest,
                              destination: URL,
                              url: URL?,
                              response: URLResponse?,
                              error: Error?,
                              ignoreDefaultValidators: Bool,
                              extraValidators: [ResponseValidator]) throws -> HTTPURLResponse {
        guard let response = response as? HTTPURLResponse else {
            throw RequestError(request: request, error: .notHttpResponse(response))
        }
        try validate(request: request,
                     data: Data(),
                     response: response,
                     ignoreDefaultValidators: ignoreDefaultValidators,
                     extraValidators: extraValidators)
        if let error {
            throw RequestError(request: request, error: .transportError(error))
        }
        if let url, error == nil {
            do {
                try FileManager.default.moveItem(at: url, to: destination)
            } catch {
                throw RequestError(request: request,
                                   error: .downloadedFileMoveFailure(error))
            }
            return response
        }
        throw RequestError(request: request, error: .unknown(nil))
    }
}

/// `URLRequest` functions
public extension ApiClient {

    @discardableResult
    func perform<RequestBody: Encodable>(
        _ urlRequest: URLRequest,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = []
    ) async throws -> (data: Data, response: HTTPURLResponse) {
        var request = urlRequest
        let jsonBodyModifiers = jsonBodyModifiers(body: body, jsonEncoder: jsonEncoder)
        try await modify(request: &request,
                         extraModifiers: jsonBodyModifiers,
                         ignoreDefaultModifiers: ignoreDefaultModifiers)

        let (data, response) = try await urlSession.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError(request: request, error: .notHttpResponse(response))
        }

        try validate(request: request,
                     data: data,
                     response: response,
                     ignoreDefaultValidators: ignoreDefaultValidators,
                     extraValidators: extraValidators)
        return (data: data, response: response)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ urlRequest: URLRequest,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = [],
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> (body: ResponseBody, response: HTTPURLResponse) {
        let (data, response) = try await perform(urlRequest,
                                                 body: body,
                                                 jsonEncoder: jsonEncoder,
                                                 ignoreDefaultModifiers: ignoreDefaultModifiers,
                                                 ignoreDefaultValidators: ignoreDefaultValidators,
                                                 extraValidators: extraValidators)
        let body: ResponseBody = try decode(data: data, jsonDecoder: jsonDecoder)
        return (body: body, response: response)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ urlRequest: URLRequest,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = [],
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> ResponseBody {
        try await perform(urlRequest,
                          body: body,
                          jsonEncoder: jsonEncoder,
                          jsonDecoder: jsonDecoder,
                          ignoreDefaultModifiers: ignoreDefaultModifiers,
                          ignoreDefaultValidators: ignoreDefaultValidators,
                          extraValidators: extraValidators,
                          responseBodyType: responseBodyType).body
    }

    @discardableResult
    func download<RequestBody: Encodable>(_ urlRequest: URLRequest,
                                          body: RequestBody = nil as String?,
                                          jsonEncoder: JSONEncoder? = nil,
                                          destination: URL,
                                          ignoreDefaultModifiers: Bool,
                                          ignoreDefaultValidators: Bool,
                                          extraValidators: [ResponseValidator]) async throws -> HTTPURLResponse {
        var request = urlRequest
        let jsonBodyModifiers = jsonBodyModifiers(body: body, jsonEncoder: jsonEncoder)
        try await modify(request: &request,
                         extraModifiers: jsonBodyModifiers,
                         ignoreDefaultModifiers: ignoreDefaultModifiers)
        var downloadTask: URLSessionDownloadTask?
        return try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                downloadTask = urlSession.downloadTask(with: request,
                                                       completionHandler: { [weak self, request] url, response, error in
                    guard let self else {
                        continuation.resume(throwing: RequestError(request: request, error: .clientDeallocated))
                        return
                    }
                    do {
                        let response = try handleDownloadResult(request: request,
                                                                destination: destination,
                                                                url: url,
                                                                response: response,
                                                                error: error,
                                                                ignoreDefaultValidators: ignoreDefaultValidators,
                                                                extraValidators: extraValidators)
                        continuation.resume(returning: response)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
                downloadTask?.resume()
            }
        }, onCancel: { [downloadTask] in
            downloadTask?.cancel()
        })
    }
}

/// `Request` functions
public extension ApiClient {

    @discardableResult
    func perform<RequestBody: Encodable>(
        _ request: Request,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = []
    ) async throws -> (data: Data, response: HTTPURLResponse) {
        try await perform(request.toUrlRequest(baseUrl: baseUrl),
                          body: body,
                          jsonEncoder: jsonEncoder,
                          ignoreDefaultModifiers: ignoreDefaultModifiers,
                          ignoreDefaultValidators: ignoreDefaultValidators,
                          extraValidators: extraValidators)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ request: Request,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = [],
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> (body: ResponseBody, response: HTTPURLResponse) {
        try await perform(request.toUrlRequest(baseUrl: baseUrl),
                          body: body,
                          jsonEncoder: jsonEncoder,
                          jsonDecoder: jsonDecoder,
                          ignoreDefaultModifiers: ignoreDefaultModifiers,
                          ignoreDefaultValidators: ignoreDefaultValidators,
                          extraValidators: extraValidators)
    }

    @discardableResult
    func perform<RequestBody: Encodable, ResponseBody: Decodable>(
        _ request: Request,
        body: RequestBody = nil as String?,
        jsonEncoder: JSONEncoder? = nil,
        jsonDecoder: JSONDecoder? = nil,
        ignoreDefaultModifiers: Bool = false,
        ignoreDefaultValidators: Bool = false,
        extraValidators: [ResponseValidator] = [],
        responseBodyType: ResponseBody.Type? = nil
    ) async throws -> ResponseBody {
        try await perform(request.toUrlRequest(baseUrl: baseUrl),
                          body: body,
                          ignoreDefaultModifiers: ignoreDefaultModifiers,
                          ignoreDefaultValidators: ignoreDefaultValidators,
                          extraValidators: extraValidators)
    }

    @discardableResult
    func download<RequestBody: Encodable>(_ request: Request,
                                          body: RequestBody = nil as String?,
                                          jsonEncoder: JSONEncoder? = nil,
                                          destination: URL,
                                          ignoreDefaultModifiers: Bool,
                                          ignoreDefaultValidators: Bool = false,
                                          extraValidators: [ResponseValidator] = []) async throws -> HTTPURLResponse {
        return try await download(request.toUrlRequest(baseUrl: baseUrl),
                                  body: body,
                                  jsonEncoder: jsonEncoder,
                                  destination: destination,
                                  ignoreDefaultModifiers: ignoreDefaultModifiers,
                                  ignoreDefaultValidators: ignoreDefaultValidators,
                                  extraValidators: extraValidators)
    }
}
