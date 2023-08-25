import Foundation

public struct BlockValidator: ResponseValidator {

    private let block: (Data, HTTPURLResponse) throws -> Void

    public init(block: @escaping (Data, HTTPURLResponse) throws -> Void) {
        self.block = block
    }

    public func validate(data: Data, response: HTTPURLResponse) throws {
        try block(data, response)
    }
}
