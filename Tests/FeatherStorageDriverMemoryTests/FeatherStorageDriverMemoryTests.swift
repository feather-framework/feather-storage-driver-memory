//
//  FeatherStorageDriverMemoryTests.swift
//  FeatherStorageDriverMemoryTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import NIO
import Logging
import Foundation
import XCTest
import FeatherComponent
import FeatherStorage
import FeatherStorageDriverMemory
import XCTFeatherStorage

final class FeatherStorageDriverMemoryTests: XCTestCase {

    func testTestDriverUsingTestSuite() async throws {
        let registry = ComponentRegistry()
        try await registry.addStorage(MemoryStorageComponentContext())
        try await registry.run()

        let storage = try await registry.storage()
        let suite = StorageTestSuite(storage)
        do {
            try await suite.testAll()
            try await registry.shutdown()
        }
        catch {
            try await registry.shutdown()
            throw error
        }
    }
}
