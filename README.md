# SwiftApiDsl

✂️ A lightweight and concise API client DSL.

The goal of this library is to provide a concise, easy to use and discoverable DSL to perform any request that stays 
open to any customization.

This implies a small number of feature to help your structure your API client:
- centralize base path and common configuration in a client
- straightforward JSON encoding and decoding
- simple and generic authentication mechanism
- singular requests customization
- intuitive error qualification

If you know Alamofire, this lib has some similarities except it's way smaller and stays closer to `URLRequest` - you
don't need to learn much to use it efficiently.

As a side note, retry mechanisms are out of the table. Better use 
[SwiftRetrier](https://github.com/PittsCraft/SwiftRetrier) to retry your requests easily and with full control.

## Create an API Client

All you need is a base URL

```swift
let baseUrl = URL(string: "https://my-domain.com")!
let client = ApiClient(baseUrl: baseUrl)
    .httpStatusCodeRange() // Validator ensuring status code is in 200..<300
```

## Use it

```swift
// Simple fetch
let profile: Profile = try await client.get("user/profile").perform() // `Profile` must conform to `Decodable`

// Post a JSON body
try await client.post("user/profile", body: newProfile).perform() // `newProfile`'s type must conform to `Encodable`

// Fetch both parsed JSON body and `HTTPURLResponse`
let response: Response<Profile> = try await client.get("user/profile").perform()

// Fetch both `Data` body and `HTTPURLResponse`
let response: Response<Data> = try await client.get("user/profile").perform()

// Add query items
let response: Response<Profile> = try await client
    .get("user/profile")
    .queryItem(name: "context", "new-user") // One by one
    .queryItems([ // Or all at once
        "user": "48",
        "flow": "signUp"
    ])
    .perform()

// Add multipart form data
let response: Profile = try await client
    .post("user/documents")
    .multipartFormData {
        TextField(name: "type", value: "driver-license")
        DataField(name: "file",
                  filename: "file.pdf",
                  data: fileData,
                  mimeType: "application/pdf")
    }
    .perform()

// Download a file
try await client.get("user/bills/8").download(destination: localDestinationUrl)
```

Numerous built-in modifiers are available, you can discover them easily using your IDE's completion.

## Authentication

You can provide a request modifier that injects authentication.

```swift
// Using a built-in modifier asynchronously
let client = ApiClient(baseUrl: baseUrl)
    .authentication {
        let token = try await getToken()
        return .bearer(token)
    }

// Or a custom one
let client = ApiClient(baseUrl: baseUrl)
    .authentication {
        let token = try await getToken()
        $0.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

// Authenticated
let profile: Profile = client.get("user/profile").perform()

// Unauthenticated
let news: News = client.get("news", bypassAuth: true).perform()
```

## Advanced Usage

You can fully customize your client

```swift
// Pass custom attributes
let client = ApiClient(urlSession: customSession, 
                       baseUrl: baseUrl,
                       jsonEncoder: customEncoder,
                       jsonDecoder: customDecoder)
    // Use built-in request modifiers
    .userAgent("my-app/5.0.1")
    .allowsCellularAccess(false)
    .timeoutInterval(8)
    // Custom URLRequest modifier
    .modifier { // You can try and await in all modifiers
        $0.cachePolicy = .reloadIgnoringLocalCacheData
    }
    // Custom validator
    .validator {
        if $0.httpResponse.value(forHTTPHeaderField: "Custom-Header") == nil {
            throw MyError()
        }
    }
```

and your requests

```swift
let news: News = client
    .get("news", bypassAuth: true, body: someEncodable, jsonEncoder: customEncoder)
    .allowsCellularAccess(false) // Use built-in modifiers
    .modifier { // Or custom ones
        $0.cachePolicy = .reloadIgnoringLocalCacheData
    }
    .validator { // Add custom validation
        if $0.body.isEmpty, $0.httpResponse.statusCode == 202 {
            throw MyCustomError()
        }
    }
    .perform(jsonDecoder: customDecoder)
}

```

## Errors thrown by `ApiClient`

`ApiClient` throws `RequestError`s that wrap source errors helping you identify at which stage your request failed.

It exposes a qualified error enum embedding the source `URLRequest`:

```swift
public enum RequestError: Error {

    /// Error thrown by a modifier (including authentication one)
    case modify(URLRequest, Error)
    /// Error thrown when performing the actual URLRequest
    case transport(URLRequest, Error)
    /// Error thrown by a validator
    case validate(URLRequest, data: Data, response: HTTPURLResponse, error: Error)
    /// Exotic error that should be considered as fatal, can be a JSON decoding one for example,
    /// switch on nested error if you need to discriminate.
    case fatal(FatalError)
}
```

You can easily check it:

```swift
do {
    let profile: Profile = try await client.get("user/profile").perform()
} catch {
    let requestError = error.asRequestError
    
    switch requestError {
        case .transport(_, let sourceError):
            print("transport error: \(sourceError.localizedDescription)")
        default:
            print("other error")
    }

    // Priviledged access to validation error
    if let myError = requestError.validationError as? MyError {
        print("MyError was thrown during validation")
    }

    // Rich description of the error, including request URL for traceability
    print(requestError.localizedDescription)
}
```

## Extend

If you use custom request modifiers or response validators in multiple places, you can add them to the DSL easily.

This will make them easily discoverable by completion and available in client and request building.

### Custom Modifier

```swift

extension RequestModifier {

    static func customModifier() -> RequestModifier {
        .init {
            $0.cachePolicy = .reloadIgnoringLocalCacheData
        }
    }
}

extension RequestModifiable {

    func customModifier() -> Self {
        modifier(.customModifier())
    }
}
```

### Custom Validator

```swift

extension ResponseValidator {

    static func customValidator() -> ResponseValidator {
        .init {
            if $0.body.isEmpty, $0.httpResponse.statusCode == 202 {
                throw MyCustomError()
            }
        }
    }
}

extension ResponseValidatable {

    func customValidator() -> Self {
        validator(.customValidator())
    }
}

```

## Mock

To get a mocked client:

```swift
// Use an existing instance
let mockedClient = client.mocked()
```

Beware: all modifiers will be applied (including authentication one).
If they can throw unexpectedly, better create a fresh instance without undesired modifiers.

```swift
// Create a fresh mocked client
let mockedClient = ApiClientMock(baseUrl: someUrl)
```

None of the requests performed on this client will reach the network.

Validators will not be applied, leaving you free to throw any `RequestError` case.

By default all responses will be mocked with empty data and an empty `200` HTTP response. 
This means that if you don't customize responses, decoding bodies will always throw.

To provide custom responses:

```swift
let profile: Profile // Decodable

mockedClient.resultProvider = { urlRequest in
    guard let url = urlRequest.url else { return nil }
    
    if url.path.contains("user/profile") {
        // Provide a response with a valid encoded body
        if urlRequest.httpMethod == "GET" { 
            return .response(request, body: profile) // response helper, default status code 200
        }
        // Throw a RequestError on this one
        if urlRequest.httpMethod == "POST" {
            return .failure(.transport(request, SomeError()))
        }
        // Fully customize the response
        if urlRequest.httpMethod == "PUT" {
            let httpResponse = HTTPURLResponse(url: url, 
                                               statusCode: 201,
                                               httpVersion: nil,
                                               headerFields: ["CustomHeader": "8"])
            return .success(.init(body: someData, httpResponse: httpResponse!))
        }
    }
    let httpResponse = HTTPURLResponse(url: $0.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return .success(Response(body: Data(), httpResponse: httpResponse!))
}
```

## Contribute

Feel free to make any comment, criticism, bug report or feature request using Github issues.
You can also directly send me an email at `pierre` *strange "a" with a long round tail* `pittscraft.com`.

## License

SwiftApiDsl is available under the MIT license. See the LICENSE file for more info.
