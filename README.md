# SwiftApiDsl

✂️ A simple DSL to create `URLRequest`s and API clients concisely.

As opposed to Alamofire and friends, the goal here is to simplify common use cases and let you manage complex ones 
yourself, either by extending this lib or by directly using `URLSession` components: they're well designed enough for
libs to be useless for advanced usage.

Also retry mechanisms are out of the table. Better use 
[SwiftRetrier](https://github.com/PittsCraft/SwiftRetrier) to retry your requests easily and with full control.

## Create an API Client

All you need is a base URL

```swift
let baseUrl = URL(string: "https://google.com")!
let client = ApiClient(baseUrl: baseUrl)
```

## Use it

```swift
// Simple fetch
let profile: Profile = try await client.perform(.get("user/profile")) // `Profile` must conform to `Decodable`

// Post a JSON body
try await client.perform(.post("user/profile"), body: newProfile) // `newProfile`'s type must conform to `Encodable`

// Fetch both parsed JSON body and `HTTPURLResponse`
let (body, response): (Profile, HTTPURLResponse) = try await client.fetchResponse(.get("user/profile"))

// Fetch both `Data` body and `HTTPURLResponse`
let (dataBody, response) = try await client.fetchResponse(.get("user/profile"))

// Add multipart form data
let formData = MultipartFormDataModifier
    .withTextField(named: "id", value: "48")
    .withDataField(named: "file",
                   filename: "file.pdf",
                   data: fileData,
                   mimeType: "application/pdf")

try await client.perform(.post("form").with(formData))

// Download a file
try await client.download(get("user/bills/8"), destination: localDestinationUrl)
```

You can customize your request easily with extra arguments to `.get()`, `.post()` etc... or with `with()` modifiers
 (see below).

A number of options are available through `perform()`, `fetchResponse()` and `download()` functions:
-  provide custom `JSONEncoder` and `JSONDecoder`, note that you can do this for all requests by passing them to the 
`ApiClient` constructor.
- if you provided request modifiers in the constructor, ignore them for a specific request 
using `ignoreDefaultModifiers` (see below for more information on modifiers)
- if you provided request validators in the constructor, ignore them for a specific request using 
`ignoreDefaultValidators`
- add extra validators

## Provide modifiers

Request modifiers can either be passed to an `ApiClient` constructor, or directly applied to a `Request`.

```swift
let apiModifiers = [
    HeaderModifier(value: "MyAppID", headerField: "CustomHeader")
]

let client = ApiClient(baseUrl: baseUrl, modifiers: apiModifiers)
```

In this case, the `HeaderModifier` will be applied to all requests executed by this client, except if you use 
`ignoreDefaultModifiers` argument in your `perform()`, `fetchResponse()` or `download()` call.

By default, no modifier is used by `ApiClient`.

You can implement your own modifiers:

```swift
// Custom modifier that adds an authentication token
class AuthModifier: RequestModifier {
    private let authProvider: AuthProvider

    func modify(_ urlRequest: inout URLRequest) async throws {
        let token = try await authProvider.authToken()
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
```

or build them using `BlockModifier`:

```swift
let authModifier = BlockModifier {
    let token = try await authProvider.authToken()
    $0.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}
```

Note that if a modifier `throws`, then the `perform()`, `fetchResponse()` or `download()` call executing the request
 will rethrow wrapping the error.

There are also multiple `with()` modifiers to help you build your requests smoothly, applying modifiers on specific 
ones:

```swift
let request = Request
                .get("profile")
                .with(queryItems: [
                    "source": "Swift API DSL"
                ])
                .with {
                    // Inline modification, no need to declare a modifier type
                    $0.allowsCellularAccess = false
                }
                .with(AuthModifier())

let profile: Profile = client.perform(request)
```

In some cases, you'll want to add specific modifiers only on some requests, but for authentication, we recommend to add
this modifier to an API client to avoid adding it explicitely to the majority of your requests, and create a separated
`ApiClient` for unauthenticated modifiers.

```swift
let commonModifiers = [
    HeaderModifier(value: "MyAppID", headerField: "CustomHeader")
]
let authModifiers = commonModifiers + [authModifier]

let unauthClient = ApiClient(baseUrl: baseUrl, modifiers: commonModifiers)
let authClient = ApiClient(baseUrl: baseUrl, modifiers: authModifiers) 
```

## Provide validators

Validators will be applied after a request has been executed and can `throw` during `perform()`, `fetchResponse()` or
`download()` calls.
The error will then be wrapped and rethrown. 

```swift
let validators = [
    HttpStatusCodeRangeValidator() // Validates HTTP status code is between 200 and 299 by default
]
let client = ApiClient(baseUrl: baseUrl, validators: validators)
```

By default, this same status code validation is used by `ApiClient` instances.

The validators are executed in the order they are provided:
- first the `ApiClient` validators in the array's order except if you use `ignoreDefaultValidators`
- then the ones provided along with the request in the array's order

Implement your own validator:

```swift
class CustomValidator: ResponseValidator {

    func validate(data: Data, response: HTTPURLResponse) throws {
        guard !data.isEmpty, response.statusCode == 42 else {
            throw MyError()
        }
    }
}

```

## Provide a custom `URLSession`

```swift
let client = ApiClient(urlSession: myCustomSession, baseUrl: baseUrl)
```

By default, `URLSession.shared` is used.

The session is exposed at `client.urlSession`.

## Provide custom `JSONDecoder` and `JSONEncoder`

```swift
let client = ApiClient(baseUrl: baseUrl, jsonEncoder: MyJsonEncoder(), jsonDecoder: MyJsonDecoder())
```

## Get `URLRequest` from `Request`

`Request` is designed to be used with `ApiClient`, but you can still easily get an `URLRequest` from a `Request`:

```swift
let baseUrl = URL(string: "https://google.com")!
let urlRequest: URLRequest = request.toUrlRequest(baseUrl: baseUrl)
```

## Perform on `URLRequest` directly

The same functions `perform()`, `fetchResponse()` and `download()` are available that take an `URLRequest` as first parameter
instead of a `Request`.

```swift

let urlRequest: URLRequest

let profile: Profile = client.perform(urlRequest)

```

## Errors thrown by `ApiClient`

`ApiClient` throws `RequestError`s that wrap source errors helping you identifying at which stage your request failed.

It exposes a qualified error enum embedding the source `URLRequest`:

```swift
public enum RequestError: Error {

    /// Error thrown by a modifier
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
    let profile = try await client.perform(.get("user/profile"))
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

## Contribute

Feel free to make any comment, criticism, bug report or feature request using Github issues.
You can also directly send me an email at `pierre` *strange "a" with a long round tail* `pittscraft.com`.

## License

SwiftRetrier is available under the MIT license. See the LICENSE file for more info.
