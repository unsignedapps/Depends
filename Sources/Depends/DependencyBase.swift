//
//  BaseDependency.swift
//  Pandora
//
//  Created by Rob Amos on 5/9/20.
//

import Foundation

#if canImport(os)
import os.log
#endif

/// The `BaseDependency` is an optional base class for other dependencies throughout the application.
///
/// Its main purpose is to provide a weakly-implemented `DependencyProvider`
/// so that subclasses can access other dependencies without creating a retain cycle.
///
open class DependencyBase: DependencyProvider {

    // MARK: - Properties

    weak public var weakDependencies: DependencyRegistry? {
        didSet {
            if oldValue == nil {
                setup()
            }
        }
    }

    public var dependencies: DependencyRegistry {
        guard let registry = weakDependencies else {

            #if canImport(os)

            if #available(iOS 14.0, OSX 11.0, *) {
                Logger.baseDependency.error(
                    """
                    Attempted to access a @Dependency within '\(String(describing: Self.self), privacy: .public)' before the dependency
                    has been added to a DependencyRegistry using `DependencyRegistry.register(_:for:)`.
                    """
                )
            }

            #endif

            assertionFailure(
                """
                Attempted to access an @Dependency within '\(String(describing: Self.self))' before the dependency
                has been added to a DependencyRegistry using `DependencyRegistry.register(_:for:)`.
                """
            )

            return DependencyRegistry()
        }

        return registry
    }

    // MARK: - Initialisation

    /// Initialises a `BaseDependency` without a specific `DependencyRegistry`.
    ///
    /// When added to a `DependencyRegistry`, the registry will take
    /// ownership of the `BaseDependency`, and set itself ion the
    /// `weakDependencyRegistry` property.
    ///
    /// - Important: Add this dependency to a `DependencyRegistry` as soon as possible!
    ///
    public init() {
        // Intentionally left blank
    }

    /// Initialises a `BaseDependency` with a specific `DependencyRegistry`.
    ///
    /// - Note: When added to a `DependencyRegistry` it will take ownership
    ///         of this `BaseDependency`, replacing any existing
    ///         `DependencyRegistry.`
    ///
    public init(dependencies: DependencyRegistry) {
        self.weakDependencies = dependencies
        setup()
    }

    /// Called when this class' dependencies are completely available
    ///
    /// This method is called automatically once all of your dependencies are
    /// available. Override it and use it to configure or setup your dependency.
    ///
    /// # Important
    ///
    /// This method does not guarantee that this dependency is available
    /// and ready to be used by anyone that wants to depend on it.
    ///
    /// Use ``addedToDependencyRegistry()`` for that.
    ///
    open func setup() {
        // Intentionally left blank
    }

    /// Called when this class has been added to the dependency registry
    ///
    /// Override this method to trigger any work that might depend on this
    /// type.
    ///
    open func addedToDependencyRegistry() {
        // Intentionally left blank
    }

}

// MARK: - Logger

#if canImport(os)

@available(iOS 14.0, OSX 11.0, *)
private extension Logger {
    static let baseDependency = Logger(subsystem: "Pandora", category: "base-dependency")
}

#endif
