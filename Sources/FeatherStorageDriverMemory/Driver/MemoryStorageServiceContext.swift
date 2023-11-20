//
//  MemoryStorageServiceContext.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherService

public struct MemoryStorageServiceContext: ServiceContext {

    public init() {}

    public func createDriver() throws -> ServiceDriver {
        MemoryStorageServiceDriver()
    }
}
