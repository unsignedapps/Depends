//===----------------------------------------------------------------------===//
//
// Copyright (c) 2021 Unsigned Apps
// Licensed under MIT License
//
// See LICENSE for license information
// See CONTRIBUTING.md to contribute to this project
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Depends
import XCTest

open class BaseTestCase: XCTestCase {

    // MARK: - Properties

    /// The managed dependency registry for this test case. You should
    /// not attempt to override or replace this in your tests.
    public var dependencies: DependencyRegistry!

    // MARK: - Setup and Tear Down

    open override func setUpWithError() throws {
        try super.setUpWithError()

        dependencies = DependencyRegistry()
    }

    open override func tearDownWithError() throws {

        dependencies.unregisterAll()
        dependencies = nil

        try super.tearDownWithError()
    }

}
