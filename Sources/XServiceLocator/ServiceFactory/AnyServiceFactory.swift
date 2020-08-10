//
//  AnyServiceFactory.swift
//  XServiceLocator
//
//  Copyright © 2020 QuickBird Studios GmbH. All rights reserved.
//

import Foundation

/// Type-erased implementation of `ServiceFactory`
final class AnyServiceFactory {
    private let _resolve: (Resolver) throws -> Any
    private let _supports: (Any.Type) -> Bool

    init<T: ServiceFactory>(_ serviceFactory: T) {

        self._resolve = { resolver -> Any in
            try serviceFactory.resolve(resolver)
        }

        self._supports = { $0 == T.ServiceType.self }
    }

    func resolve<ServiceType>(_ resolver: Resolver) throws -> ServiceType {
        return try _resolve(resolver) as! ServiceType
    }

    func supports<ServiceType>(_ serviceType: ServiceType.Type) -> Bool {
        return _supports(serviceType)
    }
}
