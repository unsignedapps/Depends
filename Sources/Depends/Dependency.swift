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

import Foundation

/// A property wrapper that simplifies consumption of dependencies
/// that lives in the ``DependencyRegistry``.
///
/// - Important: You can only use this property wrapper inside a CLASS that conforms to ``DependencyProvider``.
///
@propertyWrapper
public struct Dependency<DependencyType> {

    // MARK: - Properties

    /// The original wrapper value. This is not used. Do not call it directly.
    ///
    @available(*, unavailable, message: "Do not access this property directly")
    public var wrappedValue: DependencyType {
        get { fatalError("@Dependency can only be used in a class that conforms to `DependencyProvider`") }
        set { fatalError("@Dependency can only be used in a class that conforms to `DependencyProvider`") }
    }

    private let key: DependencyKey<DependencyType>

    /// Initialises the `@Dependency` property wrapper with the dependency at the specified KeyPath:
    ///
    ///     @Dependency(.key) var dependencyName
    ///
    /// Where `.key` is a ``DependencyKey``.
    ///
    /// - Important: You can only use this property wrapper inside a CLASS that conforms to ``DependencyProvider`.
    ///
    public init (_ key: DependencyKey<DependencyType>) {
        self.key = key
    }

    
    // MARK: - Property Wrapper

    /// This is the actual method called from `EnclosingSelf` when accessing the property wrapper.
    ///
    /// This is in the the Swift Evolution proposal:
    /// https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#referencing-the-enclosing-self-in-a-wrapper-type
    ///
    /// And was implemented to support `@Published` in Combine. You can see the Property Wrapper source for it here:
    /// https://github.com/apple/swift/blob/master/lib/Sema/TypeCheckPropertyWrapper.cpp
    ///
    /// So while it is not a publicly supported implementation, its pretty safe to use for two reasons:
    ///
    /// 1. ABI stability means any changes before it becomes public will be not break backwards compatibility
    /// 2. Any changes will probably be minimal and just require a small patch in Xcode when upgrading Swift versions
    ///
    /// As such, it is felt to be pretty safe to use right now.
    ///
    public static subscript<EnclosingSelf> (
        _enclosingInstance enclosingSelf: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, DependencyType>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Dependency>
    ) -> DependencyType where EnclosingSelf: DependencyProvider {
        get {
            return enclosingSelf.dependencies.dependency(for: enclosingSelf[keyPath: storageKeyPath].key)
        }
        set {
            // Intentionally left blank
        }
    }

}
