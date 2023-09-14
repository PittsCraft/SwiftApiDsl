import Foundation

public class ApiClientMock: ApiClient {

    public var resultProvider: (_ request: URLRequest) throws -> Result<Response<Data>, RequestError> = {
        .response($0)
    }

    public override init(urlSession: URLSession = .shared,
                         baseUrl: URL,
                         jsonEncoder: JSONEncoder = JSONEncoder(),
                         jsonDecoder: JSONDecoder = JSONDecoder()) {
        super.init(urlSession: urlSession,
                   baseUrl: baseUrl,
                   jsonEncoder: jsonEncoder,
                   jsonDecoder: jsonDecoder)
    }

    required init(urlSession: URLSession,
                  baseUrl: URL,
                  jsonEncoder: JSONEncoder,
                  jsonDecoder: JSONDecoder,
                  modifier: RequestModifier,
                  validator: ResponseValidator,
                  authenticationModifier: RequestModifier) {
        super.init(urlSession: urlSession,
                   baseUrl: baseUrl,
                   modifier: modifier,
                   validator: validator,
                   authenticationModifier: authenticationModifier)
    }

    override func perform(
        modifier: RequestModifier,
        bypassAuth: Bool,
        extraValidator: ResponseValidator
    ) async throws -> (request: URLRequest, response: Response<Data>) {
        var request = URLRequest(url: baseUrl)
        try await modify(request: &request, requestModifier: modifier, bypassAuth: bypassAuth)
        switch try resultProvider(request) {
        case .success(let response): return (request, response)
        case .failure(let error): throw error
        }
    }

    override func download(
        modifier: RequestModifier,
        bypassAuth: Bool,
        destination: URL,
        extraValidator: ResponseValidator
    ) async throws -> HTTPURLResponse {
        try await perform(modifier: modifier, bypassAuth: bypassAuth, extraValidator: extraValidator)
            .response
            .httpResponse
    }
}
