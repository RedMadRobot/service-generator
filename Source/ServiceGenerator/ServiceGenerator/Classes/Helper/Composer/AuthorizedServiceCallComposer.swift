//
//  AuthorizedServiceCallComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 07/04/2017.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


// TODO: change raw spaces to ".indent()" calls
class AuthorizedServiceCallComposer: Composer {

    func composeUtilityImplementation(
        projectName: String,
        outputDirectory: String
    ) -> Implementation {
        let filename:   String = composeEntityUtilityFilename()
        let path:       String = outputDirectory.hasSuffix("/") ? outputDirectory + filename : outputDirectory + "/" + filename
        let sourceCode: String =
            composeCopyrightComment(forFilename: filename, project: projectName).addBlankLine().addBlankLine() +
            composeImports().addBlankLine().addBlankLine() +
            composeUtilitySourceCode()

        return Implementation(
            filePath: path,
            sourceCode: sourceCode
        )
    }

    func composeEntityUtilityFilename() -> String {
        return "AuthorizedServiceCall.swift"
    }

    func composeUtilitySourceCode() -> String {
        let utilityComment:     String = self.composeUtilityComment()
        let utilityDeclaration: String = self.composeUtilityDeclaration()
        let properties:         String = self.composeProperties()
        let methods:            String = self.composeMethods()
        let authorizer:         String = self.composeAuthorizer()

        return ""
            .append(utilityComment)
            .addLine(utilityDeclaration)
            .addBlankLine()
            .append(properties.indent())
            .addBlankLine()
            .append(methods.indent())
            .addBlankLine()
            .addLine("}")
            .addBlankLine()
            .append(authorizer)
    }

}

private extension AuthorizedServiceCallComposer {

    func composeUtilityComment() -> String {
        return ""
            .addLine("/**")
            .addLine(" Fail-safe ```ServiceCall``` for cases, when the call might need to be authorized.")
            .addBlankLine()
            .addLine(" @ignore")
            .addLine(" */")
    }

    func composeAuthorizer() -> String {
        return ""
            .addLine("/**")
            .addLine(" Entity to authorize the call or to check, whether the call failure was because of auth error.")
            .addLine(" */")
            .addLine("protocol Authorizing {")
            .addBlankLine()
            .addLine("    /**")
            .addLine("     Decide, whether ```ServiceCall``` failure was because of authorization error.")
            .addLine("     */")
            .addLine("    func detectAuthError(error: NSError) -> Bool")
            .addBlankLine()
            .addLine("    /**")
            .addLine("     Authorize call.")
            .addLine("     */")
            .addLine("    func authorize() -> ServiceCall<Void>")
            .addLine("}")
    }

    func composeMethods() -> String {
        return ""
            .addLine("/**")
            .addLine(" Initializer.")
            .addBlankLine()
            .addLine(" - Parameters:")
            .addLine("     - operationQueue: background queue, where wrapped service logic will be performed")
            .addLine("     - callbackQueue: completion callback queue")
            .addLine(
                "     - authorizer: Entity to authorize the call or to check, whether the call failure was because of auth error"
            )
            .addLine("     - main: closure, which wraps service method logic.")
            .addLine(" */")
            .addLine("init(")
            .addLine("    operationQueue: OperationQueue,")
            .addLine("    callbackQueue: OperationQueue,")
            .addLine("    authorizer: Authorizing,")
            .addLine("    main: @escaping Main")
            .addLine(") {")
            .addLine("    self.authorizer = authorizer")
            .addLine("    super.init(operationQueue: operationQueue, callbackQueue: callbackQueue, main: main)")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Run authorized call synchronously.")
            .addBlankLine()
            .addLine(" If call fails because session is outdated, try to re-authorize, then call again.")
            .addLine(" */")
            .addLine("override func invoke() -> ServiceCallResult<Payload> {")
            .addLine("    // initial invocation")
            .addLine("    let result: ServiceCallResult<Payload> = self.main()")
            .addLine("    if case ServiceCallResult<Payload>.failure(let error) = result {")
            .addLine("        // initial invocation finished with error")
            .addLine("        if self.authorizer.detectAuthError(error: error) {")
            .addLine("            // error is auth error")
            .addLine("            // trying to authorize")
            .addLine("            let authResult: ServiceCallResult<Void> = self.authorizer.authorize().invoke()")
            .addLine("            if case ServiceCallResult<Void>.failure(let error) = authResult {")
            .addLine("                // auth failure, finishing")
            .addLine("                let failure = ServiceCallResult<Payload>.failure(error: error)")
            .addLine("                self.result = failure")
            .addLine("                return failure")
            .addLine("            } else {")
            .addLine("                // auth success, re-trying initial invocation")
            .addLine("                return self.invoke()")
            .addLine("            }")
            .addLine("        } else {")
            .addLine("            // error is not auth error, finishing")
            .addLine("            self.result = result")
            .addLine("            return result")
            .addLine("        }")
            .addLine("    } else {")
            .addLine("        // initial invocation finished normally")
            .addLine("        self.result = result")
            .addLine("        self.postprocess(result: result)")
            .addLine("        return result")
            .addLine("    }")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Run authorized call in background.")
            .addBlankLine()
            .addLine(" If call fails because session is outdated, try to re-authorize, then call again.")
            .addLine(" */")
            .addLine("override func operate(completion: @escaping Callback) {")
            .addLine("    self.operationQueue.addOperation {")
            .addLine("        // initial invocation")
            .addLine("        let result: ServiceCallResult<Payload> = self.main()")
            .addLine("        if case ServiceCallResult<Payload>.failure(let error) = result {")
            .addLine("            // initial invocation finished with error")
            .addLine("            if self.authorizer.detectAuthError(error: error) {")
            .addLine("                // error is auth error")
            .addLine("                // trying to authorize")
            .addLine("                self.authorizer.authorize().operate { (authResult: ServiceCallResult<Void>) in")
            .addLine("                    if case ServiceCallResult<Void>.failure(let error) = authResult {")
            .addLine("                        // auth failure, finishing")
            .addLine("                        let failure = ServiceCallResult<Payload>.failure(error: error)")
            .addLine("                        self.result = failure")
            .addLine("                        self.callbackQueue.addOperation {")
            .addLine("                            completion(failure)")
            .addLine("                        }")
            .addLine("                    } else {")
            .addLine("                        // auth success, re-trying initial invocation")
            .addLine("                        self.operate(completion: completion)")
            .addLine("                    }")
            .addLine("                }")
            .addLine("            } else {")
            .addLine("                // error is not auth error, finishing")
            .addLine("                self.callbackQueue.addOperation {")
            .addLine("                    completion(result)")
            .addLine("                }")
            .addLine("            }")
            .addLine("        } else {")
            .addLine("            // initial invocation finished normally")
            .addLine("            self.result = result")
            .addLine("            self.postprocess(result: result)")
            .addLine("            self.callbackQueue.addOperation {")
            .addLine("                completion(result)")
            .addLine("            }")
            .addLine("        }")
            .addLine("    }")
            .addLine("}")
    }

    func composeProperties() -> String {
        return ""
            .addLine("/**")
            .addLine(" Entity to authorize the call or to check, whether the call failure was because of auth error.")
            .addLine(" */")
            .addLine("let authorizer: Authorizing")
    }

    func composeUtilityDeclaration() -> String {
        return "class AuthorizedServiceCall<Payload>: ServiceCall<Payload> {"
    }

}
