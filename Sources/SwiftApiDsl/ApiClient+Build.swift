import Foundation

extension ApiClient: RequestModifiable {

    public func modifier(_ modifier: RequestModifier) -> Self {
        Self(urlSession: urlSession,
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

    public func validator(_ validator: ResponseValidator) -> Self {
        Self(urlSession: urlSession,
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

    func authentication(_ authenticate: @escaping (inout URLRequest) async throws -> Void) -> Self {
        Self(urlSession: urlSession,
             baseUrl: baseUrl,
             jsonEncoder: jsonEncoder,
             jsonDecoder: jsonDecoder,
             modifier: modifier,
             validator: validator,
             authenticationModifier: self.authenticationModifier.modifier(authenticate)
        )
    }

    func authentication(_ authenticationModifier: RequestModifier) -> Self {
        Self(urlSession: urlSession,
             baseUrl: baseUrl,
             jsonEncoder: jsonEncoder,
             jsonDecoder: jsonDecoder,
             modifier: modifier,
             validator: validator,
             authenticationModifier: self.authenticationModifier.modifier(authenticationModifier)
        )
    }

    func authentication(_ authenticationModifier: @escaping () async throws -> RequestModifier) -> Self {
        authentication {
            try await authenticationModifier().modify(&$0)
        }
    }
}
