//
//  Resolver.swift
//  X
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

public protocol Resolver {
    /// Resolves to an instance of type `ServiceType` and throws if no instance/factory has already been registered.
    func resolve<ServiceType>(_ type: ServiceType.Type) throws -> ServiceType

    /// makes use of type inference to resolve to an instance of type `ServiceType` and throws if no instance/factory
    /// has already been registered. Makes use o
    func resolve<ServiceType>() throws -> ServiceType
}
