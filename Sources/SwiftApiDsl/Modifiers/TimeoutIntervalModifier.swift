import Foundation

public struct TimeoutIntervalModifier: RequestModifier {

    public let timeoutInterval: TimeInterval

    public init(timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.timeoutInterval = timeoutInterval
    }
}
