import Foundation

/// A type that asynchronously enriches URLRequests
public protocol RequestModifier {

    /// Asynchronously mutates an URLRequest
    ///
    /// - Parameters:
    ///    - urlRequest: The URLRequest base
    ///
    func modify(_ urlRequest: inout URLRequest) async throws
}
