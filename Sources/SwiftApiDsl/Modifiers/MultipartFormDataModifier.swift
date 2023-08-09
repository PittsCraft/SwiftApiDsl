import Foundation

// Adapted from https://orjpap.github.io/swift/http/ios/urlsession/2021/04/26/Multipart-Form-Requests.html

public class MultipartFormDataModifier: RequestModifier {
    public static let defaultCharset = "ISO-8859-1"
    public static let defaultTransferEncoding = "8bit"
    private let boundary: String = UUID().uuidString
    private var httpBody = Data()

    public init() {}

    public func withTextField(named name: String,
                              value: String,
                              charset: String = defaultCharset,
                              transferEncoding: String = defaultTransferEncoding) -> Self {
        httpBody.append(textFormField(named: name, value: value, charset: charset, transferEncoding: transferEncoding))
        return self
    }

    private func textFormField(named name: String, value: String, charset: String, transferEncoding: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=\(charset)\r\n"
        fieldString += "Content-Transfer-Encoding: \(transferEncoding)\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    public func withDataField(named name: String, filename: String? = nil, data: Data, mimeType: String) -> Self {
        httpBody.append(dataFormField(named: name, filename: filename, data: data, mimeType: mimeType))
        return self
    }

    private func dataFormField(named name: String,
                               filename: String?,
                               data: Data,
                               mimeType: String) -> Data {
        var fieldData = Data()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"")
        if let filename {
            fieldData.append("; filename=\"\(filename)\"")
        }
        fieldData.append("\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }

    public func modify(_ urlRequest: inout URLRequest) async throws {
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var fullBody = httpBody
        fullBody.append("--\(boundary)--")
        urlRequest.httpBody = fullBody
    }
}

public extension MultipartFormDataModifier {

    static func withTextField(named name: String,
                              value: String,
                              charset: String = defaultCharset,
                              transferEncoding: String = defaultTransferEncoding) -> MultipartFormDataModifier {
        MultipartFormDataModifier()
            .withTextField(named: name, value: value, charset: charset, transferEncoding: transferEncoding)
    }

    static func withDataField(named name: String,
                              filename: String? = nil,
                              data: Data,
                              mimeType: String) -> MultipartFormDataModifier {
        MultipartFormDataModifier()
            .withDataField(named: name, filename: filename, data: data, mimeType: mimeType)
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
