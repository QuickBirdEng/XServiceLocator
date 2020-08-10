//
//  Container.swift
//  XServiceLocator
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

/// Stores the configuration on how to create instances of the registered types
public class Container {
    let dependency: Resolver?
    let factories: [AnyServiceFactory]

    /// Initializes a new container with an optional child resolver
    /// - Parameter dependency: a child resolver that is used when the dependency cannot be resolved by this container.
    /// However, the container first tries to resolve the dependencies by itself
    public init(dependency: Resolver? = nil) {
        self.dependency = dependency
        self.factories = []
    }

    /// Initializes a new container with an optional child resolver and an array of factories
    /// - Parameter dependency: a child resolver that is used when the dependency cannot be resolved by this container.
    /// However, the container first tries to resolve the dependencies by itself
    /// - Parameter factories: an array of already registered types.
    init(dependency: Resolver? = nil, factories: [AnyServiceFactory]) {
        self.dependency = dependency
        self.factories = factories
    }

    // MARK: - Register

    /// Register the `instance` as a object of Type `ServiceType`. The same instance will be resolved on every resolve call.
    /// - Parameter interface: The target type `ServiceType` to register the object as
    /// - Parameter instance: The instance to register
    public func register<ServiceType>(_ interface: ServiceType.Type, instance: ServiceType) -> Container {
        return register(interface) { _ in instance }
    }

    /// Register the `factory` as a template to create object of Type `ServiceType`. The `factory` will be called on
    /// every resolve call which means that a new instance will be created on every resolve call.
    /// - Parameter interface: The target type `ServiceType` to register the object as
    /// - Parameter factory: The factory/closure that is used to create the instance of type `ServiceType`
    public func register<ServiceType>(_ interface: ServiceType.Type,
                                      _ factory: @escaping (Resolver) -> ServiceType) -> Container {

        let newFactory = BasicServiceFactory<ServiceType>(interface, factory: { resolver in
            factory(resolver)
        })
        return .init(dependency: dependency, factories: factories + [AnyServiceFactory(newFactory)])
    }
}

// MARK: - Resolver

extension Container: Resolver {
    /// returns a resolver that can be used to resolve the container objects
    public var resolver: Resolver { return self as Resolver }

    /// Resolves to an instance of type `ServiceType` and throws if no instance/factory has already been registered.
    /// In case the container is not able to resolve the instance type, it will try to resolve it using its dependency.
    /// An `Error.factoryNotFound` will be thrown in case the resolution is not possible.
    public func resolve<ServiceType>(_ type: ServiceType.Type) throws -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            guard let resolvedByDependency = try dependency?.resolve(type) else {
                throw Container.unableToResolve(type)
            }

            return resolvedByDependency
        }

        return try factory.resolve(self)
    }

    /// Resolves to an instance of type `ServiceType` and throws if no instance/factory has already been registered.
    /// In case the container is not able to resolve the instance type, it will try to resolve it using its dependency.
    /// An `Error.factoryNotFound` will be thrown in case the resolution is not possible.
    public func resolve<ServiceType>() throws -> ServiceType {
        return try resolve(ServiceType.self)
    }
}

// MARK: - Error

extension Container {
    public static func unableToResolve<ServiceType>(_ type: ServiceType.Type) -> Error {
        return .factoryNotFound(service: type)
    }

    public enum Error: Swift.Error, Equatable {
        public static func == (lhs: Container.Error, rhs: Container.Error) -> Bool {
            switch (lhs, rhs) {
            case let (.factoryNotFound(lhsType), .factoryNotFound(rhsType)):
                return lhsType == rhsType
            }
        }

        case factoryNotFound(service: Any.Type)
    }
}
