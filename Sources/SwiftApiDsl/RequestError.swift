import Foundation

public enum RequestError: Error {

    /// Error thrown by a modifier
    case modify(URLRequest, Error)
    /// Error thrown when performing the actual URLRequest
    case transport(URLRequest, Error)
    /// Error thrown by a validator
    case validate(URLRequest, data: Data, response: HTTPURLResponse, error: Error)
    /// The URLResponse of the request is not an HTTPURLResponse 🤷‍♂️
    case notHttpResponse(URLRequest, URLResponse?)
    /// The response passed validation, but its body failed to decode as the expected type
    case decode(URLRequest, data: Data, response: HTTPURLResponse, error: Error, expectedType: Any.Type)
    /// Terrible inconsistency, should never happen
    case unknown(URLRequest?, Error?)
    /// The client was deallocated during a download
    case clientDeallocated(URLRequest)
    /// Couldn't move the downloaded file to its destination
    case downloadedFileMoveFailure(URLRequest, Error)

    private var caseDescription: String {
        switch self {
        case .modify(_, let error):
            return "Error thrown by a modifier: \(error.localizedDescription)"
        case .transport(_, let error):
            return "Error thrown when performing the request: \(error.localizedDescription)"
        case .validate(_, data: _, response: let response, error: let error):
            return "Validation error: \(error.localizedDescription). Response: \(response.debugDescription)"
        case .notHttpResponse(_, let urlResponse):
            return "The URLResponse \(urlResponse?.debugDescription ?? "(nil)") of the request is not an "
            + "HTTPURLResponse 🤷‍♂️"
        case .decode(_, data: _, response: let response, error: let error, expectedType: let expectedType):
            return "The response \(response.debugDescription) passed validation, but its body failed to decode as "
            + "the expected type \(expectedType). Error: \(error.localizedDescription)"
        case .unknown(_, let error):
            return "Terrible inconsistency, should never happen: \(error?.localizedDescription ?? "")"
        case .clientDeallocated:
            return "The client was deallocated during a download"
        case .downloadedFileMoveFailure(_, let error):
            return "Couldn't move the downloaded file to its destination: \(error.localizedDescription)"
        }
    }

    public var localizedDescription: String {
        let requestSuffix = "For request URL: " + (request?.url?.absoluteString ?? "(unknown request)")
        return "\(caseDescription)\n\(requestSuffix)"
    }

    public var validationError: Error? {
        if case .validate(_, _, _, let error) = self {
            return error
        }
        return nil
    }

    public var request: URLRequest? {
        switch self {
        case .modify(let request, _),
                .transport(let request, _),
                .validate(let request, data: _, response: _, error: _),
                .notHttpResponse(let request, _),
                .decode(let request, data: _, response: _, error: _, expectedType: _),
                .clientDeallocated(let request),
                .downloadedFileMoveFailure(let request, _):
            return request
        case .unknown(let request, _):
            return request
        }
    }
}

public extension Error {

    var asRequestError: RequestError {
        self as? RequestError ?? .unknown(nil, self)
    }
}
