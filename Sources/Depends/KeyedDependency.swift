//
//  KeyedDependency.swift
//  Pandora
//
//  Created by Rob Amos on 10/7/21.
//

/// A protocol that associates a dependency in the `DependencyRegistry` with
/// a `DependencyKey`.
///
/// The use of this protocol is a convenience – you can always register
/// any concrete type as a dependency directly using `dependencies.register(_:forKey:`)
///
public protocol KeyedDependency {

    associatedtype DependencyProtocol

    /// The `DependencyKey` associated with this dependency
    static var dependencyKey: DependencyKey<DependencyProtocol> { get }

}

// MARK: - Type Erasure

/// A type-erasing `KeyedDependency` that keeps just the information
/// required for registration around.
///
public struct AnyKeyedDependency {

    let storageKey: DependencyRegistry.StorageKey
    let dependency: Any

    init<Dependency>(_ dependency: Dependency) where Dependency: KeyedDependency {
        self.storageKey = Dependency.dependencyKey.name
        self.dependency = dependency
    }

}

extension Optional: KeyedDependency where Wrapped: KeyedDependency {

    public typealias DependencyProtocol = Wrapped.DependencyProtocol

    public static var dependencyKey: DependencyKey<Wrapped.DependencyProtocol> {
        Wrapped.dependencyKey
    }

}

