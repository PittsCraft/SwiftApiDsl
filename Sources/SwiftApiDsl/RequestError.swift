import Foundation

public struct RequestError: Error {

    public enum ErrorWrapper: Error {
        /// Error thrown by a modifier
        case requestModifierError(Error)
        /// Error thrown when performing the actual URLRequest
        case transportError(Error)
        /// Error thrown by a validator
        case validationError(data: Data, response: HTTPURLResponse, error: Error)
        /// The URLResponse of the request is not an HTTPURLResponse 🤷‍♂️
        case notHttpResponse(URLResponse?)
        /// Terrible inconsistency, should never happen
        case unknown(Error?)
        /// The client was deallocated during a download
        case clientDeallocated
        /// Couldn't move the downloaded file to its destination
        case downloadedFileMoveFailure(Error)

        public var localizedDescription: String {
            switch self {
            case .requestModifierError(let error):
                return "Error thrown by a modifier: \(error.localizedDescription)"
            case .transportError(let error):
                return "Error thrown when performing the request: \(error.localizedDescription)"
            case .validationError(data: _, response: let response, error: let error):
                return "Validation error: \(error.localizedDescription). Response: \(response.debugDescription)"
            case .notHttpResponse(let urlResponse):
                return "The URLResponse \(urlResponse?.debugDescription ?? "(nil)") of the request is not an "
                + "HTTPURLResponse 🤷‍♂️"
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
    public let error: ErrorWrapper

    public var localizedDescription: String {
        "Error: \(error.localizedDescription) for request: \(request.debugDescription)"
    }

    public init(request: URLRequest?, error: ErrorWrapper) {
        self.request = request
        self.error = error
    }
}

public extension Error {

    var asRequestError: RequestError {
        self as? RequestError ?? RequestError(request: nil, error: .unknown(self))
    }
}
