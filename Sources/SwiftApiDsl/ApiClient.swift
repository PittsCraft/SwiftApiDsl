import Foundation

public struct ApiClient {

    let urlSession: URLSession
    let baseUrl: URL
    let jsonEncoder: JSONEncoder
    let jsonDecoder: JSONDecoder
    let modifier: RequestModifier
    let validator: ResponseValidator
    let authenticationModifier: RequestModifier

    public init(urlSession: URLSession = .shared,
                baseUrl: URL,
                jsonEncoder: JSONEncoder = JSONEncoder(),
                jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.baseUrl = baseUrl
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.modifier = .empty
        self.validator = .empty
        self.authenticationModifier = .empty
    }

    init(urlSession: URLSession = .shared,
         baseUrl: URL,
         jsonEncoder: JSONEncoder = JSONEncoder(),
         jsonDecoder: JSONDecoder = JSONDecoder(),
         modifier: RequestModifier,
         validator: ResponseValidator,
         authenticationModifier: RequestModifier) {
        self.urlSession = urlSession
        self.baseUrl = baseUrl
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.modifier = modifier
        self.validator = validator
        self.authenticationModifier = authenticationModifier
    }
}

extension ApiClient {

    func modify(request: inout URLRequest, modifier: RequestModifier) async throws {
        do {
            try await modifier
                .modifier(modifier)
                .modify(&request)
        } catch {
            throw RequestError.modify(request, error)
        }
    }

    func validate(request: URLRequest,
                  response: Response<Data>,
                  extraValidator: ResponseValidator) throws {
        let validator = self.validator.validator(extraValidator)
        do {
            try validator.validate(response)
        } catch {
            throw RequestError.validate(request,
                                        response: response,
                                        error: error)
        }
    }

    func execute(request: URLRequest) async throws -> Response<Data> {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw RequestError.transport(request, error)
        }
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.fatal(.notHttpResponse(request, response))
        }
        return Response(body: data, httpResponse: response)
    }

    func decode<ResponseBody: Decodable>(request: URLRequest,
                                         dataResponse: Response<Data>,
                                         jsonDecoder: JSONDecoder?) throws -> ResponseBody {
        do {
            let jsonDecoder = jsonDecoder ?? self.jsonDecoder
            return try jsonDecoder.decode(ResponseBody.self, from: dataResponse.body)
        } catch {
            throw RequestError.fatal(.decode(request,
                                             response: dataResponse,
                                             error: error,
                                             expectedType: ResponseBody.self))
        }
    }

    // swiftlint:disable:next function_parameter_count
    func handleDownloadResult(request: URLRequest,
                              destination: URL,
                              url: URL?,
                              response: URLResponse?,
                              error: Error?,
                              extraValidator: ResponseValidator) throws -> HTTPURLResponse {
        if let error {
            throw RequestError.transport(request, error)
        }
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.fatal(.notHttpResponse(request, response))
        }
        try validate(request: request,
                     response: Response(body: Data(), httpResponse: response),
                     extraValidator: extraValidator)
        if let url {
            do {
                try FileManager.default.moveItem(at: url, to: destination)
            } catch {
                throw RequestError.fatal(.downloadedFileMoveFailure(request, error))
            }
            return response
        }
        throw RequestError.fatal(.unknown(request, nil))
    }

    func perform(
        modifier: RequestModifier,
        anonymous: Bool,
        extraValidator: ResponseValidator
    ) async throws -> (request: URLRequest, response: Response<Data>) {
        var request = URLRequest(url: baseUrl)
        // Modify
        var modifier = self.modifier.modifier(modifier)
        if !anonymous {
            modifier = modifier.modifier(authenticationModifier)
        }
        try await modify(request: &request, modifier: modifier)
        // Transport
        let response = try await execute(request: request)
        // Validate
        try validate(request: request, response: response, extraValidator: extraValidator)
        return (request, response)
    }

    func download(
        modifier: RequestModifier,
        anonymous: Bool,
        destination: URL,
        extraValidator: ResponseValidator
    ) async throws -> HTTPURLResponse {
        var request = URLRequest(url: baseUrl)
        var modifier = self.modifier.modifier(modifier)
        if !anonymous {
            modifier = modifier.modifier(authenticationModifier)
        }
        try await modify(request: &request, modifier: modifier)
        var downloadTask: URLSessionDownloadTask?
        return try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                downloadTask = urlSession.downloadTask(with: request,
                                                       completionHandler: { [self, request] url, response, error in
                    do {
                        let response = try handleDownloadResult(request: request,
                                                                destination: destination,
                                                                url: url,
                                                                response: response,
                                                                error: error,
                                                                extraValidator: extraValidator)
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
