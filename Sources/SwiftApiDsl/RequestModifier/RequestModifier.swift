import Foundation

/// A type that asynchronously enriches URLRequests
public struct RequestModifier: RequestModifiable {

    /// Asynchronously mutates an URLRequest
    ///
    /// - Parameters:
    ///    - urlRequest: The URLRequest base
    ///
    public let modify: (_ urlRequest: inout URLRequest) async throws -> Void

    public init(modify: @escaping (_ urlRequest: inout URLRequest) async throws -> Void) {
        self.modify = modify
    }

    public init(buildModifier: @escaping () async throws -> RequestModifier) {
        self.modify = {
            try await buildModifier().modify(&$0)
        }
    }

    public func modifier(_ modifier: RequestModifier) -> RequestModifier {
        .init {
            try await modify(&$0)
            try await modifier.modify(&$0)
        }
    }

    static let empty: RequestModifier = .init { _ in }
}
