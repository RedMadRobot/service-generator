//
//  TestCase.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 10/04/2017.
//  Copyright © 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation
import XCTest


class TestCase: XCTestCase {

    func loadInput(nameOfFile: String) -> SourceCodeFile {
        var stubSwiftLines: [SourceCodeLine] = []

        for (index, line) in self.loadContentsOfFile(name: nameOfFile).lines().enumerated() {
            stubSwiftLines.append(
                SourceCodeLine(
                    absoluteFilePath: "",
                    lineNumber: index,
                    line: line
                )
            )
        }

        return SourceCodeFile(
            absoluteFilePath: "",
            lines: stubSwiftLines
        )
    }

    func loadContentsOfFile(name: String) -> String {
        let path: String = Bundle(for: type(of: self)).path(forResource: name, ofType: nil, inDirectory: nil)!
        return try! String(contentsOfFile: path)
    }

}
