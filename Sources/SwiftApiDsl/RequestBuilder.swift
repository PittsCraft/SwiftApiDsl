import Foundation

public struct RequestBuilder {
    let apiClient: ApiClient
    let anonymous: Bool
    let extraValidator: ResponseValidator
    let modifier: RequestModifier

    init(apiClient: ApiClient,
         anonymous: Bool,
         extraValidator: ResponseValidator,
         modifier: RequestModifier) {
        self.apiClient = apiClient
        self.anonymous = anonymous
        self.extraValidator = .empty
        self.modifier = modifier
    }
}

extension RequestBuilder: ResponseValidatable {

    public func validator(_ validator: ResponseValidator) -> RequestBuilder {
        .init(apiClient: apiClient,
              anonymous: anonymous,
              extraValidator: extraValidator.validator(validator),
              modifier: modifier)
    }
}

extension RequestBuilder: RequestModifiable {

    public func modifier(_ modifier: RequestModifier) -> RequestBuilder {
        .init(apiClient: apiClient,
              anonymous: anonymous,
              extraValidator: extraValidator,
              modifier: self.modifier.modifier(modifier))
    }
}

public extension RequestBuilder {

    func perform() async throws {
        _ = try await apiClient.perform(modifier: modifier, anonymous: anonymous, extraValidator: extraValidator)
    }

    func perform() async throws -> Response<Data> {
        try await apiClient.perform(modifier: modifier, anonymous: anonymous, extraValidator: extraValidator).response
    }

    func perform<ResponseBody: Decodable>(jsonDecoder: JSONDecoder? = nil) async throws -> Response<ResponseBody> {
        let (request, response) = try await apiClient.perform(modifier: modifier,
                                                              anonymous: anonymous,
                                                              extraValidator: extraValidator)
        let body: ResponseBody = try apiClient.decode(request: request,
                                                      dataResponse: response,
                                                      jsonDecoder: jsonDecoder)
        return Response(body: body, httpResponse: response.httpResponse)
    }

    func perform<ResponseBody: Decodable>(jsonDecoder: JSONDecoder? = nil) async throws -> ResponseBody {
        try await perform(jsonDecoder: jsonDecoder).body
    }

    @discardableResult
    func download(_ destination: URL) async throws -> HTTPURLResponse {
        try await apiClient.download(modifier: modifier,
                                     anonymous: anonymous,
                                     destination: destination,
                                     extraValidator: extraValidator)
    }
}
