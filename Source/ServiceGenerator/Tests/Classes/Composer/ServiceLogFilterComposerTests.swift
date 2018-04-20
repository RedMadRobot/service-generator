//
//  ServiceLogFilterComposerTests
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 5/2/2017 AD.
//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation
import XCTest


class ServiceLogFilterComposerTests: TestCase {

    private let stubProjectName:     String = "GEN"
    private let stubOutputDirectory: String = "dir"

    func testCompose_allSet_expectedOutput() {
        let composer: ServiceLogFilterComposer = ServiceLogFilterComposer()

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
            filePath: self.stubOutputDirectory + "/" + "ServiceLogFilter.swift",
            sourceCode: self.composeExpectedSourceCode()
        )
    }

    private func composeExpectedSourceCode() -> String {
        return loadContentsOfFile(name: "ServiceLogFilter.swift.test")
    }
}
