//
//  ServiceMethodCallComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 5/23/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


class ServiceMethodCallComposer {

    func composeCallBody(forScheme methodScheme: ServiceMethodScheme) -> String {
        let scopeVariablesDeclaration: String = self.composeScopeVariablesDeclaration(forMethodScheme: methodScheme)
        let scopeVariablesFill:        String = self.composeScopeVariablesFill(forMethodScheme: methodScheme)
        let httpRequest:               String = self.composeHTTPRequest(forMethodScheme: methodScheme)
        let switchResult:              String = self.composeResultSwitch(forMethodScheme: methodScheme)

        return ""
            .append(scopeVariablesDeclaration)
            .addBlankLine()
            .append(scopeVariablesFill)
            .addLine("let request: HTTPRequest =")
            .append(httpRequest.indent())
            .addBlankLine()
            .append(switchResult)
    }

}

private extension ServiceMethodCallComposer {

    func composeScopeVariablesDeclaration(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        
        let headersDecl = methodScheme.containsHeaders ? "var" : "let"
        let parametersDecl = methodScheme.containsRequestParameters ? "var" : "let"
        let requestInterceptorsDecl = methodScheme.containsRequestInterceptors ? "var" : "let"
        let responseInterceptorsDecl = methodScheme.containsResponseInterceptors ? "var" : "let"
        
        return ""
            .addLine("\(headersDecl) headers:    [String: String]        = [:]")
            .addLine("\(parametersDecl) parameters: [HTTPRequestParameters] = []")
            .addLine("\(requestInterceptorsDecl) requestInterceptors:  [HTTPRequestInterceptor]  = []")
            .addLine("\(responseInterceptorsDecl) responseInterceptors: [HTTPResponseInterceptor] = []")
    }

    func composeScopeVariablesFill(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        let headersFill:    String = self.composeHeadersFill(headers: methodScheme.headers)
        let parametersFill: String = self.composeParametersFill(forMethodScheme: methodScheme)
        let interceptorsFill: String = self.composeInterceptorsFill(forMethodScheme: methodScheme)
        
        return ""
            .append(headersFill)
            .append(parametersFill)
            .append(interceptorsFill)
    }

    func composeHeadersFill(headers: [ServiceMethodScheme.Parameter]) -> String {
        var result: String = ""
        headers.forEach { (header: ServiceMethodScheme.Parameter) in
            result += self.composeFill(forParameter: header, scopeVariable: "headers")
        }

        if !headers.isEmpty { result += "\n" }
        return result
    }

    func composeParametersFill(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        var result: String = ""

        if !methodScheme.queryParameters.isEmpty {
            result = result.addLine(
                "let queryParameters: HTTPRequestParameters = HTTPRequestParameters(parameters: [:], encoding: HTTPRequestParameters.Encoding.url)"
            )
            methodScheme.queryParameters.forEach { (parameter: ServiceMethodScheme.Parameter) in
                result += self.composeFill(forParameter: parameter, scopeVariable: "queryParameters")
            }
            result = result.addLine("parameters.append(queryParameters)").addBlankLine()
        }

        if !methodScheme.jsonParameters.isEmpty {
            result = result.addLine(
                "let jsonParameters: HTTPRequestParameters = HTTPRequestParameters(parameters: [:], encoding: HTTPRequestParameters.Encoding.json)"
            )
            methodScheme.jsonParameters.forEach { (parameter: ServiceMethodScheme.Parameter) in
                result += self.composeFill(forParameter: parameter, scopeVariable: "jsonParameters")
            }
            result = result.addLine("parameters.append(jsonParameters)").addBlankLine()
        }

        if !methodScheme.plistParameters.isEmpty {
            result = result.addLine(
                "let plistParameters: HTTPRequestParameters = HTTPRequestParameters(parameters: [:], encoding: HTTPRequestParameters.Encoding.propertyList)"
            )
            methodScheme.plistParameters.forEach { (parameter: ServiceMethodScheme.Parameter) in
                result += self.composeFill(forParameter: parameter, scopeVariable: "plistParameters")
            }
            result = result.addLine("parameters.append(plistParameters)").addBlankLine()
        }

        return result
    }
    
