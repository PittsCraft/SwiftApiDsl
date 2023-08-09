import Foundation

public enum BuildRequestError: Error {
    case noUrl
    case parseComponents(URL)
    case buildUrlFromComponents(URLComponents)
}
