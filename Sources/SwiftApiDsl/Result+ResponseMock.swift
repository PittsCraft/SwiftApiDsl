import Foundation

public extension Result<Response<Data>, RequestError> {

    static func response(_ request: URLRequest, body: Data = Data(), statusCode: Int = 200) -> Self {
        let httpResponse = HTTPURLResponse(url: request.url!,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)
        return .success(.init(body: body, httpResponse: httpResponse!))
    }

    static func response<ResponseBody: Encodable>(_ request: URLRequest,
                                                  body: ResponseBody,
                                                  encoder: JSONEncoder = JSONEncoder(),
                                                  statusCode: Int = 200) throws -> Self {
        return response(request, body: try encoder.encode(body))
    }
}
