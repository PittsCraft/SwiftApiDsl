import Foundation

// Adapted from https://orjpap.github.io/swift/http/ios/urlsession/2021/04/26/Multipart-Form-Requests.html

public extension RequestModifier {

    static func multipartFormData(
        @MultiPartFormDataBuilder _ fields: @escaping () -> [MultiPartFormDataField]
    ) -> RequestModifier {
        .init {
            var body = Data()
            let boundary = UUID().uuidString
            fields().forEach {
                body.append($0.asData(boundary: boundary))
            }
            body.append("--\(boundary)--")

            $0.httpBody = body
            $0.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        }
    }
}

public extension RequestModifiable {

    func  multipartFormData(
        @MultiPartFormDataBuilder _ fields: @escaping () -> [MultiPartFormDataField]
    ) -> Self {
        modifier(.multipartFormData(fields))
    }
}

public protocol MultiPartFormDataField {
    func asData(boundary: String) -> Data
}

public struct DataField: MultiPartFormDataField {
    let name: String
    let filename: String?
    let data: Data
    let mimeType: String

    public init(name: String, filename: String? = nil, data: Data, mimeType: String) {
        self.name = name
        self.filename = filename
        self.data = data
        self.mimeType = mimeType
    }

    public func asData(boundary: String) -> Data {
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
}

public struct TextField: MultiPartFormDataField {
    public static let defaultCharset = "ISO-8859-1"
    public static let defaultTransferEncoding = "8bit"

    let name: String
    let value: String
    let charset: String
    let transferEncoding: String

    public init(name: String,
                value: String,
                charset: String = defaultCharset,
                transferEncoding: String = defaultTransferEncoding) {
        self.name = name
        self.value = value
        self.charset = charset
        self.transferEncoding = transferEncoding
    }

    public func asData(boundary: String) -> Data {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=\(charset)\r\n"
        fieldString += "Content-Transfer-Encoding: \(transferEncoding)\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString.data(using: .utf8) ?? Data()
    }
}

@resultBuilder
public struct MultiPartFormDataBuilder {

    public static func buildBlock(_ components: MultiPartFormDataField...) -> [MultiPartFormDataField] {
        components
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
