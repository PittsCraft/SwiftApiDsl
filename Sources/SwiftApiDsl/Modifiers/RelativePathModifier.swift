import Foundation

public struct RelativePathModifier: RequestModifier {

    public let relativePath: String

    public init(relativePath: String) {
        self.relativePath = relativePath
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.url = urlRequest.url?.appendingPathComponent(relativePath)
    }
}
