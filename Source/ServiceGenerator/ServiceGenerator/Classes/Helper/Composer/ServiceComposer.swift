//
//  ServiceComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 10/04/2017.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


class ServiceComposer: Composer {

    let serviceSuffix: String = "Gen"

    override func composeEntityUtilityFilename(forEntityKlass entityKlass: Klass) -> String {
        return entityKlass.name + serviceSuffix + ".swift"
    }

    override func composeImports() -> String {
        return super.composeImports()
                    .addLine("import CoreParser")
                    .addLine("import HTTPTransport")
    }

    override func composeUtilitySourceCode(
        forEntityKlass entityKlass: Klass,
        availableEntityKlasses entityKlasses: [Klass]
    ) throws -> String {
        let serviceScheme: ServiceScheme = try ServiceSchemeFactory().createSchema(
            forService: entityKlass,
            availableModels: entityKlasses,
            nameSuffix: serviceSuffix
        )

        let declaration: String = self.composeDeclaration(forServiceScheme: serviceScheme)
        let properties:  String = self.composeProperties(forServiceScheme: serviceScheme)
        let methods:     String = self.composeMethods(forServiceScheme: serviceScheme)

        return ""
            .addLine(declaration)
            .addBlankLine()
            .append(properties.indent())
            .addBlankLine()
            .append(methods.indent())
            .addLine("}")
    }

}

private extension ServiceComposer {

    func composeDeclaration(forServiceScheme serviceScheme: ServiceScheme) -> String {
        return "class \(serviceScheme.name): \(serviceScheme.parent) {"
    }

    func composeProperties(forServiceScheme serviceScheme: ServiceScheme) -> String {
        let cookieProviderProperty: String
        if serviceScheme.addCookies {
            cookieProviderProperty = "\nlet cookieProvider: CookieProviding"
        } else {
            cookieProviderProperty = ""
        }

        let cookieStorageProperty: String
        if serviceScheme.receiveCookies {
            cookieStorageProperty = "\nlet cookieStorage: CookieStoring"
        } else {
            cookieStorageProperty = ""
        }

        let authorizerProperty: String
        if serviceScheme.needsAuthorizer {
            authorizerProperty = "\nlet authorizer: Authorizing"
        } else {
            authorizerProperty = ""
        }

        let computedProperties: String = self.composeComputedProperties(forServiceScheme: serviceScheme)

        return ""
            .addLine("let baseURL:    String")
            .addLine("let dependency: ServiceDependency")
            .addLine("var logFilter:  ServiceLogFilter")
            .append(cookieProviderProperty)
            .append(cookieStorageProperty)
            .append(authorizerProperty)
            .addBlankLine()
            .addBlankLine()
            .append(computedProperties)
    }

    func composeMethods(forServiceScheme serviceScheme: ServiceScheme) -> String {
        let initializer:       String = self.composeInitializer(forServiceScheme: serviceScheme)
        let createCallMethods: String = self.composeCreateCallMethods(forServiceScheme: serviceScheme)

        let serviceMethods: String = ServiceMethodComposer().composeMethods(withMethodSchemes: serviceScheme.methods)

        return ""
            .append(initializer)
            .addBlankLine()
            .append(createCallMethods)
            .addBlankLine()
            .addLine("func verify(response: HTTPResponse) -> NSError? { return nil }")
            .addBlankLine()
            .append(serviceMethods)
    }

