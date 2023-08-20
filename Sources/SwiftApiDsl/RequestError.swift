import Foundation

public struct RequestError: Error {

    public enum Wrapped: Error {
        /// Error thrown by a modifier
        case modify(Error)
        /// Error thrown when performing the actual URLRequest
        case transport(Error)
        /// Error thrown by a validator
        case validate(data: Data, response: HTTPURLResponse, error: Error)
        /// The URLResponse of the request is not an HTTPURLResponse 🤷‍♂️
        case notHttpResponse(URLResponse?)
        /// The response passed validation, but its body failed to decode as the expected type
        case decode(data: Data, response: HTTPURLResponse, error: Error, expectedType: Any.Type)
        /// Terrible inconsistency, should never happen
        case unknown(Error?)
        /// The client was deallocated during a download
        case clientDeallocated
        /// Couldn't move the downloaded file to its destination
        case downloadedFileMoveFailure(Error)

        public var localizedDescription: String {
            switch self {
            case .modify(let error):
                return "Error thrown by a modifier: \(error.localizedDescription)"
            case .transport(let error):
                return "Error thrown when performing the request: \(error.localizedDescription)"
            case .validate(data: _, response: let response, error: let error):
                return "Validation error: \(error.localizedDescription). Response: \(response.debugDescription)"
            case .notHttpResponse(let urlResponse):
                return "The URLResponse \(urlResponse?.debugDescription ?? "(nil)") of the request is not an "
                + "HTTPURLResponse 🤷‍♂️"
            case .decode(data: _, response: let response, error: let error, expectedType: let expectedType):
                return "The response \(response.debugDescription) passed validation, but its body failed to decode as "
                + "the expected type \(expectedType). Error: \(error.localizedDescription)"
            case .unknown(let error):
                return "Terrible inconsistency, should never happen: \(error?.localizedDescription ?? "")"
            case .clientDeallocated:
                return "The client was deallocated during a download"
            case .downloadedFileMoveFailure(let error):
                return "Couldn't move the downloaded file to its destination: \(error.localizedDescription)"
            }
        }
    }

    public let request: URLRequest?
    public let wrapped: Wrapped

    public var localizedDescription: String {
        "Error: \(wrapped.localizedDescription) for request: \(request.debugDescription)"
    }

    public init(request: URLRequest?, wrapped: Wrapped) {
        self.request = request
        self.wrapped = wrapped
    }
}

public extension Error {

    var asRequestError: RequestError {
        self as? RequestError ?? RequestError(request: nil, wrapped: .unknown(self))
    }
}
