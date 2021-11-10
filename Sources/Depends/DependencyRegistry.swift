//
//  DependencyRegistry.swift
//  Pandora
//
//  Created by Rob Amos on 5/9/20.
//

#if canImport(Combine)
import Combine
#endif

import Foundation

/// The DependencyRegistry is a central place to register different versions of dependencies that you need.
///
/// It is heavily inspired by (copied from) SwiftUI's `@Environment` property wrapper.
///
/// To use:
///
/// ```swift
/// // We need a DependencyKey that wraps our type and provides a default value
/// public extension DependencyKey where Dependency == MyDependency {
///     static let myDependency = DependencyKey<MyDependency>(defaultDependency: MyDependency())
/// }
///
/// // Then at runtime, if you want to use something other than
/// // the default value above, make sure you register it
/// dependencyRegistry.register(MyActualDependency(), for: .myDependency)
///
/// // To fetch:
/// dependencyRegistry.dependency(for: .myDependency)
///
/// // or
/// dependencyRegistry[.myDependency]
///
/// // or
/// @Dependency(.myDependency) private var myDependency
/// ```
///
public final class DependencyRegistry {

    // MARK: - Types

    public typealias StorageKey = String


    // MARK: - Properties

    private var storage: [StorageKey: Any] = [:]
    private let lock = Lock()

    /// The parent `DependencyRegistry` that this instance will search for dependencies if we can't satisfy them ourselves
    private var parent: DependencyRegistry?

    #if canImport(Combine)

    private var cancellables = Set<AnyHashable>()

    #endif


    // MARK: - Initialisation

    /// Initialise the dependency registry, optionally providing a parent registry.
    ///
    /// - Parameters:
    ///   - parent: A parent `DependencyRegistry` to be used in a chain of responsibility when fetching dependencies.
    ///
    public init(parent: DependencyRegistry? = nil) {
        self.parent = parent
    }

    /// Initialise the dependency registry with some existing dependencies, optionally providing a parent registry.
    ///
    /// - Parameters:
    ///   - parent: A parent `DependencyRegistry` to be used in a chain of responsibility when fetching dependencies.
    ///
    public init(parent: DependencyRegistry? = nil, @DependencyRegistryBuilder _ builder: () throws -> DependencyRegistryBuilder.Component) rethrows {
        self.parent = parent
        try register(builder: builder)
    }


    // MARK: - Locating Dependencies

    /// Locates the dependency for the specified `key`.
    ///
    /// - Parameters:
    ///   - key:        The key of the registered dependency.
    ///
    public func dependency<DependencyType>(for key: DependencyKey<DependencyType>) -> DependencyType {
        if let registered = findDependency(for: key.name) {
            if let dependency = registered as? DependencyType {
                return dependency
            }

            // we got something else?
            assertionFailure (
                """
                Dependency registered at key \(key.name) is a \(type(of: registered)) when we expected a \(DependencyType.self).
                Returning the default instead.
                """
            )
        }

        guard let factory = key.dependencyFactory else {
            fatalError(
                """
                You have not registered a dependency at key \(key.name). Expecting a \(String(describing: DependencyType.self)).
                """
            )
        }

        let dependency = factory()
        register(dependency, for: key)
        return dependency
    }

    /// Locates the dependency for the specified `key`.
    public subscript<DependencyType> (_ key: DependencyKey<DependencyType>) -> DependencyType {
        self.dependency(for: key)
    }

    /// Find the first matching dependency for the specified `key`. Searches parent `DependencyRegistry` if available.
    private func findDependency(for key: StorageKey) -> Any? {
        lock.withLock { storage[key] }
            ?? parent?.findDependency(for: key)
    }


    // MARK: - Registering Dependencies

    /// Registers an implementation of the dependency for the specified key.
    ///
    /// - Parameters:
    ///   - dependency: The dependency instance to register.
    ///   - key: The dependency key under which to register the `dependency`.
    ///
    public func register<Dependency>(_ dependency: Dependency, for key: DependencyKey<Dependency>) {
        register(dependency, storageKey: key.name)
    }

