//===----------------------------------------------------------------------===//
//
// This source file is part of the Depends open source project
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

public struct DependencyKey<DependencyType>: Hashable {

    /// The name of the dependency key.
    ///
    internal var name: DependencyRegistry.StorageKey

    /// Constructs & returns the default dependency for this dependency key.
    ///
    var dependencyFactory: DependencyFactory?

    public typealias DependencyFactory = () -> DependencyType

    /// Initialises a dependency key with the specified name and default dependency.
    ///
    /// - Parameters:
    ///   - name:                   The name of the dependency key. This should be unique and defaults to the dependency type name.
    ///   - default:                The default dependency to be used when one has not been assigned to this key.
    ///                             This expression is evaluated lazily when the default dependency is requested.
    ///
    public init (
        name: DependencyRegistry.StorageKey = DependencyRegistry.StorageKey(String(reflecting: DependencyType.self)),
        default defaultDependency: @escaping @autoclosure DependencyFactory
    ) {
        self.name = name
        self.dependencyFactory = defaultDependency
    }

    /// Initialises a dependency key with the specified name and NO default dependency.
    ///
    /// - Parameters:
    ///   - name:                   The name of the dependency key. This should be unique and defaults to the dependency type name.
    ///
    public init(name: DependencyRegistry.StorageKey = DependencyRegistry.StorageKey(String(reflecting: DependencyType.self))) {
        self.name = name
    }

    public func hash(into hasher: inout Hasher) {
        self.name.hash(into: &hasher)
    }

    public static func == (lhs: DependencyKey<DependencyType>, rhs: DependencyKey<DependencyType>) -> Bool {
        lhs.name == rhs.name
    }

}
