import Foundation

public protocol ResponseValidatable {

    func validator(_ validator: ResponseValidator) -> Self
}

public extension ResponseValidatable {

    func validator(_ validate: @escaping (Response<Data>) throws -> Void) -> Self {
        validator(.init(validate: validate))
    }
}
