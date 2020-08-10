//
//  XServiceLocatorTests.swift
//  XServiceLocatorTests
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

@testable import XServiceLocator
import XCTest

class XServiceLocatorTests: XCTestCase {

    func test_registerInstance_resolvesCorrectly() {
        let resolver = Container()
            .register(TestProtocol.self, instance: TestClass(id: 1, score: .random(in: 0...10)))
        let instance: TestProtocol = try! resolver.resolve()

        XCTAssert(instance is TestClass)
    }

    func test_registerFactory_resolvesCorrectly() {
        let resolver = Container()
            .register(TestProtocol.self) { _ in TestClass(id: 1, score: .random(in: 0...10)) }
        let instance: TestProtocol = try! resolver.resolve()

        XCTAssert(instance is TestClass)
    }

    func test_registerInstance_resolvesToSameInstanceEveryTime() {
        let resolver = Container()
            .register(TestClass.self, instance: TestClass(id: 1, score: 2))

        let instance1: TestClass = try! resolver.resolve()
        let instance2: TestClass = try! resolver.resolve()

        XCTAssertTrue(instance1 === instance2)
    }

    func test_registerFactory_resolvesToNewInstanceEveryTime() {
        let resolver = Container()
            .register(TestClass.self) { _ in TestClass(id: 5, score: 10) }

        let instance1: TestClass = try! resolver.resolve()
        let instance2: TestClass = try! resolver.resolve()

        XCTAssertFalse(instance1 === instance2)
    }

    func test_registerProtocolAndClass_resolvesCorrectly() {
        let resolver = Container()
            .register(TestProtocol.self, instance: TestClass(id: 1, score: 10))
            .register(TestClass.self, instance: TestClass(id: 2, score: 20))

        let resolvedProtocol: TestProtocol = try! resolver.resolve()
        let resolvedInstance: TestClass = try! resolver.resolve()

        XCTAssert(resolvedProtocol is TestClass)

        XCTAssertEqual(resolvedProtocol.id, 1)
        XCTAssertEqual((resolvedProtocol as! TestClass).score, 10)

        XCTAssertEqual(resolvedInstance.id, 2)
        XCTAssertEqual(resolvedInstance.score, 20)
    }

    func test_registerSingleInstance_resolvesCorrectly() {
        let expectedInstance = TestClass(id: 1, score: 10)
        let resolver = Container().register(TestProtocol.self, instance: expectedInstance)
        let instance: TestProtocol = try! resolver.resolve()

        guard let castedInstance = instance as? TestClass else {
            XCTFail("Expected Instance to be of type `\(String(describing: TestClass.self))`")
            return
        }

        XCTAssert(castedInstance === expectedInstance,
                  "Expected resolved instance and original instance to be the exact same object")
    }

    func test_nonregisteredInstance_factoryNotFound() throws {
        let resolver = Container().register(TestProtocol.self, instance: TestStruct(id: 1))

        XCTAssertThrowsError(try resolver.resolve(DummyProtocol.self)) { error in
            XCTAssertEqual(error as? Container.Error, Container.Error.factoryNotFound(service: DummyProtocol.self))
        }
    }

    func test_registerTwoImplementations_lastOneOverridesPreviousOne() {
        let first = TestStruct(id: 1)
        let second = TestStruct(id: 2)

        let resolver = Container().register(TestProtocol.self, instance: first)
            .register(TestProtocol.self, instance: second)

        let resolved: TestProtocol = try! resolver.resolve()

        XCTAssertEqual(resolved.id, first.id)
        XCTAssertNotEqual(resolved.id, second.id)
    }

    func test_alreadyRegisteredDependencies_canBeResolvedForSubsequenetRegistrations() {
        let container = Container()
            .register(Int.self, instance: 100)
            .register(TestProtocol.self) { resolver in TestStruct(id: try! resolver.resolve(Int.self)) }

        let resolvedInt = try! container.resolve(Int.self)
        let resolvedObject = try! container.resolve(TestProtocol.self)

        XCTAssertEqual(resolvedInt, resolvedObject.id)
    }

    func test_registerInDependency_canBeResolvedByParent() {
        let expectedId = 100
        let first = Container().register(Int.self, instance: expectedId)
        let second = Container(dependency: first)
            .register(TestProtocol.self) { resolver in TestStruct(id: try! resolver.resolve(Int.self)) }

        let resolvedIntByFirst = try! first.resolve(Int.self)
        let resolvedIntBySecond = try! second.resolve(Int.self)

        XCTAssertEqual(resolvedIntByFirst, resolvedIntBySecond)

        let resolved = try! second.resolve(TestProtocol.self)
        XCTAssertEqual(resolved.id, expectedId)
    }

    func test_registerInDependency_isOverridenByParentWhenAccessViaParent() {
        let first = Container().register(Int.self, instance: 100)
        let second = Container(dependency: first)
            .register(TestProtocol.self) { resolver in TestStruct(id: 150) }
            .register(Int.self, instance: 200)

        let resolvedIntByFirst = try! first.resolve(Int.self)
        let resolvedIntBySecond = try! second.resolve(Int.self)

        XCTAssertNotEqual(resolvedIntByFirst, resolvedIntBySecond)
        XCTAssertEqual(resolvedIntByFirst, 100)
        XCTAssertEqual(resolvedIntBySecond, 200)
    }

    func test_ArrayOfResolvers_resolvesAll() {
        let resolver: Resolver = [
            Container().register(Int.self, instance: 100),
            Container().register(Float.self, instance: 200),
            Container().register(Double.self, instance: 300),
        ]

        XCTAssertEqual(try! resolver.resolve(Int.self), 100)
        XCTAssertEqual(try! resolver.resolve(Float.self), 200)
        XCTAssertEqual(try! resolver.resolve(Double.self), 300)
    }

    func test_arrayOfResolvers_resolvesTheFirstMatchInTheArray() {
        let first = Container().register(Int.self, instance: 100)
        let second = Container().register(Int.self, instance: 200)
        let third = Container().register(Int.self, instance: 300)

        let resolver1: Resolver = [first, second]
        let resolver2: Resolver = [first, third]
        let resolver3: Resolver = [first, second, third]

        XCTAssertEqual(try! resolver1.resolve(Int.self), 100)
        XCTAssertEqual(try! resolver2.resolve(Int.self), 100)
        XCTAssertEqual(try! resolver3.resolve(Int.self), 100)

        let resolver4: Resolver = [second, third]
        XCTAssertEqual(try! resolver4.resolve(Int.self), 200)

        let resolver5: Resolver = [first, second, third].reversed()
        XCTAssertEqual(try! resolver5.resolve(Int.self), 300)
    }

    func test_emptyArrayOfResolvers_emptyResolverError() {
        let resolver: Resolver = []

        XCTAssertThrowsError(try resolver.resolve(Int.self)) { error in
            XCTAssert(error is Array<Resolver>.EmptyResolverError)
        }
    }

    func test_arrayOfResolvers_factoryNotFound() {
        let resolver: Resolver = [
            Container().register(Double.self, instance: 100)
        ]

        XCTAssertThrowsError(try resolver.resolve(Int.self)) { error in
            XCTAssertEqual(error as? Container.Error, Container.Error.factoryNotFound(service: Int.self))
        }
    }
}
