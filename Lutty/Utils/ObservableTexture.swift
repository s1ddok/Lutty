//
//  BinadableTexture.swift
//  Lutty
//
//  Created by Andrey Volodin on 29.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import Combine
import Metal
import SwiftUI

public final class ObservableTexture: ObservableObject {
    var texture: MTLTexture {
        didSet {
            self.objectWillChange.send(self.texture)
        }
    }

    public init(texture: MTLTexture) {
        self.texture = texture
    }

    public let objectWillChange = PassthroughSubject<MTLTexture, Never>()
}
