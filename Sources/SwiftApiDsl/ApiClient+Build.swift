import Foundation

extension ApiClient: RequestModifiable {

    public func modifier(_ modifier: RequestModifier) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: self.modifier.modifier(modifier),
                  validator: validator,
                  authenticationModifier: authenticationModifier
        )
    }
}

extension ApiClient: ResponseValidatable {

    public func validator(_ validator: ResponseValidator) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: self.validator.validator(validator),
                  authenticationModifier: authenticationModifier
        )
    }
}

public extension ApiClient {

    func authentication(_ authenticate: @escaping (inout URLRequest) async throws -> Void) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: validator,
                  authenticationModifier: self.authenticationModifier.modifier(authenticate)
        )
    }

    func authentication(_ authenticationModifier: RequestModifier) -> ApiClient {
        ApiClient(urlSession: urlSession,
                  baseUrl: baseUrl,
                  jsonEncoder: jsonEncoder,
                  jsonDecoder: jsonDecoder,
                  modifier: modifier,
                  validator: validator,
                  authenticationModifier: self.authenticationModifier.modifier(authenticationModifier)
        )
    }

    func authentication(_ authenticationModifier: @escaping () async throws -> RequestModifier) -> ApiClient {
        authentication {
            try await authenticationModifier().modify(&$0)
        }
    }
}
