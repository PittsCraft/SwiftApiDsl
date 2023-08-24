import Foundation

public struct HttpStatusCodeRangeValidator: ResponseValidator {

    public struct Error: Swift.Error {
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

    public let codeRange: ClosedRange<Int>

    public init(codeRange: ClosedRange<Int> = 200...299) {
        self.codeRange = codeRange
    }

    public func validate(data: Data, response: HTTPURLResponse) throws {
        guard codeRange.contains(response.statusCode) else {
            throw Error(codeRange: codeRange, statusCode: response.statusCode)
        }
    }
}
