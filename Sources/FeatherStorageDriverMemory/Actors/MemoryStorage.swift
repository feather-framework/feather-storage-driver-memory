//
//  MemoryStorage.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 07/11/2023.
//

import NIOCore

enum MemoryStorageComponentError: Error {
    case invalidKey
    case invalidMultipartId
    case invalidMultipartChunks
}

final actor MemoryStorage {
    private static let rootKey = "[root]"

    public struct Part: Sendable {
        public let id: String
        public let number: Int

        public init(id: String, number: Int) {
            self.id = id
            self.number = number
        }
    }

    public struct Chunk: Sendable {
        public let id: String
        public let number: Int
        public let buffer: ByteBuffer
    }

    public let key: String
    public private(set) var buffer: ByteBuffer?
    public private(set) var children: [MemoryStorage]
    private var multiparts: [String: [Chunk]]

    public var isDirectory: Bool { buffer == nil }
    public var isFile: Bool { !isDirectory }

    public init() {
        self.init(key: MemoryStorage.rootKey)
    }

    private init(
        key: String,
        buffer: ByteBuffer? = nil,
        multiparts: [String: [Chunk]] = [:],
        children: [MemoryStorage] = []
    ) {
        self.key = key
        self.buffer = buffer
        self.multiparts = multiparts
        self.children = children
    }

    // MARK: -

    public func setBuffer(_ value: ByteBuffer?) {
        buffer = value
        multiparts = [:]
        children = []
    }

    public func size() -> Int {
        buffer?.readableBytes ?? 0
    }

    private func addMultipart(_ id: String) {
        multiparts[id] = []
    }

    private func addMultipartChunk(_ id: String, _ chunk: Chunk) throws {
        guard multiparts[id] != nil else {
            throw MemoryStorageComponentError.invalidMultipartId
        }
        multiparts[id]!.append(chunk)
    }

    private func removeMultipart(_ id: String) throws {
        guard multiparts[id] != nil else {
            throw MemoryStorageComponentError.invalidMultipartId
        }
        multiparts[id] = nil
    }

    private func getMultipartChunks(_ id: String) throws -> [Chunk] {
        guard multiparts[id] != nil else {
            throw MemoryStorageComponentError.invalidMultipartId
        }
        return multiparts[id]!
    }

    // MARK: -

    public func get(key: String) async -> MemoryStorage? {
        for child in children {
            if child.key == key {
                return child
            }
            if let item = await child.get(key: key) {
                return item
            }
        }
        return nil
    }

    public func add(key: String, value: ByteBuffer?) async {
        if let child = await get(key: key) {
            return await child.setBuffer(value)
        }
        children.append(.init(key: key, buffer: value))
    }

    public func firstIndex(key: String) -> Int? {
        children.firstIndex(where: { $0.key == key })
    }

    public func exists(key: String) -> Bool {
        firstIndex(key: key) != nil
    }

    public func remove(key: String) {
        if let index = firstIndex(key: key) {
            children.remove(at: index)
        }
    }

    // MARK: -

    public func createMultipartUpload(key: String) async -> String {
        await add(key: key, value: nil)
        let id = String.random()
        await get(key: key)?.addMultipart(id)
        return id
    }

    public func addMultipartUploadChunk(
        key: String,
        multipartId: String,
        number: Int,
        buffer: ByteBuffer
    ) async throws -> Chunk {
        let chunkId = String.random()
        let chunk = Chunk(id: chunkId, number: number, buffer: buffer)
        guard let storage = await get(key: key) else {
            throw MemoryStorageComponentError.invalidKey
        }
        try await storage.addMultipartChunk(multipartId, chunk)
        return chunk
    }

    public func abortMultipartUpload(
        key: String,
        multipartId: String
    ) async throws {
        guard let storage = await get(key: key) else {
            throw MemoryStorageComponentError.invalidKey
        }
        try await storage.removeMultipart(multipartId)
    }

    public func finishMultipartUpload(
        key: String,
        multipartId: String,
        parts: [Part]
    ) async throws {
        guard let storage = await get(key: key) else {
            throw MemoryStorageComponentError.invalidKey
        }
        let allParts = try await storage.getMultipartChunks(multipartId)
        let finalParts =
            allParts.filter { p in
                parts.contains {
                    p.id == $0.id && p.number == $0.number
                }
            }
            .sorted(by: { $0.number < $1.number })

        guard parts.count == finalParts.count else {
            throw MemoryStorageComponentError.invalidMultipartChunks
        }

        var buffer = ByteBuffer()
        for part in finalParts {
            var readBuffer = part.buffer
            buffer.writeBuffer(&readBuffer)
        }

        await storage.setBuffer(buffer)
    }
}

extension MemoryStorage {

    public func prettyPrint(_ level: Int = 0) async {
        let indent = Array(repeating: "    ", count: level).joined()
        print("\(indent)\(key)")
        for child in children {
            await child.prettyPrint(level + 1)
        }
    }
}
