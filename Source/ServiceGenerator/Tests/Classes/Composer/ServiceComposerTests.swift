//
//  ServiceComposerTests
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 5/3/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation
import XCTest


class ServiceComposerTests: TestCase {

    private let stubProjectName:     String = "GEN"
    private let stubOutputDirectory: String = "dir"

    func testCompose_allSet_expectedOutput() {
        let compiledServiceProtocol: Klass = self.getCompiledFile(at: "EntityService.swift.test")
        let compiledEntityClass:     Klass = self.getCompiledFile(at: "Entity.swift.test")

        let composer: ServiceComposer = ServiceComposer()

        let expectedSourceCode: Implementation = self.composeExpectedImplementation()
        let actualSourceCode:   Implementation = try! composer.composeEntityUtilityImplementation(
            forEntityKlass: compiledServiceProtocol,
            availableEntityKlasses: [compiledEntityClass],
            projectName: self.stubProjectName,
            outputDirectory: self.stubOutputDirectory
        )

        // TODO: Implement equality operator for "Implementation" class
        XCTAssertEqual(actualSourceCode.sourceCode, expectedSourceCode.sourceCode)
        XCTAssertEqual(actualSourceCode.filePath, expectedSourceCode.filePath)
    }

    private func composeExpectedImplementation() -> Implementation {
        return Implementation(
            filePath: self.stubOutputDirectory + "/" + "EntityServiceGen.swift",
            sourceCode: self.composeExpectedSourceCode()
        )
    }

    private func getCompiledFile(at filePath: String) -> Klass {
        let serviceProtocolRaw: String = loadContentsOfFile(name: filePath)

        let serviceProtocolSourceCode: SourceCodeFile = SourceCodeFile(
            absoluteFilePath: filePath,
            contents: serviceProtocolRaw
        )

        return try! Compiler(verbose: false).compile(file: serviceProtocolSourceCode)!
    }

    private func composeExpectedSourceCode() -> String {
        return loadContentsOfFile(name: "EntityServiceGen.swift.test")
    }
}
