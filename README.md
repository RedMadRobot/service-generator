# ServiceGenerator

> Binary file can be installed via cocoapods ([link](https://github.com/RedMadRobot/cocoapods-specs)).

> Each time you update repository ensure to draft new release, info can be found [here](https://github.com/RedMadRobot/cocoapods-specs/blob/master/README.md).

This utility generates parsers from model objects. Only works for [HTTP Transport](https://github.com/RedMadRobot/http-transport).

## Example

### How to delare a service

First of all you need to declare a protocol


```swift
/**
 @service
 @url http://server.com/api/entities
 @add_cookies
 @receive_cookies
*/
protocol Service {
}
```

Supported service annotations:

`@service`
Annotate a protocol, a service will be generated upon this.

`@url URL`
Base URL for your service. Service includes this URL as initializer argument.

`@add_cookies`
Service will add Cookie to requests. Cookie is passes in initializer.

`@receive_cookies`
Service will save received Cookie. Cookie is passes in initializer.

### How to declare methods

Methods must return `ServiceCell` or `AuthorizedServiceCall`.
Model object should be annotated with `@model` or you should write `@parser ParserName`.

If yout method return void result just use `ServiceCall<Void>`.

```swift
/**
 @auto_login
 @post
 @url /paginated/{request_id}
*/
func getEntities(
    requestIdentifier: String, // @url request_id
    searchQuery: String,       // @query search
    dateToken: Double,         // @json date_token
    deviceOS: String           // @header X-Att-Deviceos
) -> ServiceCall<[Entity]>
```

Supported method annotations:
`@get, @post, @put, @patch, @delete, @head, @options`.

`@auto_login`
In case of failed request we check existent session. If it absents `Authorizer` try to renew it and repeat original request.
`Authorizer` is passed in initializer.

The next three examples are the same.

```swift
/**
 @get
 @auto_login
*/
func method() -> ServiceCall<Entity>
```

```swift
/**
 @get
*/
func method() -> AuthorizedServiceCall<Entity>
```

```swift
/**
 @get
 @auto_login
*/
func method() -> AuthorizedServiceCall<Entity>
```

`@url URL` relative URL for method based on service URL. This URL can include a template for URL-parameter with format `{parameter_name}`.
Parameters are passed as arguments of method. You need to annotate them with `@url parameter_name`.

`@parser NAME`
Parser name to parse response body into models. Generator takes it from return model type by default.

Supported method annotations:

`@url NAME`
URL parameter to insert in place of `{NAME}`.

`@query NAME`
query parameter with `NAME=`.

`@json NAME`
Параметр требуется передать в JSON-тело запроса под именем "NAME": ...

`@header NAME`
Параметр требуется добавить к запросу в виде заголовка NAME.

`@responseInterceptor NAME`
`HTTPResponseInterceptor` to add to this method only.

`@requestInterceptor NAME`
`HTTPRequestInterceptor` to add this method only.

`@content [json|string]` used for specify type of parser for primitive return type. In case of option `string`, response body parsed as raw string. In case of option `json` (default) response body parsed as JSON and extract first value suitable for returned type.


### Example of EntityService

Let's take a look at typical `EntityService` that obtain model type `Entity`.

```swift
/**
 This is our entity.
 
 This annotation means this is model object
 @model
 */
class Entity {
    /**
     Identifier.
 
     This annotation for another our generator utility - Core Parser Generator
     @json
    */
    let id: Int
}
```
Service protocol

```swift
/**
 Service for our model of type Entity.
 
 Base URL, for model Entity:
 @url https://server.com/api/entities

 We need to be authorized before making requests, so we use Cookie to pass session identifier for each request.
 
 Adding this annotation says we want to add Cookie to each request.
 @add_cookies
 
 Server can send us additional Cookie. This is our duty to save it.
 
 Adding this annotation says we want to save Cookie from each response.
 @receive_cookies
 */
protocol EntityService {
 
    /**
     Obtain Entity by page.
 
 	  In case of expired session, we need to automatically renew it.
     @auto_login
 
     Method is GET /entities, so leave relative URL empty.
     @get
 
     Don't forget to write limit and offset query parameters.
     */
    func getEntities(
        limit: Int,        // @query
        offset: Int        // @query
    ) -> ServiceCall<[Entity]> // return array of Entity
 
    /**
     Obtain Entity by identifier.
 
     Method is GET /entities/{id}
     @get
     @url /{id}
 
     Pay attention how entityId is passed to {id} from URL.
     Internal argument name is id, so this default value for annotation @url.
     */
    func getEntity(
        entityId id: String // @url
    ) -> ServiceCall<Entity> // returns Entity
 
}
```

The result of generator is (comments are written manually for your understanding)

```swift
class EntityServiceGen: EntityService {
 
    let baseURL:    String                 // base URL, that used in EntityServiceGen.baseRequest
    let dependency: ServiceDependency      // requests/response queues, security settings
    var logFilter:  ServiceLogFilter       // log levels
 
    let cookieProvider: CookieProviding    // this property generated regards to annotation @add_cookies – we take cookie from here
    let cookieStorage: CookieStoring       // this property generated regards to annotation @receive_cookies – we store cookie here
    let authorizer: Authorizing            // this property generated regards to annotation @auto_login — getEntities(limit:offset:)
                                           // authorizer repeats authorization and makes error handling
 
    // this is base interceptors for requests
    var baseRequestInterceptors: [HTTPRequestInterceptor] {
        return [
            AddCookieInterceptor(cookieProvider: self.cookieProvider),       // this interceptor generated regards to annotation @add_cookies
            LogRequestInterceptor(logLevel: self.logFilter.requestLogLevel),
        ]
    }
 
    // this is base interceptors for responses
    var baseResponseInterceptors: [HTTPResponseInterceptor] {
        return [
            ReceivedCookieInterceptor(cookieStorage: self.cookieStorage),    // this interceptor generated regards to annotation @receive_cookies
            LogResponseInterceptor(logLevel: self.logFilter.responseLogLevel, isFilteringHeaders: self.logFilter.isFilteringResponseHeaders, headerFilter: self.logFilter.responseHeaderFilter),
        ]
    }
 
    // this is base request for any other request. It usess baseURL
    var baseRequest: HTTPRequest { return HTTPRequest(endpoint: self.baseURL) }
 
    // this is transport with base interceptors, security settings and etc.
    var transport: HTTPTransport { return HTTPTransport(session: self.dependency.session, requestInterceptors: self.baseRequestInterceptors, responseInterceptors: self.baseResponseInterceptors, useDefaultValidation: self.dependency.useDefaultValidation) }
 
    // Initializer
    init(
        dependency: ServiceDependency,
        baseURL: String = "https://server.com/api/entities",   // this is generate from @url annotation @url https://server.com/api/entities
        authorizer: Authorizing,                               // this is generated from @auto_login annotation
        cookieProvider: CookieProviding,                       // this is generated from @add_cookies annotation — this is object with Cookie for requests
        cookieStorage: CookieStoring,                          // this is generated from @receive_cookies annotation — this is object to store Cookie from responses
        logFilter: ServiceLogFilter = ServiceLogFilter()
    ) {
        self.dependency = dependency
        self.baseURL = baseURL
        self.logFilter = logFilter
        self.authorizer = authorizer
        self.cookieProvider = cookieProvider
        self.cookieStorage = cookieStorage
    }
 
    // Helper method
    func createCall<Payload>(main: @escaping ServiceCall<Payload>.Main) -> ServiceCall<Payload> {
        return ServiceCall(operationQueue: self.dependency.operationQueue, callbackQueue: self.dependency.completionQueue, main: main)
    }
 
    // Helper method
    func createAuthorizedCall<Payload>(main: @escaping ServiceCall<Payload>.Main) -> ServiceCall<Payload> {
        return AuthorizedServiceCall(operationQueue: self.dependency.operationQueue, callbackQueue: self.dependency.completionQueue, authorizer: authorizer, main: main)
    }
 
    // override this method to check errors in response
    func verify(response: HTTPResponse) -> NSError? { return nil }
 
    func getEntities(limit: Int, offset: Int) -> AuthorizedServiceCall<[Entity]> {
        return self.createAuthorizedCall() { () -> ServiceCallResult<[Entity]> in     // as a result this will be AuthorizedServiceCall with autologin functionality
            let request: HTTPRequest =
                HTTPRequest(
                    httpMethod: HTTPRequest.HTTPMethod.get,                           // @get method annotation
                    endpoint: "",
                    headers: [:],
                    parameters: [
                        HTTPRequestParameters(parameters: [
                            "limit": limit,                                           // @query annotation for parameter
                            "offset": offset,                                         // @query annotation for parameter
                        ], encoding: HTTPRequestParameters.Encoding.url),             // your parameters serialize to query
                    ],
                    base: self.baseRequest
                )
 
            switch self.transport.send(request: request) {
                case .success(let response):
                    if let error = self.verify(response: response) { return ServiceCallResult.failure(error: error) }
 
                    do {
                        let jsonObject: Any = try response.getJSON()!
                        let payload = EntityParser().parse(jsonObject)                // parser name generated based on Entity name
                        return ServiceCallResult.success(payload: payload)
                    } catch let error {
                        return ServiceCallResult.failure(error: error as NSError)
                    }
 
                case .failure(let error):
                    return ServiceCallResult.failure(error: error)
            }
        }
    }
 
    func getEntity(entityId id: String) -> ServiceCall<Entity> {
        return self.createCall() { () -> ServiceCallResult<Entity> in
            let request: HTTPRequest =
                HTTPRequest(
                    httpMethod: HTTPRequest.HTTPMethod.get,
                    endpoint: "/\(id)",                                               // URL generated from @url /{id} annotation and argument annotation entityId id: String // @url
                    headers: [:], 
                    parameters: [],
                    base: self.baseRequest
                )
 
            switch self.transport.send(request: request) {
                case .success(let response):
                    if let error = self.verify(response: response) { return ServiceCallResult.failure(error: error) }
 
                    do {
                        let jsonObject: Any = try response.getJSON()!
                        let payload = EntityParser().parse(jsonObject).first!     // parser name generated based on Entity name
                        return ServiceCallResult.success(payload: payload)
                    } catch let error {
                        return ServiceCallResult.failure(error: error as NSError)
                    }
 
                case .failure(let error):
                    return ServiceCallResult.failure(error: error)
            }
        }
    }
 
}
```

You can inherit `EntityServiceGen` and redefine the following properties and function

```swift
var baseRequestInterceptors                      // set your own array of base interceptors
var baseResponseInterceptors                     // set your own array of base interceptors
var baseRequest                                  // add some configuration to reauest
var transport                                    // add some configuration too 
func verify(response: HTTPResponse) -> NSError?  // check response for possible error
```

 The next properties are passed in initializer, you don't need to redefine it.

```swift 
let baseURL
let dependency
var logFilter
let cookieProvider
let cookieStorage
let authorizer
```

## Restrictions

* Generator supports only object types and arrays of them. Primitive types, generics, Dictionaries are not supported.

```swift
func getSome() -> ServiceCall<Int>
```
will generate an error.

## Author

Egor Taflanidi, et@redmadrobot.com

## Support team

Ivan Vavilov, iv@redmadrobot.com

Andrey Rozhkov, ar@redmadrobot.com