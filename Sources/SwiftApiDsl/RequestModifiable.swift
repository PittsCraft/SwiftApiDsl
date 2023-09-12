import Foundation

public protocol RequestModifiable {

    func modifier(_ modifier: RequestModifier) -> Self
}

public extension RequestModifiable {

    func modifier(
        _ modify: @escaping (_ urlRequest: inout URLRequest) async throws -> Void
    ) -> Self {
        modifier(RequestModifier(modify: modify))
    }

    func modifier(
        _ buildModifier: @escaping () async throws -> RequestModifier
    ) -> Self {
        modifier {
            try await buildModifier().modify(&$0)
        }
    }
}
