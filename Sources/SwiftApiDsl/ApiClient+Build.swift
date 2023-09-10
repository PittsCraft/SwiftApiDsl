import Foundation

public extension ApiClient {

    func modifier(_ modifier: RequestModifier) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: self.modifier.compose(with: modifier),
                  validator: validator,
                  authenticationModifier: authenticationModifier
        )
    }

    func modifier(_ modify: @escaping (inout URLRequest) async throws -> Void) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: self.modifier.compose(with: .init(modify: modify)),
                  validator: validator,
                  authenticationModifier: authenticationModifier
        )
    }

    func validator(_ validator: ResponseValidator) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: self.validator.compose(with: validator),
                  authenticationModifier: authenticationModifier
        )
    }

    func validator(_ validate: @escaping (Response<Data>) throws -> Void) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: self.validator.compose(with: .init(validate: validate)),
                  authenticationModifier: authenticationModifier
        )
    }

    func authentication(_ authenticationModifier: RequestModifier) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: self.modifier.compose(with: modifier),
                  validator: validator,
                  authenticationModifier: self.authenticationModifier.compose(with: authenticationModifier)
        )
    }

    func authentication(_ authenticate: @escaping (inout URLRequest) async throws -> Void) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: validator,
                  authenticationModifier: self.authenticationModifier.compose(with: .init(modify: authenticate))
        )
    }
}
