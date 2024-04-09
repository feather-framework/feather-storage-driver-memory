//
//  FeatherStorageDriverMemoryTests.swift
//  FeatherStorageDriverMemoryTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherComponent
import FeatherStorage
import FeatherStorageDriverMemory
import Foundation
import Logging
import NIO
import XCTFeatherStorage
import XCTest

final class FeatherStorageDriverMemoryTests: XCTestCase {

    func testTestDriverUsingTestSuite() async throws {
        let registry = ComponentRegistry()
        try await registry.addStorage(MemoryStorageComponentContext())

        let storage = try await registry.storage()
        let suite = StorageTestSuite(storage)
        try await suite.testAll()
    }
}
