//
//  String+Random.swift
//  FeatherStorageDriverMemory
//
//  Created by Tibor Bodecs on 17/11/2023.
//

extension String {

    static func random(length: Int = 16) -> String {
        let letters =
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
