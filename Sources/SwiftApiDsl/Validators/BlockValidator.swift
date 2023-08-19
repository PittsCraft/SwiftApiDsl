import Foundation

struct BlockValidator: ResponseValidator {

    private let block: (Data, HTTPURLResponse) throws -> Void

    init(block: @escaping (Data, HTTPURLResponse) throws -> Void) {
        self.block = block
    }

    func validate(data: Data, response: HTTPURLResponse) throws {
        try block(data, response)
    }
}
