//
//  ServiceLogFilterComposer
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 5/2/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


// TODO: change raw spaces to ".indent()" calls
class ServiceLogFilterComposer: Composer {

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
        return "ServiceLogFilter.swift"
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


private extension ServiceLogFilterComposer {
    func composeUtilityComment() -> String {
        return ""
            .addLine("/**")
            .addLine(" HTTP requests' log filtering.")
            .addLine(" */")
    }

    func composeInitializer() -> String {
        return ""
            .addLine("/**")
            .addLine(" Initializer.")
            .addLine(" */")
            .addLine("init(")
            .addLine("    requestLogLevel:            LogRequestInterceptor.LogLevel  = .url,")
            .addLine("    responseLogLevel:           LogResponseInterceptor.LogLevel = .status,")
            .addLine("    isFilteringResponseHeaders: Bool                            = true,")
            .addLine(
                "    responseHeaderFilter:       [LogResponseInterceptor.Header] = [.contentType, .setCookie, .lastModified]"
            )
            .addLine(") {")
            .addLine("    self.requestLogLevel = requestLogLevel")
            .addLine("    self.responseLogLevel = responseLogLevel")
            .addLine("    self.isFilteringResponseHeaders = isFilteringResponseHeaders")
            .addLine("    self.responseHeaderFilter = responseHeaderFilter")
            .addLine("}")
    }

    func composeProperties() -> String {
        return ""
            .addLine("/**")
            .addLine(" Requests' log level.")
            .addLine(" */")
            .addLine("var requestLogLevel:            LogRequestInterceptor.LogLevel")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Responses' log level.")
            .addLine(" */")
            .addLine("var responseLogLevel:           LogResponseInterceptor.LogLevel")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Enable filtering log of received headers.")
            .addLine(" */")
            .addLine("var isFilteringResponseHeaders: Bool")
            .addBlankLine()
            .addLine("/**")
            .addLine(" Filter for log of received headers.")
            .addLine(" */")
            .addLine("var responseHeaderFilter:       [LogResponseInterceptor.Header]")
    }

    func composeUtilityDeclaration() -> String {
        return ""
            .addLine("class ServiceLogFilter {")
    }
}
