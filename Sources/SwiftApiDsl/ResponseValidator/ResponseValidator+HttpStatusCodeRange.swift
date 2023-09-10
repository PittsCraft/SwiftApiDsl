import Foundation

public extension ResponseValidator {

    struct HttpStatusCodeRangeError: Swift.Error {
        public let codeRange: ClosedRange<Int>
        public let statusCode: Int

        public init(codeRange: ClosedRange<Int>, statusCode: Int) {
            self.codeRange = codeRange
            self.statusCode = statusCode
        }

        public var localizedDescription: String {
            "Response status code \(statusCode) not in range "
            + "\(codeRange.lowerBound)-\(codeRange.upperBound) "
        }
    }

    static func httpStatusCodeRange(_ codeRange: ClosedRange<Int>) -> ResponseValidator {
        ResponseValidator { response in
            guard codeRange.contains(response.httpResponse.statusCode) else {
                throw HttpStatusCodeRangeError(codeRange: codeRange, statusCode: response.httpResponse.statusCode)
            }
        }
    }
}
