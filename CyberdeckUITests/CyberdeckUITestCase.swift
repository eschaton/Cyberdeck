//
//  CyberdeckUITestCase.swift
//  CyberdeckUITests
//
//  Copyright © 2024-2025 Christopher M. Hanson
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

/// Base class for UI test cases for Cyberdeck.
final class CyberdeckUITestCase: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Additional setup here.
    }

    override func tearDownWithError() throws {
        // Additional teardown here.

        try super.tearDownWithError()
    }
}
