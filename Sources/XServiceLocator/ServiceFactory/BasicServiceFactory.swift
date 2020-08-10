//
//  BasicServiceFactory.swift
//  XServiceLocator
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

/// Implementation of `ServiceFactory` that is used to generate instances of the generic type `ServiceType`
struct BasicServiceFactory<ServiceType>: ServiceFactory {
    private let factory: (Resolver) throws -> ServiceType

    /// initializes the factory with type `ServiceType` and a factory for creation of the type
    /// - Parameter type: The type of the object that this factory supports/creates
    /// - Parameter factory: The factory method that takes a resolver and should return an instance of the type
    init(_ type: ServiceType.Type, factory: @escaping (Resolver) throws -> ServiceType) {
        self.factory = factory
    }

    /// tries resolving/generating the instance of generic type using the passed `Resolver`
    func resolve(_ resolver: Resolver) throws -> ServiceType {
        return try factory(resolver)
    }
}