    func composeComputedProperties(forServiceScheme serviceScheme: ServiceScheme) -> String {
        var baseRequestInterceptors: String
        if serviceScheme.addCookies {
            baseRequestInterceptors = "AddCookieInterceptor(cookieProvider: self.cookieProvider),\n"
        } else {
            baseRequestInterceptors = ""
        }

        baseRequestInterceptors = baseRequestInterceptors.addLine(
            "LogRequestInterceptor(logLevel: self.logFilter.requestLogLevel),"
        )

        let returnBaseRequestInterceptors: String = ""
            .addLine("return [")
            .append(baseRequestInterceptors.indent())
            .addLine("]")

        let baseRequestInterceptorsProperty: String = ""
            .addLine("var baseRequestInterceptors: [HTTPRequestInterceptor] {")
            .append(returnBaseRequestInterceptors.indent())
            .addLine("}")

        var baseResponseInterceptors: String
        if serviceScheme.receiveCookies {
            baseResponseInterceptors = "ReceivedCookieInterceptor(cookieStorage: self.cookieStorage),\n"
        } else {
            baseResponseInterceptors = ""
        }

        baseResponseInterceptors = baseResponseInterceptors.addLine(
            "LogResponseInterceptor(logLevel: self.logFilter.responseLogLevel, isFilteringHeaders: self.logFilter.isFilteringResponseHeaders, headerFilter: self.logFilter.responseHeaderFilter),"
        )

        let returnBaseResponseInterceptors: String = ""
            .addLine("return [")
            .append(baseResponseInterceptors.indent())
            .addLine("]")

        let baseResponseInterceptorsProperty: String = ""
            .addLine("var baseResponseInterceptors: [HTTPResponseInterceptor] {")
            .append(returnBaseResponseInterceptors.indent())
            .addLine("}")

        return ""
            .append(baseRequestInterceptorsProperty)
            .addBlankLine()
            .append(baseResponseInterceptorsProperty)
            .addBlankLine()
            .addLine("var baseRequest: HTTPRequest { return HTTPRequest(endpoint: self.baseURL) }")
            .addBlankLine()
            .addLine(
                "var transport: HTTPTransport { return HTTPTransport(session: self.dependency.session, requestInterceptors: self.baseRequestInterceptors, responseInterceptors: self.baseResponseInterceptors, useDefaultValidation: self.dependency.useDefaultValidation) }"
            )
    }

    func composeCreateCallMethods(forServiceScheme serviceScheme: ServiceScheme) -> String {
        let createCallMethod: String = ""
            .addLine("func createCall<Payload>(main: @escaping ServiceCall<Payload>.Main) -> ServiceCall<Payload> {")
            .addLine(
                "    return ServiceCall(operationQueue: self.dependency.operationQueue, callbackQueue: self.dependency.completionQueue, main: main)"
            )
            .addLine("}")

        let createAuthorizedCallMethod: String
        if serviceScheme.needsAuthorizer {
            createAuthorizedCallMethod = ""
                .addLine(
                    "func createAuthorizedCall<Payload>(main: @escaping ServiceCall<Payload>.Main) -> ServiceCall<Payload> {"
                )
                .addLine(
                    "    return AuthorizedServiceCall(operationQueue: self.dependency.operationQueue, callbackQueue: self.dependency.completionQueue, authorizer: authorizer, main: main)"
                )
                .addLine("}")
        } else {
            createAuthorizedCallMethod = ""
        }

        return ""
            .append(createCallMethod)
            .addBlankLine()
            .append(createAuthorizedCallMethod)
    }

    func composeInitializer(forServiceScheme serviceScheme: ServiceScheme) -> String {
        let baseURLDefaultValue: String
        if let baseURL: String = serviceScheme.baseURL {
            baseURLDefaultValue = " = \"\(baseURL)\""
        } else {
            baseURLDefaultValue = ""
        }

        let initializerParameters: String = ""
            .addLine("dependency: ServiceDependency,")
            .addLine("baseURL: String\(baseURLDefaultValue),")
            .append(serviceScheme.needsAuthorizer ? "authorizer: Authorizing,\n" : "")
            .append(serviceScheme.addCookies ? "cookieProvider: CookieProviding,\n" : "")
            .append(serviceScheme.receiveCookies ? "cookieStorage: CookieStoring,\n" : "")
            .addLine("logFilter: ServiceLogFilter = ServiceLogFilter()")

        let initializerBody: String = ""
            .addLine("self.dependency = dependency")
            .addLine("self.baseURL = baseURL")
            .addLine("self.logFilter = logFilter")
            .append(serviceScheme.needsAuthorizer ? "self.authorizer = authorizer\n" : "")
            .append(serviceScheme.addCookies ? "self.cookieProvider = cookieProvider\n" : "")
            .append(serviceScheme.receiveCookies ? "self.cookieStorage = cookieStorage\n" : "")

        return ""
            .addLine("init(")
            .append(initializerParameters.indent())
            .addLine(") {")
            .append(initializerBody.indent())
            .addLine("}")
    }

}
