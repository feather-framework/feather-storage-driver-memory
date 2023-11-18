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
import FeatherService
import FeatherStorage
import FeatherStorageDriverMemory
import XCTFeatherStorage

final class FeatherStorageDriverMemoryTests: XCTestCase {

    func testTestDriverUsingTestSuite() async throws {
        let registry = ServiceRegistry()
        try await registry.add(.memoryStorage(), as: .memoryStorage)
        try await registry.run()

        let storage = try await registry.get(.memoryStorage) as! StorageService
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
