import Foundation

public struct ResponseValidator: ResponseValidatable {

    public let validate: (Response<Data>) throws -> Void

    public init(validate: @escaping (Response<Data>) throws -> Void) {
        self.validate = validate
    }

    public func validator(_ validator: ResponseValidator) -> ResponseValidator {
        .init { response in
            try self.validate(response)
            try validator.validate(response)
        }
    }

    public static let empty: ResponseValidator = .init { _ in }
}
