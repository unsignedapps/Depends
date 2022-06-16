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

#if canImport(Combine)

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {

    /// Subscribes the provided ``DependencyRegistry`` to the receiving `Publisher`and updates the Dependency
    /// registration with each omitted value.
    ///
    /// Each new instance emitted will **replace** the existing one.
    ///
    /// - Important: ``DependencyRegistry`` will subscribe to the `Publisher` immediately. If your `Publisher` relies
    /// on any other dependencies they **must** be registered and available before calling this method.
    ///
    func subscribe(dependencyRegistry: DependencyRegistry, for key: DependencyKey<Output>) {
        dependencyRegistry.register(dynamic: self, for: key)
    }

}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Output: KeyedDependency, Failure == Never {

    /// Subscribes to the provided `Publisher` and updates the Dependency registration with each omitted value.
    ///
    /// Every time the provided `Publisher` emits a new instance of the dependency, it will be registered against
    /// the provided key. Each new instance will **replace** the existing one.
    ///
    /// - Important: ``DependencyRegistry`` will subscribe to the `Publisher` immediately. If your `Publisher` relies
    /// on any other dependencies they **must** be registered and available before calling this method.
    ///
    func subscribe(dependencyRegistry: DependencyRegistry) {
        dependencyRegistry.register(dynamic: self)
    }

}

#endif
