//
//  FilterService.swift
//  Lutty
//
//  Created by Andrey Volodin on 29.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import Alloy

public class FilterService: ObservableObject {
    public enum Errors: Error {
        case filterNotFound
    }

    public let context: MTLContext

    public let originalTexture: MTLTexture
    public let destinationTexture: MTLTexture

    private let lutEncoder: LookUpTableEncoder
    private let luts: [Int: MTLTexture]

    public init(context: MTLContext, image: CGImage, filters: [Filter]) throws {
        self.context = context
        self.lutEncoder = try LookUpTableEncoder(context: context)
        self.originalTexture = try context.texture(from: image)
        self.destinationTexture = self.originalTexture
                                      .matchingTexture(usage: [.shaderRead, .shaderWrite])!

        var parsedLUTs: [Int: MTLTexture] = [:]

        let loader = LUTLoader(device: context.device)
        for filter in filters {
            parsedLUTs[filter.id] = try loader.lut(from: filter.data)
        }

        self.luts = parsedLUTs
    }

    public func apply(filterId: Int, intensity: Float, completion: @escaping (MTLTexture) -> Void) throws {
        guard let lut = self.luts[filterId] else {
            throw Errors.filterNotFound
        }

        try self.context.schedule { buffer in
            self.lutEncoder.encode(sourceTexture: self.originalTexture,
                                   outputTexture: self.destinationTexture,
                                   lut: lut,
                                   intensity: intensity,
                                   in: buffer)
            buffer.addCompletedHandler { _ in
                completion(self.destinationTexture)
            }
        }
    }
}
