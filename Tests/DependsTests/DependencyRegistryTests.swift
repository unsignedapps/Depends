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
#endif

import Foundation
import Depends
import TestDepends
import XCTest

final class DependencyRegistryTests: BaseTestCase {

    // MARK: - Registration Tests

    func testRegistersMultipleDependencies() {
        let testDependency = TwoDependency()
        dependencies.register(testDependency, for: .testDependency)
        XCTAssertEqual(dependencies.dependency(for: .testDependency).id, testDependency.id)

        let otherDependency = OtherDependency()
        dependencies.register(otherDependency, for: .otherDependency)
        XCTAssertEqual(dependencies.dependency(for: .otherDependency).id, otherDependency.id)
    }

    func testRegisterOverridesSameDependency() {
        let oneDependency = OneDependency()
        dependencies.register(oneDependency, for: .testDependency)
        XCTAssertEqual(dependencies.dependency(for: .testDependency).id, oneDependency.id)

        let twoDependency = TwoDependency()
        dependencies.register(twoDependency, for: .testDependency)
        XCTAssertEqual(dependencies.dependency(for: .testDependency).id, twoDependency.id)
    }

    // MARK: - Location Tests

    func testLocateReturnsDefaultDependency() {
        let dependency = dependencies.dependency(for: .testDependency)
        XCTAssertEqual(dependency.id.uuidString, "3B191299-5F1F-40D1-BD71-0F5BF9221941")
    }

    // test we're returned the same value type
    func testLocateReturnsSameDependencyValueType() {
        let dependency = TwoDependency()
        dependencies.register(dependency, for: .testDependency)
        let locatedDependency = dependencies.dependency(for: .testDependency)
        XCTAssert(locatedDependency is TwoDependency)
        XCTAssertEqual(dependency.id, locatedDependency.id)
    }

    // test we're returned a reference to the same object
    func testLocateReturnsSameDependencyReferenceType() {
        let klass = ClassDependency()
        dependencies.register(klass, for: .classDependency)
        let locatedKlass = dependencies.dependency(for: .classDependency)
        XCTAssertTrue(klass === locatedKlass)
    }

    // test searching registry tree for dependency
    func testLocateReturnsDependencyFromParentRegistry() {
        let parent = DependencyRegistry()
        let subject = DependencyRegistry(parent: parent)

        let klass = ClassDependency()
        let oneDependency = OneDependency()
        let twoDependency = TwoDependency()

        parent.register(klass, for: .classDependency)
        parent.register(oneDependency, for: .testDependency)
        subject.register(twoDependency, for: .testDependency)

        let locatedKlass = subject.dependency(for: .classDependency)
        XCTAssertTrue(klass === locatedKlass)

        let dependency = subject.dependency(for: .testDependency)
        XCTAssert(dependency is TwoDependency)
        XCTAssertEqual(dependency.id, twoDependency.id)

        let parentDependency = parent.dependency(for: .testDependency)
        XCTAssert(parentDependency is OneDependency)
        XCTAssertEqual(parentDependency.id, oneDependency.id)
    }

    // MARK: - Dynamic Registration Tests

    #if canImport(Combine)

    // Note: because we have no way of knowing when `DependencyRegistry` completes
    // these tests assume they are registered synchronously

    func testRegistersDynamicDependency() throws {

        // GIVEN a publisher of dependency instances
        let publisher = PassthroughSubject<TestDependency, Never>()

        // WHEN we register that
        dependencies.register(dynamic: publisher, for: .testDependency)

        // THEN we expect each emitted dependency to be registered
        for _ in 0 ..< 10 {
            let dependency = OneDependency()
            publisher.send(dependency)
            XCTAssertEqual(dependencies.dependency(for: .testDependency).id, dependency.id)
        }

    }

    func testRegistersDynamicKeyedDependency() throws {

        // GIVEN a publisher of dependency instances
        let publisher = PassthroughSubject<TestDependency, Never>()

        // WHEN we register that
        dependencies.register(dynamic: publisher, for: .testDependency)

        // THEN we expect each emitted dependency to be registered
        for _ in 0 ..< 10 {
            let dependency = KeyedTestDependency()
            publisher.send(dependency)
            XCTAssertEqual(dependencies.dependency(for: .testDependency).id, dependency.id)
        }

    }

#endif

    // MARK: - Threading Tests

    func testRegistersALotOfDependencys() throws {
        // Perform a bunch of registrations on multiple threads
        // There are no asserts here, it will just crash the test if we've
        // messed up threading support
        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            dependencies.register(OneDependency(), for: .testDependency)
            dependencies.register(OtherDependency(), for: .otherDependency)
            dependencies.register(ClassDependency(), for: .classDependency)

            // test a simple one that registers dependencys inside itself to verify the recursive lock
            dependencies.register(BasicRecursiveDependency(dependencies: dependencies), for: .recursiveDependency)

            // verify fetching works as expected also
            _ = dependencies.dependency(for: .otherDependency)
        }

    }
}

private protocol TestDependency {
    var id: UUID { get }
}

private struct DefaultDependency: TestDependency {
    let id = UUID(uuidString: "3B191299-5F1F-40D1-BD71-0F5BF9221941")!
}

private struct OneDependency: TestDependency {
    let id = UUID()
}

private struct TwoDependency: TestDependency {
    let id = UUID()
}

private struct KeyedTestDependency: KeyedDependency, TestDependency {

    typealias DependencyProtocol = TestDependency
    static let dependencyKey = DependencyKey.testDependency

    let id = UUID()

}

private struct OtherDependency {
    let id = UUID()
}

private class ClassDependency {
}

private protocol RecursiveDependency {
}

private class BasicRecursiveDependency: DependencyBase, RecursiveDependency {

    @Dependency(.testDependency) private var testDependency: TestDependency

    override func setup() {
        super.setup()
        dependencies.register(OneDependency(), for: .testDependency)
        dependencies.register(OtherDependency(), for: .otherDependency)
        dependencies.register(ClassDependency(), for: .classDependency)

        // check fetching + lookup
        _ = testDependency
    }

}

private struct VoidRecursiveDependency: RecursiveDependency {
}

// MARK: - Fixtures: DependencyKeys

private extension DependencyKey where DependencyType == TestDependency {
    static let testDependency = DependencyKey<TestDependency>(default: DefaultDependency())
}

private extension DependencyKey where DependencyType == OtherDependency {
    static let otherDependency = DependencyKey<OtherDependency>(default: OtherDependency())
}

private extension DependencyKey where DependencyType == ClassDependency {
    static let classDependency = DependencyKey<ClassDependency>(default: ClassDependency())
}

private extension DependencyKey where DependencyType == RecursiveDependency {
    static let recursiveDependency = DependencyKey<RecursiveDependency>(default: VoidRecursiveDependency())
}

