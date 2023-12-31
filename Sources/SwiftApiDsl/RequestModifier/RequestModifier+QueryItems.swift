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
            var resultItems = components.queryItems ?? []
            resultItems += queryItems
                .filter { $0.value != nil }
                .map { (name, value) in URLQueryItem(name: name, value: value) }
            components.queryItems = resultItems
            guard let url = components.url else {
                throw BuildRequestError.buildUrlFromComponents(components)
            }
            $0.url = url
        }
    }

    static func queryItem(name: String, _ value: String?) -> RequestModifier {
        queryItems([name: value])
    }
}

public extension RequestModifiable {

    func queryItems(_ queryItems: [String: String?]) -> Self {
        modifier(.queryItems(queryItems))
    }

    func queryItem(name: String, _ value: String?) -> Self {
        modifier(.queryItem(name: name, value))
    }
}
