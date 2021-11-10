//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
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

import Foundation

/// Declares that a type houses a ``DependencyRegistry`` and that
/// the `@Dependency` property wrapper can be used.
///
public protocol DependencyProvider: AnyObject {
    var dependencies: DependencyRegistry { get }
}


// MARK: - SwiftUI Support

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private enum DependencyRegistryKey: EnvironmentKey {
    static var defaultValue: DependencyRegistry {
        return DependencyRegistry()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension EnvironmentValues {
    var dependencies: DependencyRegistry {
        get { self[DependencyRegistryKey.self] }
        set { self[DependencyRegistryKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View where Self: DependencyProvider {
    var dependencies: DependencyRegistry {
        let environment = Environment(\.dependencies)
        return environment.wrappedValue
    }
}

#endif

