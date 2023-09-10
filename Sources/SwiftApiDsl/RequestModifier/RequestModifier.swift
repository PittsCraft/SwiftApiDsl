import Foundation

/// A type that asynchronously enriches URLRequests
public struct  RequestModifier {

    /// Asynchronously mutates an URLRequest
    ///
    /// - Parameters:
    ///    - urlRequest: The URLRequest base
    ///
    public let modify: (_ urlRequest: inout URLRequest) async throws -> Void

    public init(modify: @escaping (_ urlRequest: inout URLRequest) async throws -> Void) {
        self.modify = modify
    }

    public func compose(with otherModifier: RequestModifier) -> RequestModifier {
        .init {
            try await self.modify(&$0)
            try await otherModifier.modify(&$0)
        }
    }

    static let empty: RequestModifier = .init { _ in }
}

public typealias Request = RequestModifier
