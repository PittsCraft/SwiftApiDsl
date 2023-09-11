import Foundation

public extension ResponseValidator {

    struct HttpStatusCodeRangeError: Swift.Error {
        public let codeRange: Range<Int>
        public let statusCode: Int

        public init(codeRange: Range<Int>, statusCode: Int) {
            self.codeRange = codeRange
            self.statusCode = statusCode
        }

        public var localizedDescription: String {
            "Response status code \(statusCode) not in range "
            + "\(codeRange.lowerBound)-\(codeRange.upperBound) "
        }
    }

    static func httpStatusCodeRange(_ codeRange: Range<Int> = 200..<300) -> ResponseValidator {
        .init { response in
            guard codeRange.contains(response.httpResponse.statusCode) else {
                throw HttpStatusCodeRangeError(codeRange: codeRange, statusCode: response.httpResponse.statusCode)
            }
        }
    }
}

public extension ResponseValidatable {
    func httpStatusCodeRange(_ codeRange: Range<Int> = 200..<300) -> Self {
        validator(.httpStatusCodeRange(codeRange))
    }
}
