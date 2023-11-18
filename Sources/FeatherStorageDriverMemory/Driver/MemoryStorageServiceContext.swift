//
//  MemoryStorageServiceContext.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherService

struct MemoryStorageServiceContext: ServiceContext {

    func createDriver() throws -> ServiceDriver {
        MemoryStorageServiceDriver()
    }
}
