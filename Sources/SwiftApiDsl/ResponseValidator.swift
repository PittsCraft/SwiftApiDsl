import Foundation

public protocol ResponseValidator {

    func validate(data: Data, response: HTTPURLResponse) throws
}
