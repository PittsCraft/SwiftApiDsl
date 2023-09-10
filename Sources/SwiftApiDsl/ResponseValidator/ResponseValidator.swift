import Foundation

public struct ResponseValidator {

    public let validate: (Response<Data>) throws -> Void

    public init(validate: @escaping (Response<Data>) throws -> Void) {
        self.validate = validate
    }

    public func compose(with otherValidator: ResponseValidator) -> ResponseValidator {
        .init { response in
            try self.validate(response)
            try otherValidator.validate(response)
        }
    }

    public static let empty: ResponseValidator = .init { _ in }
}
