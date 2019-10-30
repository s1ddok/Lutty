//
//  MetalView.swift
//  Lutty
//
//  Created by Andrey Volodin on 23.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import SwiftUI
import Alloy
import MTLTextureView
import UIKit
import Combine

public struct MetalTextureView: View, UIViewRepresentable {

    public typealias UIViewType = MTLTextureView

    @Binding var texture: MTLTexture
    @EnvironmentObject var context: MTLContextWrapper

    public func makeUIView(context: Context) -> MTLTextureView {
        let view = MTLTextureView(device: context.coordinator.context.device)
        view.contentMode = .scaleAspectFit
        view.autoResizeDrawable = false
        view.texture = texture
        view.drawableSize = CGSize(width: texture.width, height: texture.height)

        return view
    }

    public func updateUIView(_ mtlView: MTLTextureView, context: Context) {
        let texture = self.texture
        mtlView.texture = texture
        mtlView.drawableSize = CGSize(width: texture.width, height: texture.height)

        try! context.coordinator.context.schedule { buffer in
            mtlView.draw(in: buffer)
        }
    }

    // MARK: Make coordinator

    public class Coordinator {
        let context: MTLContext
        let parent: MetalTextureView

        public init(parent metalView: MetalTextureView, context: MTLContext) {
            self.parent = metalView
            self.context = context
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, context: self.context.context)
    }
}
