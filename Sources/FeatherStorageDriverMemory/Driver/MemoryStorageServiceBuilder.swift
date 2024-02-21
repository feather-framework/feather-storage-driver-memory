//
//  MemoryStorageComponentBuilder.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherComponent

struct MemoryStorageComponentBuilder: ComponentBuilder {

    func build(
        using config: ComponentConfig
    ) throws -> Component {
        MemoryStorageComponent(config: config)
    }
}
