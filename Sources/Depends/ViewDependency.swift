//
//  ViewDependency.swift
//  Pandora
//
//  Created by Rob Amos on 5/9/20.
//

#if canImport(SwiftUI)

import Foundation
import SwiftUI

/// A property wrapper that simplifies consumption of dependencies
/// that lives in the `DependencyRegistry`.
///
/// - Important: This property wrapper is intended only to be used inside a SwiftUI view hierarchy.
///
@propertyWrapper
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ViewDependency<DependencyType> {

    // MARK: - Properties

    /// The dynamically looked up dependency
    public var wrappedValue: DependencyType {
        let registry = Environment(\.dependencies).wrappedValue
        return registry.dependency(for: self.key)
    }

    private let key: DependencyKey<DependencyType>

    /// Initialises the `@Dependency` property wrapper with the dependency at the specified KeyPath:
    ///
    ///     @Dependency(.key) var dependencyName
    ///
    /// Where `.key` is a `DependencyKey`.
    ///
    /// - Important: You can only use this property wrapper inside a type that conforms to `DependencyProvider`.
    ///
    public init (_ key: DependencyKey<DependencyType>) {
        self.key = key
    }

}

#endif
