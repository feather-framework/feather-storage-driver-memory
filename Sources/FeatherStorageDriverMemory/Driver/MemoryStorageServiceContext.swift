//
//  MemoryStorageComponentContext.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherComponent

public struct MemoryStorageComponentContext: ComponentContext {

    public init() {}

    public func make() throws -> ComponentBuilder {
        MemoryStorageComponentBuilder()
    }
}
