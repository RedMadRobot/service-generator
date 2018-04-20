//
//  ServiceMethodComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 5/3/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


class ServiceMethodComposer {

    func composeMethods(withMethodSchemes methodSchemes: [ServiceMethodScheme]) -> String {
        return methodSchemes.reduce("") { (result: String, methodScheme: ServiceMethodScheme) -> String in
            return result + self.composeMethod(withMethodScheme: methodScheme).addBlankLine()
        }
    }

}


private extension ServiceMethodComposer {

    func composeMethod(withMethodScheme methodScheme: ServiceMethodScheme) -> String {
        let methodDeclaration: String = self.composeMethodDeclaration(forScheme: methodScheme)
        let returnCreateCall:  String = self.composeReturnCreateCall(forScheme: methodScheme)
        let callBody:          String = ServiceMethodCallComposer().composeCallBody(forScheme: methodScheme)

        return ""
            .addLine(methodDeclaration)
            .addLine(returnCreateCall.indent())
            .append(callBody.indent().indent())
            .addLine("}".indent())
            .addLine("}")
    }

    func composeMethodDeclaration(forScheme methodScheme: ServiceMethodScheme) -> String {
        let arguments: String =
            methodScheme
                .method
                .arguments
                .map { (argument: Argument) -> String in
                    if argument.bodyName == argument.name {
                        return "\(argument.name): \(argument.type)"
                    } else {
                        return "\(argument.name) \(argument.bodyName): \(argument.type)"
                    }
                }
                .joined(separator: ", ")

        return "func \(methodScheme.method.name)(\(arguments)) -> \(methodScheme.returnedTypeName)<\(methodScheme.returnedModelObjectTypeName)> {"
    }

    func composeReturnCreateCall(forScheme methodScheme: ServiceMethodScheme) -> String {
        if methodScheme.autoLogin {
            return "return self.createAuthorizedCall() { () -> ServiceCallResult<\(methodScheme.returnedModelObjectTypeName)> in"
        }

        return "return self.createCall() { () -> ServiceCallResult<\(methodScheme.returnedModelObjectTypeName)> in"
    }

}
