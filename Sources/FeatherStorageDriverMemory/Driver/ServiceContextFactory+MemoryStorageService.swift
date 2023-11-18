//
//  ServiceContextFactory+MemoryStorageService.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherService

public extension ServiceContextFactory {

    static func memoryStorage() -> Self {
        .init {
            MemoryStorageServiceContext()
        }
    }

}
