import Foundation

public struct Response<Body> {
    public let body: Body
    public let httpResponse: HTTPURLResponse

    public init(body: Body, httpResponse: HTTPURLResponse) {
        self.body = body
        self.httpResponse = httpResponse
    }
}