    /// Registers a dependency that conforms to ``KeyedDependency`` against its internal key.
    ///
    /// - Parameters:
    ///   - dependency:    The dependency instance to register
    ///
    public func register<Dependency>(_ dependency: Dependency) where Dependency: KeyedDependency {
        register(dependency, storageKey: Dependency.dependencyKey.name)
    }

    private func register(_ dependency: AnyKeyedDependency) {
        register(dependency.dependency, storageKey: dependency.storageKey)
    }

    /// Registers multiple dependencies that conform to ``KeyedDependency`` using the provided closure
    public func register(@DependencyRegistryBuilder builder: () throws -> DependencyRegistryBuilder.Component) rethrows {
        for dependency in try builder() {
            register(dependency)
        }
    }

    private func register<Dependency>(_ dependency: Dependency, storageKey: StorageKey) {

        // if its a LotusDependency then it is also a DependencyRegistryProvider
        // lets decorate it with a weak reference to ourselves
        lock.withLock {
            if let baseDependency = dependency as? DependencyBase {
                baseDependency.weakDependencies = self
                storage.updateValue(baseDependency, forKey: storageKey)

            } else {
                storage.updateValue(dependency, forKey: storageKey)
            }
        }
    }


    // MARK: - Dynamic Dependencies

    #if canImport(Combine)

    /// Subscribes to the provided `Publisher` and updates the Dependency registration with each omitted value.
    ///
    /// Every time the provided `Publisher` emits a new instance of the dependency, it will be registered against
    /// the provided key. Each new instance will **replace** the existing one.
    ///
    /// - Important: `DependencyRegistry` will subscribe to the `Publisher` immediately. If your `Publisher` relies
    /// on any other dependencies they **must** be registered and available before calling this method.
    ///
    /// - Parameters:
    ///   - publisher:              A `Publisher` that emits `Dependency` instances.
    ///   - key:                    The `DependencyKey` under which to register the emitted instances of the dependency.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func register<Pub, Dependency>(dynamic publisher: Pub, for key: DependencyKey<Dependency>) where Pub: Publisher, Pub.Output == Dependency, Pub.Failure == Never {
        publisher
            .sink { [weak self] dependency in
                self?.register(dependency, storageKey: key.name)
            }
            .store(in: &cancellables)
    }

    /// Subscribes to the provided `Publisher` and updates the Dependency registration with each omitted value.
    ///
    /// Every time the provided `Publisher` emits a new instance of the dependency, it will be registered.
    /// Each new instance will **replace** the existing one.
    ///
    /// - Important: `DependencyRegistry` will subscribe to the `Publisher` immediately. If your `Publisher` relies
    /// on any other dependencies they **must** be registered and available before calling this method.
    ///
    /// - Parameters:
    ///   - publisher:              A `Publisher` that emits `KeyedDependency` instances.
    ///
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func register<Pub>(dynamic publisher: Pub) where Pub: Publisher, Pub.Output: KeyedDependency, Pub.Failure == Never {
        publisher
            .sink { [weak self] dependency in
                self?.register(dependency, storageKey: Pub.Output.dependencyKey.name)
            }
            .store(in: &cancellables)
    }

    #endif


    // MARK: - Unregistering Dependencies

    /// Remove a registered dependency. This effectively resets it back to default
    public func unregister<Dependency>(key: DependencyKey<Dependency>) {
        unregister(storageKey: key.name)
    }

    /// Removes a registered dependency that conforms to ``KeyedDependency``
    ///
    /// - Important: This method uses the ``DependencyKey`` associated with the ``KeyedDependency``
    /// and removes any registered dependency with that key. It does not check that the registered
    /// dependency is the same as the provided instance.
    ///
    public func unregister<Dependency>(_ dependency: Dependency) where Dependency: KeyedDependency {
        unregister(storageKey: Dependency.dependencyKey.name)
    }

    private func unregister(storageKey: StorageKey) {
        lock.withLockVoid {
            storage.removeValue(forKey: storageKey)
        }
    }

    /// Removes all of the registered dependencies
    public func unregisterAll() {
        lock.withLock {
            storage.removeAll()
        }
    }


}
