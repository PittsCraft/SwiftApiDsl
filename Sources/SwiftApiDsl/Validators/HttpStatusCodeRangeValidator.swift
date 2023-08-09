import Foundation

public struct HttpStatusCodeRangeValidator: ResponseValidator {

    public let codeRange: ClosedRange<Int>

    public init(codeRange: ClosedRange<Int> = 200...299) {
        self.codeRange = codeRange
    }

    public func validate(data: Data, response: HTTPURLResponse) throws {
        guard codeRange.contains(response.statusCode) else {
            throw ValidationError(message: "Response status code \(response.statusCode) not in range "
                                  + "\(codeRange.lowerBound)-\(codeRange.upperBound) "
                                  + "for url \(response.url?.absoluteString ?? "(nil)")")
        }
    }
}
