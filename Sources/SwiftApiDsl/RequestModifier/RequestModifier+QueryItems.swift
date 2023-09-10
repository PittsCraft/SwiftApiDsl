import Foundation

public extension RequestModifier {

    static func queryItems(_ queryItems: [String: String?]) -> RequestModifier {
        .init {
            guard let url = $0.url else {
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
            $0.url = url
        }
    }

    func queryItems(_ queryItems: [String: String?]) -> RequestModifier {
        compose(with: .queryItems(queryItems))
    }
}
