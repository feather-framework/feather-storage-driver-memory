//
//  MemoryStorageServiceBuilder.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherService

struct MemoryStorageServiceBuilder: ServiceBuilder {

    func build(
        using config: ServiceConfig
    ) throws -> Service {
        MemoryStorageService(config: config)
    }
}
