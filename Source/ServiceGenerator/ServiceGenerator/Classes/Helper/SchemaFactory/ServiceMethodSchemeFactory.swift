//
//  ServiceMethodSchemeFactory.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 22/03/2017.
//  Copyright © 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


class ServiceMethodSchemeFactory {

    func createScheme(
        forMethods methods: [Method],
        availableModelKlasses modelKlasses: [Klass]
    ) throws -> [ServiceMethodScheme] {
        return try methods.map { (method: Method) -> ServiceMethodScheme in
            return try self.createScheme(forMethod: method, availableModelKlasses: modelKlasses)
        }
    }

    func createScheme(forMethod method: Method, availableModelKlasses modelKlasses: [Klass]) throws -> ServiceMethodScheme {
        guard
            let returnType: Typê = method.returnType,
            case Typê.GenericType(let returnTypeName, let returnObjectType) = returnType,
            returnTypeName == "ServiceCall" || returnTypeName == "AuthorizedServiceCall"
        else {
            throw self.generateErrorMessage(
                message: "Method must return a ServiceCall<> or an AuthorizedServiceCall<>",
                declaration: method.declaration
            )
        }

        let parserName:        String
        let returnsCollection: Bool

        if let specifiedParser: String = method.annotations["parser"]?.value {
            parserName = specifiedParser
            if case Typê.ArrayType = returnObjectType {
                returnsCollection = true
            } else {
                returnsCollection = false
            }
        } else if case Typê.ObjectType(let name) = returnObjectType,
                  modelKlasses.contains(klassName: name) || name == "Void" {
            returnsCollection = false
            parserName = name + "Parser"
        } else if returnObjectType.isPrimitive() {
            returnsCollection = false
            if let contentType = method.annotations["content"]?.value,
               contentType == "string" {
                if returnObjectType != .StringType {
                    throw self.generateErrorMessage(
                        message: "Content type and returned object type are not equal. " +
                                 "Use `@content json` or change the type of the returned object to String",
                        declaration: method.declaration)
                }
                parserName = ""
            } else {
                parserName = "SimpleValueJsonParser<\(returnObjectType.description)>"
            }
        } else if case Typê.ArrayType(let itemType) = returnObjectType {
            returnsCollection = true

            if case Typê.ObjectType(let name) = itemType,
               modelKlasses.contains(klassName: name) || name == "Void" {
                parserName = name + "Parser"
            } else {
                throw self.generateErrorMessage(
                    message: "Can only pick a parser for known models",
                    declaration: method.declaration
                )
            }
        } else {
            throw self.generateErrorMessage(
                message: "Can't pick a parser for returned object type, model object is out of scope or not supported",
                declaration: method.declaration
            )
        }

        let httpVerb: ServiceMethodScheme.HTTPVerb = self.getHTTPVerb(forMethod: method)
        let endpoint: String                       = try self.getURLEndpoint(forMethod: method)

        let queryParameters: [ServiceMethodScheme.Parameter] = try self.getParameters(
            fromMethodArguments: method.arguments,
            withAnnotationName: "query",
            canBeOptional: true
        )

        let headers: [ServiceMethodScheme.Parameter] = try self.getParameters(
            fromMethodArguments: method.arguments,
            withAnnotationName: "header",
            canBeOptional: true
        )

        let jsonParameters: [ServiceMethodScheme.Parameter] = try self.getParameters(
            fromMethodArguments: method.arguments,
            withAnnotationName: "json",
            canBeOptional: true
        )

        let plistParameters: [ServiceMethodScheme.Parameter] = try self.getParameters(
            fromMethodArguments: method.arguments,
            withAnnotationName: "plist",
            canBeOptional: true
        )

        let autoLogin: Bool = nil != method.annotations["auto_login"] || returnTypeName == "AuthorizedServiceCall"

        let requestInterceptors: [String] = self.getValues(
            fromMethodAnnotations: method.annotations,
            withAnnotationName: "requestInterceptor"
        )
        
        let responseInterceptors: [String] = self.getValues(
            fromMethodAnnotations: method.annotations,
            withAnnotationName: "responseInterceptor"
        )
        
        return ServiceMethodScheme(
            httpVerb: httpVerb,
            endpoint: endpoint,
            queryParameters: queryParameters,
            headers: headers,
            jsonParameters: jsonParameters,
            plistParameters: plistParameters,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors,
            method: method,
            autoLogin: autoLogin,
            parserName: parserName,
            returnsCollection: returnsCollection,
            returnedTypeName: returnTypeName,
            returnedModelObjectTypeName: String(describing: returnObjectType)
        )
    }

}


