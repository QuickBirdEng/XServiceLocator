//
//  ServiceFactory.swift
//  XServiceLocator
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

/// Generic factory solution that is used to resolve/create instances of type `ServiceType`
protocol ServiceFactory {
    associatedtype ServiceType

    /// tries resolving/generating the instance of generic type using the passed `Resolver`
    func resolve(_ resolver: Resolver) throws -> ServiceType
}

extension ServiceFactory {
    /// Checks if the service factory supports creation of the specific `ServiceType`
    func supports<ServiceType>(_ type: ServiceType.Type) -> Bool {
        return type == ServiceType.self
    }
}
