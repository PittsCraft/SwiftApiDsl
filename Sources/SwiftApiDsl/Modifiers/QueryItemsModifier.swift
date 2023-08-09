import Foundation

public struct QueryItemsModifier: RequestModifier {

    public let queryItems: [String: String?]

    public init(queryItems: [String: String?]) {
        self.queryItems = queryItems
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        guard let url = urlRequest.url else {
            throw BuildRequestError.noUrl
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw BuildRequestError.parseComponents(url)
        }
        components.queryItems = queryItems
            .filter { $0.value != nil }
            .map { (name, value) in URLQueryItem(name: name, value: value) }
        guard let url = components.url else {
            throw BuildRequestError.buildUrlFromComponents(components)
        }
        urlRequest.url = url
    }
}
