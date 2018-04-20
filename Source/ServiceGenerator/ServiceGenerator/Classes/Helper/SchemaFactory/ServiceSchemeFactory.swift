//
//  ServiceSchemeFactory.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 22/03/2017.
//  Copyright © 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


class ServiceSchemeFactory {

    func createSchema(
        forService service: Klass,
        availableModels: [Klass],
        nameSuffix: String
    ) throws -> ServiceScheme {
        let baseURL:         String? = self.getBaseURL(forService: service)
        let needsAuthorizer: Bool    = self.detectServiceNeedsAuthorizer(service)
        let addCookies:      Bool    = service.annotations.contains(annotationName: "add_cookies")
        let receiveCookies:  Bool    = service.annotations.contains(annotationName: "receive_cookies")

        let methods: [ServiceMethodScheme] = try ServiceMethodSchemeFactory().createScheme(
            forMethods: service.methods,
            availableModelKlasses: availableModels
        )

        return ServiceScheme(
            name: service.name + nameSuffix,
            parent: service.name,
            baseURL: baseURL,
            addCookies: addCookies,
            receiveCookies: receiveCookies,
            needsAuthorizer: needsAuthorizer,
            methods: methods
        )
    }

}


private extension ServiceSchemeFactory {

    func getBaseURL(forService service: Klass) -> String? {
        if let baseUrl: String = service.annotations["url"]?.value {
            return baseUrl
        }

        return nil
    }

    func detectServiceNeedsAuthorizer(_ service: Klass) -> Bool {
        let result =
            0 < self.findRequests(inService: service, annotatedWith: "auto_login").count
            || 0 < self.findRequests(inService: service, withReturnTypeName: "AuthorizedServiceCall").count
        return result
    }

    func findRequests(inService service: Klass, annotatedWith annotation: String) -> [Method] {
        return service.methods.filter { (method: Method) -> Bool in
            return nil != method.annotations[annotation]
        }
    }

    func findRequests(inService service: Klass, withReturnTypeName wantedReturnTypeName: String) -> [Method] {
        return service.methods.filter { (method: Method) -> Bool in
            if let returnType: Typê = method.returnType,
               case Typê.GenericType(let returnTypeName, _) = returnType, returnTypeName == wantedReturnTypeName {
                return true
            }
            return false
        }
    }

    func generateErrorMessage(message: String, declaration: SourceCodeLine) -> CompilerMessage {
        return CompilerMessage(
            line: declaration,
            message: "[ServiceGenerator] \(message)"
        )
    }

}
