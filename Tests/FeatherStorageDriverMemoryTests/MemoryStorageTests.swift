//
//  FeatherStorageTests.swift
//  FeatherStorageTests
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import XCTest
@testable import FeatherStorageDriverMemory

final class MemoryStorageTests: XCTestCase {

    func testAdd() async throws {
        let storage = MemoryStorage()
        await storage.add(key: "foo", value: .init())

        let item1 = await storage.get(key: "foo")
        let storage1 = try XCTUnwrap(item1)
        let isFile1 = await storage1.isFile
        XCTAssertTrue(isFile1)

        await storage.add(key: "foo", value: nil)
        let item2 = await storage.get(key: "foo")
        let storage2 = try XCTUnwrap(item2)
        let isDirectory2 = await storage2.isDirectory
        XCTAssertTrue(isDirectory2)

        await storage.remove(key: "foo")
        let item3 = await storage.get(key: "foo")
        XCTAssertNil(item3)
    }

    func testExists() async throws {
        let storage = MemoryStorage()

        let exists1 = await storage.exists(key: "foo")
        XCTAssertFalse(exists1)

        await storage.add(key: "foo", value: .init())

        let exists2 = await storage.exists(key: "foo")
        XCTAssertTrue(exists2)
    }

    func testGet() async throws {
        let storage = MemoryStorage()
        await storage.add(key: "foo", value: nil)
        await storage.get(key: "foo")?.add(key: "baz", value: .init())

        let item1 = await storage.get(key: "foo")
        let storage1 = try XCTUnwrap(item1)
        let isDirectory1 = await storage1.isDirectory
        XCTAssertTrue(isDirectory1)

        let item2 = await storage.get(key: "bar")
        XCTAssertNil(item2)

        let item3 = await storage.get(key: "nope")
        XCTAssertNil(item3)

        let item4 = await storage.get(key: "baz")
        let storage2 = try XCTUnwrap(item4)
        let isDirectory2 = await storage2.isDirectory
        XCTAssertFalse(isDirectory2)
    }

    func testChildren() async throws {
        let storage = MemoryStorage()
        await storage.add(key: "a", value: nil)
        await storage.add(key: "b", value: nil)
        await storage.add(key: "c", value: nil)
        await storage.add(key: "foo", value: nil)
        await storage.get(key: "foo")?.add(key: "bar", value: .init())
        await storage.get(key: "bar")?.add(key: "baz", value: .init())

        let children = await storage.children
        var keys: [String] = []
        for child in children {
            let key = await child.key
            keys.append(key)
        }
        keys.sort()
        XCTAssertEqual(keys, ["a", "b", "c", "foo"])
    }

    func testSize() async throws {
        let storage = MemoryStorage()
        await storage.add(key: "a", value: nil)
        await storage.add(key: "b", value: .init(string: "foo"))

        let size1 = await storage.get(key: "a")?.size()
        let size2 = await storage.get(key: "b")?.size()

        XCTAssertEqual(size1, 0)
        XCTAssertEqual(size2, 3)
    }

    func testMultipart() async throws {
        let storage = MemoryStorage()

        let key = "foo"
        let multipartId = await storage.createMultipartUpload(
            key: key
        )
        let chunk1 = try await storage.addMultipartUploadChunk(
            key: key,
            multipartId: multipartId,
            number: 1,
            buffer: .init(string: "foo")
        )
        let chunk2 = try await storage.addMultipartUploadChunk(
            key: key,
            multipartId: multipartId,
            number: 2,
            buffer: .init(string: "bar")
        )
        let chunk3 = try await storage.addMultipartUploadChunk(
            key: key,
            multipartId: multipartId,
            number: 2,
            buffer: .init(string: "baz")
        )

        let parts: [MemoryStorage.Part] = [chunk1, chunk2, chunk3]
            .map {
                .init(id: $0.id, number: $0.number)
            }
        try await storage.finishMultipartUpload(
            key: key,
            multipartId: multipartId,
            parts: parts
        )

        let item = await storage.get(key: key)
        let object = try XCTUnwrap(item)
        let bfr = await object.buffer
        let buffer = try XCTUnwrap(bfr)
        let value = buffer.getString(at: 0, length: buffer.readableBytes)
        let exp = try XCTUnwrap(value)
        XCTAssertEqual(exp, "foobarbaz")
    }
}
