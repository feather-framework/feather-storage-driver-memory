//
//  MemoryStorageComponent.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import FeatherComponent
import FeatherStorage
import NIOCore

@dynamicMemberLookup
public struct MemoryStorageComponent {

    static let memoryStorage: MemoryStorage = .init()

    public let config: ComponentConfig

    subscript<T>(
        dynamicMember keyPath: KeyPath<MemoryStorageComponentContext, T>
    ) -> T {
        let context = config.context as! MemoryStorageComponentContext
        return context[keyPath: keyPath]
    }
}

extension MemoryStorageComponent {

    fileprivate func create(_ keys: [String]) async -> MemoryStorage {
        var storage = Self.memoryStorage
        for k in keys {
            if await storage.get(key: String(k)) == nil {
                await storage.add(key: String(k), value: nil)
            }
            storage = await storage.get(key: String(k))!
        }
        return storage
    }

    fileprivate func find(_ keys: [String]) async -> MemoryStorage? {
        var storage = Self.memoryStorage
        for k in keys {
            guard let s = await storage.get(key: String(k)) else {
                return nil
            }
            storage = s
        }
        return storage
    }

    fileprivate func find(_ key: String?) async -> MemoryStorage? {
        guard let key else {
            return Self.memoryStorage
        }
        let keys = key.split(separator: "/")
        return await find(keys.map(String.init))
    }
}

extension MemoryStorageComponent: StorageComponent {

    public var availableSpace: UInt64 { .max }

    public func uploadStream(
        key: String,
        sequence: StorageAnyAsyncSequence<ByteBuffer>
    ) async throws {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await create(keys.map(String.init))
        await storage.add(
            key: String(lastKey),
            value: try sequence.collect(upTo: Int.max)
        )
    }

    public func downloadStream(key: String, range: ClosedRange<Int>?)
        async throws -> StorageAnyAsyncSequence<ByteBuffer>
    {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await find(keys.map(String.init))

        guard let buffer = await storage?.get(key: String(lastKey))?.buffer
        else {
            throw StorageComponentError.invalidKey
        }
        if let range = range {
            var buffer = buffer
            buffer.moveReaderIndex(to: Int(range.lowerBound))
            let length = Int(range.upperBound - range.lowerBound) + 1
            guard let bytes = buffer.readBytes(length: length) else {
                throw StorageComponentError.invalidBuffer
            }
            return .init(
                asyncSequence: StorageByteBufferAsyncSequenceWrapper(
                    buffer: .init(bytes: bytes)
                ),
                length: UInt64(length)
            )

        }
        return .init(
            asyncSequence: StorageByteBufferAsyncSequenceWrapper(
                buffer: buffer
            ),
            length: UInt64(buffer.readableBytes)
        )
    }

    public func exists(key: String) async -> Bool {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await find(keys.map(String.init))
        return await storage?.exists(key: String(lastKey)) ?? false
    }

    public func size(key: String) async -> UInt64 {
        .init(await find(key)?.size() ?? 0)
    }

    public func copy(key source: String, to destination: String) async throws {
        let sourceKeys = source.split(separator: "/")
        guard let sourceStorage = await find(sourceKeys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }

        var destinationKeys = destination.split(separator: "/")
        let lastKey = destinationKeys.removeLast()
        let destinationStorage = await create(destinationKeys.map(String.init))
        await destinationStorage.add(
            key: String(lastKey),
            value: sourceStorage.buffer
        )
    }

    public func move(key source: String, to destination: String) async throws {
        try await copy(key: source, to: destination)
        try await delete(key: source)
    }

    public func list(key: String?) async throws -> [String] {
        let storage = await find(key)
        var res: [String] = []
        for child in await storage?.children ?? [] {
            res.append(child.key)
        }
        return res
    }

    public func delete(key: String) async throws {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        guard let storage = await find(keys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }
        await storage.remove(key: String(lastKey))
    }

    public func create(key: String) async throws {
        let keys = key.split(separator: "/")
        _ = await create(keys.map(String.init))
    }

    public func createMultipartId(
        key: String
    ) async throws -> String {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        guard let storage = await find(keys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }
        let id = await storage.createMultipartUpload(key: String(lastKey))

        return id
    }

    public func uploadStream(
        multipartId: String,
        key: String,
        number: Int,
        sequence: StorageAnyAsyncSequence<ByteBuffer>
    ) async throws -> FeatherStorage.StorageChunk {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        guard let storage = await find(keys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }
        let chunk = try await storage.addMultipartUploadChunk(
            key: String(lastKey),
            multipartId: multipartId,
            number: number,
            buffer: sequence.collect(upTo: Int.max)
        )

        return .init(chunkId: chunk.id, number: chunk.number)
    }

    public func abort(
        multipartId: String,
        key: String
    ) async throws {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        guard let storage = await find(keys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }
        try await storage.abortMultipartUpload(
            key: String(lastKey),
            multipartId: multipartId
        )
    }

    public func finish(
        multipartId: String,
        key: String,
        chunks: [StorageChunk]
    ) async throws {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        guard let storage = await find(keys.map(String.init)) else {
            throw StorageComponentError.invalidKey
        }
        try await storage.finishMultipartUpload(
            key: String(lastKey),
            multipartId: multipartId,
            parts: chunks.map {
                .init(id: $0.chunkId, number: $0.number)
            }
        )
    }
}
