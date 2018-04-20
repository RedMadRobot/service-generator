//
//  ServiceDependencyComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 4/27/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


// TODO: change raw spaces to ".indent()" calls
class ServiceDependencyComposer: Composer {

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
        return "ServiceDependency.swift"
    }

    override func composeImports() -> String {
        return super.composeImports()
                    .addLine("import HTTPTransport")
    }

    func composeUtilitySourceCode() -> String {
        let utilityComment:     String = self.composeUtilityComment()
        let utilityDeclaration: String = self.composeUtilityDeclaration().addBlankLine()
        let properties:         String = self.composeProperties().addBlankLine()
        let initializer:        String = self.composeInitializer().indent().addBlankLine().addLine("}")

        return ""
            .append(utilityComment)
            .addLine(utilityDeclaration)
            .addBlankLine()
            .append(properties.indent())
            .append(initializer)
    }

}


private extension ServiceDependencyComposer {
    func composeUtilityComment() -> String {
        return ""
            .addLine("/**")
            .addLine(" Working & completion queues, base URL, security preferences and request retrier.")
            .addLine(" */")
    }

    func composeInitializer() -> String {
        return ""
            .addLine("/**")
            .addLine(" Initializer.")
            .addLine(" */")
            .addLine("init(")
            .addLine("    operationQueue:       OperationQueue        = OperationQueue(),")
            .addLine("    completionQueue:      OperationQueue        = OperationQueue.main,")
            .addLine("    security:             Security              = Security.noEvaluation,")
            .addLine("    retrier:              HTTPTransportRetrier? = nil,")
            .addLine("    useDefaultValidation: Bool                  = true")
            .addLine(") {")
            .addLine("    self.operationQueue = operationQueue")
            .addLine("    self.completionQueue = completionQueue")
            .addLine("    self.session = Session(security: security, retrier: retrier)")
            .addLine("    self.useDefaultValidation = useDefaultValidation")
            .addLine("}")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Initializer.")
            .addBlankLine()
            .addLine(" Shared API session might be applied.")
            .addLine(" */")
            .addLine("init(")
            .addLine("    operationQueue:       OperationQueue        = OperationQueue(),")
            .addLine("    completionQueue:      OperationQueue        = OperationQueue.main,")
            .addLine("    session:              Session,")
            .addLine("    useDefaultValidation: Bool                  = true")
            .addLine(") {")
            .addLine("    self.operationQueue = operationQueue")
            .addLine("    self.completionQueue = completionQueue")
            .addLine("    self.session = session")
            .addLine("    self.useDefaultValidation = useDefaultValidation")
            .addLine("}")
    }

    func composeProperties() -> String {
        return ""
            .addLine("/**")
            .addLine(" Background working queue.")
            .addLine(" */")
            .addLine("let operationQueue:       OperationQueue")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Main queue for callbacks.")
            .addLine(" */")
            .addLine("let completionQueue:      OperationQueue")
            .addBlankLine()
            .addLine("/**")
            .addLine(" API session.")
            .addLine(" */")
            .addLine("let session:              Session")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Validate via Alamofire.")
            .addLine(" */")
            .addLine("let useDefaultValidation: Bool")
    }

    func composeUtilityDeclaration() -> String {
        return ""
            .addLine("class ServiceDependency {")
    }
}
