//
//  ServiceCallComposerTests
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 07/04/2017.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation
import XCTest


class ServiceCallComposerTests: TestCase {

    private let stubProjectName:     String = "GEN"
    private let stubOutputDirectory: String = "dir"

    func testCompose_allSet_expectedOutput() {
        let composer: ServiceCallComposer = ServiceCallComposer()

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
            filePath: self.stubOutputDirectory + "/" + "ServiceCall.swift",
            sourceCode: self.composeExpectedSourceCode()
        )
    }

    private func composeExpectedSourceCode() -> String {
        return loadContentsOfFile(name: "ServiceCall.swift.test")
    }
}
