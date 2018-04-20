//
//  ServiceCallComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 07/04/2017.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


// TODO: change raw spaces to ".indent()" calls
class ServiceCallComposer: Composer {

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
        return "ServiceCall.swift"
    }

    func composeUtilitySourceCode() -> String {
        let utilityComment:     String = self.composeUtilityComment()
        let utilityDeclaration: String = self.composeUtilityDeclaration()
        let closureTypealiases: String = self.composeClosureTypealiases()
        let properties:         String = self.composeProperties()
        let methods:            String = self.composeMethods()
        let serviceCallResult:  String = self.composeServiceCallResult()

        return ""
            .append(utilityComment)
            .addLine(utilityDeclaration)
            .addBlankLine()
            .append(closureTypealiases.indent())
            .addBlankLine()
            .append(properties.indent())
            .addBlankLine()
            .append(methods.indent())
            .addBlankLine()
            .addLine("}")
            .addBlankLine()
            .append(serviceCallResult)
    }

}

private extension ServiceCallComposer {

    func composeUtilityComment() -> String {
        return ""
            .addLine("/**")
            .addLine(" Wrapper over service method. Might be called synchronously or asynchronously.")
            .addBlankLine()
            .addLine(" @ignore")
            .addLine(" */")
    }

    func composeServiceCallResult() -> String {
        return ""
            .addLine("/**")
            .addLine(" Result, returned by ```ServiceCall```")
            .addBlankLine()
            .addLine(" - seealso: ```ServiceCall```")
            .addLine(" */")
            .addLine("enum ServiceCallResult<Payload> {")
            .addLine("    case success(payload: Payload)")
            .addLine("    case failure(error: NSError)")
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
            .addLine("     - main: closure, which wraps service method logic.")
            .addLine(" */")
            .addLine("init(")
            .addLine("    operationQueue: OperationQueue,")
            .addLine("    callbackQueue: OperationQueue,")
            .addLine("    main: @escaping Main")
            .addLine(") {")
            .addLine("    self.operationQueue = operationQueue")
            .addLine("    self.callbackQueue  = callbackQueue")
            .addLine("    self.main           = main")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Run synchronously.")
            .addLine(" */")
            .addLine("func invoke() -> ServiceCallResult<Payload> {")
            .addLine("    let result: ServiceCallResult<Payload> = self.main()")
            .addLine("    self.result = result")
            .addLine("    self.postprocess(result: result)")
            .addLine("    return result")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Run in background.")
            .addBlankLine()
            .addLine(" - seealso: ```ServiceCall.operationQueue```")
            .addLine(" */")
            .addLine("func operate(completion: @escaping Callback) {")
            .addLine("    self.operationQueue.addOperation {")
            .addLine("        let result: ServiceCallResult<Payload> = self.main()")
            .addLine("        self.result = result")
            .addLine("        self.postprocess(result: result)")
            .addLine("        self.callbackQueue.addOperation {")
            .addLine("            completion(result)")
            .addLine("        }")
            .addLine("    }")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Handle `payload` before completion callback.")
            .addLine(" */")
            .addLine("func postprocess(process: @escaping PostProcess) -> Self {")
            .addLine("    self.postprocess = process")
            .addLine("    return self")
            .addLine("}")
            .addBlankLine()
            .addLine("func postprocess(result: ServiceCallResult<Payload>) {")
            .addLine("    if case ServiceCallResult.success(let payload) = result { self.postprocess?(payload) }")
            .addLine("}")
    }

    func composeProperties() -> String {
        return ""
            .addLine("/**")
            .addLine(" Closure, which wraps service method logic.")
            .addLine(" */")
            .addLine("let main: Main")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Background queue, where wrapped service logic will be performed.")
            .addLine(" */")
            .addLine("let operationQueue: OperationQueue")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Completion callback queue.")
            .addLine(" */")
            .addLine("let callbackQueue: OperationQueue")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Result.")
            .addLine(" */")
            .addLine("var result: ServiceCallResult<Payload>?")
            .addBlankLine()
            .addLine("var postprocess: PostProcess?")
    }

    func composeClosureTypealiases() -> String {
        return ""
            .addLine("/**")
            .addLine(" Signature for closure, which wraps service method logic.")
            .addLine(" */")
            .addLine("typealias Main = () -> ServiceCallResult<Payload>")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Completion callback signature.")
            .addLine(" */")
            .addLine("typealias Callback = (_ result: ServiceCallResult<Payload>) -> ()")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Signature for closure to handle `payload` in background before callback.")
            .addLine(" */")
            .addLine("typealias PostProcess = (_ payload: Payload) -> ()")
    }

    func composeUtilityDeclaration() -> String {
        return "class ServiceCall<Payload> {"
    }

}