private extension ServiceMethodSchemeFactory {

    func getHTTPVerb(forMethod method: Method) -> ServiceMethodScheme.HTTPVerb {
        for annotation in method.annotations {
            switch annotation.name.lowercased() {
                case "delete":
                    return ServiceMethodScheme.HTTPVerb.delete

                case "get":
                    return ServiceMethodScheme.HTTPVerb.get

                case "head":
                    return ServiceMethodScheme.HTTPVerb.head

                case "options":
                    return ServiceMethodScheme.HTTPVerb.options

                case "patch":
                    return ServiceMethodScheme.HTTPVerb.patch

                case "post":
                    return ServiceMethodScheme.HTTPVerb.post

                case "put":
                    return ServiceMethodScheme.HTTPVerb.put

                default: break
            }
        }

        print(
            CompilerMessage(
                line: method.declaration,
                message: "HTTP verb annotation for method not found (e.g. @get). Using @get by default",
                type: CompilerMessage.MessageType.Warning
            )
        )

        return ServiceMethodScheme.HTTPVerb.get
    }

    func generateErrorMessage(message: String, declaration: SourceCodeLine) -> CompilerMessage {
        return CompilerMessage(
            line: declaration,
            message: "[ServiceGenerator] \(message)"
        )
    }

    func getParameters(
        fromMethodArguments arguments: [Argument],
        withAnnotationName annotationName: String,
        canBeOptional: Bool
    ) throws -> [ServiceMethodScheme.Parameter] {
        return try arguments.flatMap { (argument: Argument) -> ServiceMethodScheme.Parameter? in
            if let annotation: Annotation = argument.annotations[annotationName] {
                if !canBeOptional, case Typê.OptionalType = argument.type {
                    throw self.generateErrorMessage(
                        message: "@\(annotationName) parameter cannot be optional",
                        declaration: argument.declaration
                    )
                }

                let placeholderName: String = annotation.value ?? argument.bodyName
                return ServiceMethodScheme.Parameter(
                    placeholderName: placeholderName,
                    argumentName: argument.bodyName,
                    argumentDeclaration: argument.declaration,
                    type: argument.type
                )
            }
            return nil
        }
    }

    func getValues(
        fromMethodAnnotations annotations: [Annotation],
        withAnnotationName annotationName: String
        ) -> [String] {
        return annotations
            .filter{ (annotation: Annotation) -> Bool in annotation.name == annotationName }
            .flatMap { (annotation: Annotation) -> String? in annotation.value }
    }
    
    func fill(url: String, withURLParametersFromMethod method: Method) throws -> String {
        let urlParameters: [ServiceMethodScheme.Parameter] = try self.getParameters(
            fromMethodArguments: method.arguments,
            withAnnotationName: "url",
            canBeOptional: false
        )

        var resultURL: String = url
        try urlParameters.forEach { (parameter: ServiceMethodScheme.Parameter) in
            if resultURL.contains("{\(parameter.placeholderName)}") {
                resultURL = resultURL.replacingOccurrences(
                    of: "{\(parameter.placeholderName)}",
                    with: "\\(\(parameter.argumentName))"
                )
            } else {
                throw self.generateErrorMessage(
                    message: "Can't find placeholder in URL for method argument",
                    declaration: parameter.argumentDeclaration
                )
            }
        }

        return resultURL
    }

    func getURLEndpoint(forMethod method: Method) throws -> String {
        if let url: String = method.annotations["url"]?.value {
            return try self.fill(url: url, withURLParametersFromMethod: method)
        } else {
            return ""
        }
    }

}
