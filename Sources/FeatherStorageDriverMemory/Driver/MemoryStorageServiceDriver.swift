//
//  MemoryStorageServiceDriver.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherService

struct MemoryStorageServiceDriver: ServiceDriver {

    func run(
        using config: ServiceConfig
    ) throws -> Service {
        MemoryStorageService(config: config)
    }
}
