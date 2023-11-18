//
//  MemoryStorageService.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import NIOCore
import FeatherService
import FeatherStorage

@dynamicMemberLookup
public struct MemoryStorageService {

    let memoryStorage: MemoryStorage

    public let config: ServiceConfig

    subscript<T>(
        dynamicMember keyPath: KeyPath<MemoryStorageServiceContext, T>
    ) -> T {
        let context = config.context as! MemoryStorageServiceContext
        return context[keyPath: keyPath]
    }

    init(config: ServiceConfig) {
        self.config = config
        self.memoryStorage = .init()
    }
}

private extension MemoryStorageService {

    func create(_ keys: [String]) async -> MemoryStorage {
        var storage = memoryStorage
        for k in keys {
            if await storage.get(key: String(k)) == nil {
                await storage.add(key: String(k), value: nil)
            }
            storage = await storage.get(key: String(k))!
        }
        return storage
    }

    func find(_ keys: [String]) async -> MemoryStorage? {
        var storage = memoryStorage
        for k in keys {
            guard let s = await storage.get(key: String(k)) else {
                return nil
            }
            storage = s
        }
        return storage
    }

    func find(_ key: String?) async -> MemoryStorage? {
        guard let key else {
            return memoryStorage
        }
        let keys = key.split(separator: "/")
        return await find(keys.map(String.init))
    }
}

extension MemoryStorageService: StorageService {

    public var availableSpace: UInt64 { .max }

    public func upload(key: String, buffer: ByteBuffer) async throws {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await create(keys.map(String.init))
        await storage.add(key: String(lastKey), value: buffer)
        await storage.prettyPrint()
    }

    public func download(key: String, range: ClosedRange<UInt>?)
        async throws -> ByteBuffer
    {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await find(keys.map(String.init))

        guard let buffer = await storage?.get(key: String(lastKey))?.buffer
        else {
            throw StorageServiceError.invalidKey
        }
        //        if let range = range {
        //            var buffer = buffer
        //            buffer.moveReaderIndex(to: Int(range.lowerBound))
        //            let length = Int(range.upperBound - range.lowerBound)
        //            guard let bytes = buffer.readBytes(length: length) else {
        //                throw StorageServiceError.invalidResponse
        //            }
        //            return .init(bytes: bytes)
        //        }
        return buffer
    }

    public func exists(key: String) async -> Bool {
        var keys = key.split(separator: "/")
        let lastKey = keys.removeLast()
        let storage = await find(keys.map(String.init))
        return await storage?.exists(key: String(lastKey)) ?? false
    }

    public func size(key: String) async -> UInt64 {
        .init(await memoryStorage.get(key: key)?.size() ?? 0)
    }

    public func copy(key source: String, to destination: String) async throws {
        let sourceKeys = source.split(separator: "/")
        guard let sourceStorage = await find(sourceKeys.map(String.init)) else {
            throw StorageServiceError.invalidKey
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
            throw StorageServiceError.invalidKey
        }
        await storage.remove(key: String(lastKey))
    }

    public func create(key: String) async throws {
        let keys = key.split(separator: "/")
        let storage = await create(keys.map(String.init))
        await storage.prettyPrint()
    }

    public func createMultipartId(
        key: String
    ) async throws -> String {
        return ""
        //        return await memoryStorage.createMultipart()
    }

    public func upload(
        multipartId: String,
        key: String,
        number: Int,
        buffer: ByteBuffer
    ) async throws -> Multipart.Chunk {
        return .init(chunkId: "", number: 0)
        //        return await memoryStorage.uploadChunk(
        //            multipartId: multipartId,
        //            key: key,
        //            number: number,
        //            buffer: buffer
        //        )
    }

    public func abort(
        multipartId: String,
        key: String
    ) async throws {
        //        await memoryStorage.abort(
        //            multipartId: multipartId,
        //            key: key
        //        )
    }

    public func finish(
        multipartId: String,
        key: String,
        chunks: [Multipart.Chunk]
    ) async throws {
        //        await memoryStorage.finish(
        //            multipartId: multipartId,
        //            key: key,
        //            chunks: chunks
        //        )
    }
}