    func composeInterceptorsFill(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        var result: String = ""
        
        if !methodScheme.requestInterceptors.isEmpty {
            methodScheme.requestInterceptors.forEach { (interceptor: String) in
                result = result.addLine("requestInterceptors.append(\(interceptor)())")
            }
            result = result.addBlankLine()
        }
        
        if !methodScheme.responseInterceptors.isEmpty {
            methodScheme.responseInterceptors.forEach { (interceptor: String) in
                result = result.addLine("responseInterceptors.append(\(interceptor)())")
            }
            result = result.addBlankLine()
        }
        
        return result
    }

    func composeFill(forParameter parameter: ServiceMethodScheme.Parameter, scopeVariable: String) -> String {
        if case Typê.OptionalType = parameter.type {
            return ""
                .addLine("if let \(parameter.argumentName) = \(parameter.argumentName) {")
                .addLine("\(scopeVariable)[\"\(parameter.placeholderName)\"] = \(parameter.argumentName)".indent())
                .addLine("}")
        } else {
            return "".addLine("\(scopeVariable)[\"\(parameter.placeholderName)\"] = \(parameter.argumentName)")
        }
    }

    func composeHTTPRequest(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        let httpRequestParameters: String = self.composeHTTPRequestArguments(forMethodScheme: methodScheme)

        return ""
            .addLine("HTTPRequest(")
            .append(httpRequestParameters.indent())
            .addLine(")")
    }

    func composeResultSwitch(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        let cases: String = self.composeResultSwitchCases(forMethodScheme: methodScheme)

        return ""
            .addLine("switch self.transport.send(request: request) {")
            .append(cases.indent())
            .addLine("}")
    }

    func composeHTTPRequestArguments(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        return ""
            .addLine("httpMethod: HTTPRequest.HTTPMethod.\(methodScheme.httpVerb.rawValue),")
            .addLine("endpoint: \"\(methodScheme.endpoint)\",")
            .addLine("headers: headers,")
            .addLine("parameters: parameters,")
            .addLine("requestInterceptors: requestInterceptors,")
            .addLine("responseInterceptors: responseInterceptors,")
            .addLine("base: self.baseRequest")
    }

    func composeResultSwitchCases(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        let successCase: String = self.composeResultSwitchSuccessCaseBody(forMethodScheme: methodScheme)
        let failureCase: String = self.composeResultSwitchFailureCaseBody(forMethodScheme: methodScheme)

        return ""
            .addLine("case .success(let response):")
            .append(successCase.indent())
            .addBlankLine()
            .addLine("case .failure(let error):")
            .append(failureCase.indent())
    }

    func composeResultSwitchFailureCaseBody(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        return ""
            .addLine("return ServiceCallResult.failure(error: error)")
    }

    func composeResultSwitchSuccessCaseBody(forMethodScheme methodScheme: ServiceMethodScheme) -> String {
        if methodScheme.returnedModelObjectTypeName == "Void" {
            return ""
                .addLine("if let error = self.verify(response: response) { return ServiceCallResult.failure(error: error) }")
                .addLine("return ServiceCallResult.success(payload: ())")
        } else if methodScheme.returnedModelObjectTypeName == "String" {
            return ""
            .addLine("if let error = self.verify(response: response) { return ServiceCallResult.failure(error: error) }")
            .addLine("if let data = response.body,")
            .addLine("let string = String(data: data, encoding: .utf8) {".indent())
            .addLine("return ServiceCallResult.success(payload: string)".indent())
            .addLine("} else {")
            .addLine("return ServiceCallResult.failure(error: NSError.noHTTPResponse)".indent())
            .addLine("}")
        }

        let payloadDeclaration:    String
        let jsonObjectDeclaration: String

        jsonObjectDeclaration = "let jsonObject: Any = try response.getJSON()!\n"
        if methodScheme.returnsCollection {
            payloadDeclaration = "let payload = \(methodScheme.parserName)().parse(jsonObject)"
        } else {
            payloadDeclaration = "guard let payload = \(methodScheme.parserName)().parse(jsonObject).first else { throw NSError.noHTTPResponse }"
        }

        return ""
            .addLine("if let error = self.verify(response: response) { return ServiceCallResult.failure(error: error) }")
            .addBlankLine()
            .addLine("do {")
            .append(jsonObjectDeclaration.indent())
            .addLine(payloadDeclaration.indent())
            .addLine("return ServiceCallResult.success(payload: payload)".indent())
            .addLine("} catch let error {")
            .addLine("return ServiceCallResult.failure(error: error as NSError)".indent())
            .addLine("}")
    }

}
