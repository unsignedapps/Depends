//
//  TestDependency.swift
//  Pandora: Grail
//
//  Created by Rob Amos on 10/7/21.
//

import Depends
import XCTest

/// A property wrapper that simplifies consumption of dependencies that live in the `DependencyRegistry`.
///
/// - Important: You can only use this property wrapper inside a type that conforms to `BaseTestCase`.
///
@propertyWrapper
public struct TestDependency<DependencyType, Proto> where DependencyType: KeyedDependency, Proto == DependencyType.DependencyProtocol {

    // MARK: - Properties

    /// The original wrapper value. This is not used. Do not call it directly.
    @available(*, unavailable, message: "Do not access this property directly")
    public var wrappedValue: DependencyType {
        get { fatalError("@TestDependency can only be used in a class that conforms to `BaseTestCase`") }
        set { fatalError("@TestDependency can only be used in a class that conforms to `BaseTestCase`") }
    }

    public init () {
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
    /// As such, it is felt to be pretty safe to use right now
    ///
    public static subscript<EnclosingSelf> (
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, DependencyType>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, TestDependency>
    ) -> DependencyType where EnclosingSelf: BaseTestCase {
        get {
            let registered = observed.dependencies.dependency(for: DependencyType.dependencyKey)
            guard let dependency = registered as? DependencyType else {
                fatalError("Dependency in the registry is of type \(String(describing: type(of: registered))) but we were expecting \(String(describing: DependencyType.self))")
            }
            return dependency
        }
        set {
            if let dependency = newValue as? Proto {
                observed.dependencies.register(dependency, for: DependencyType.dependencyKey)
                return
            } else if let dependency = newValue as? Proto?, dependency == nil {
                observed.dependencies.unregister(key: DependencyType.dependencyKey)
                return
            }

            XCTFail("Attempted to register Dependency of type \(String(describing: type(of: newValue))) but it does not conform to \(String(describing: Proto.self))")
        }
    }
}

