//
//  LUTLoader.swift
//  Lutty
//
//  Created by Andrey Volodin on 29.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import Metal

public class LUTLoader {
    let device: MTLDevice

    public init(device: MTLDevice) {
        self.device = device
    }

    public func lut(from data: Data) throws -> MTLTexture {
        return data.withUnsafeBytes { p -> MTLTexture in
            let length = Int(p.baseAddress!.assumingMemoryBound(to: UInt8.self).pointee)

            let descriptor = MTLTextureDescriptor()
            descriptor.width = length
            descriptor.height = length
            descriptor.depth = length
            descriptor.textureType = .type3D
            descriptor.mipmapLevelCount = 1
            descriptor.arrayLength = 1
            descriptor.pixelFormat = .rgba8Unorm

            let texture = self.device.makeTexture(descriptor: descriptor)!
            texture.replace(region: texture.region,
                            mipmapLevel: 0,
                            slice: 0,
                            withBytes: p.baseAddress!
                                        .assumingMemoryBound(to: UInt8.self)
                                        .advanced(by: 1),
                            bytesPerRow: length * 4,
                            bytesPerImage: length * 4 * length)

            return texture
        }
    }
}
