//
//  ServiceDependencyComposerTests
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 4/27/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation
import XCTest


class ServiceDependencyComposerTests: TestCase {

    private let stubProjectName:     String = "GEN"
    private let stubOutputDirectory: String = "dir"

    func testCompose_allSet_expectedOutput() {
        let composer: ServiceDependencyComposer = ServiceDependencyComposer()

        let expectedSourceCode: Implementation = self.composeExpectedImplementation()
        let actualSourceCode:   Implementation = composer.composeUtilityImplementation(
            projectName: self.stubProjectName,
            outputDirectory: self.stubOutputDirectory
        )

        // TODO: Implement equality operator for "Implementation" class
        XCTAssertEqual(actualSourceCode.sourceCode, expectedSourceCode.sourceCode)
        XCTAssertEqual(actualSourceCode.filePath, expectedSourceCode.filePath)
    }

    private func composeExpectedImplementation() -> Implementation {
        return Implementation(
            filePath: self.stubOutputDirectory + "/" + "ServiceDependency.swift",
            sourceCode: self.composeExpectedSourceCode()
        )
    }

    private func composeExpectedSourceCode() -> String {
        return loadContentsOfFile(name: "ServiceDependency.swift.test")
    }
}
