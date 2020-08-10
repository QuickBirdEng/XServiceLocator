//
//  Array+Resolver.swift
//  XServiceLocator
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

extension Array: Resolver where Element == Resolver {

    /// tries to resolve to an instance of `ServiceType` and returns the instance as soon as the first element(resolver)
    /// resolves it successfully.
    public func resolve<ServiceType>(_ type: ServiceType.Type) throws -> ServiceType {
        guard !isEmpty else { throw EmptyResolverError() }

        return try firstToResolve({ try $0.resolve(type) })
    }

    public func resolve<ServiceType>() throws -> ServiceType {
        return try resolve(ServiceType.self)
    }

    struct EmptyResolverError: Error { }
}
