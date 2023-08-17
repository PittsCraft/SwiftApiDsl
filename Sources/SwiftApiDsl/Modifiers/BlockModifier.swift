import Foundation

public struct BlockModifier: RequestModifier {
    private let block: (inout URLRequest) async throws -> Void

    public init(block: @escaping (inout URLRequest) async throws -> Void) {
        self.block = block
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        try await block(&urlRequest)
    }
}
