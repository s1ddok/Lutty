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
    @ObservedObject var texture: ObservableTexture
    @EnvironmentObject var context: MTLContextWrapper

    public func makeUIView(context: Context) -> MTLTextureView {
        print("Metal view creation called")
        let view = MTLTextureView(device: context.coordinator.context.device)
        view.contentMode = .scaleAspectFit
        view.autoResizeDrawable = false
        context.coordinator.mtlView = view

        return view
    }

    public func updateUIView(_ mtlView: MTLTextureView, context: Context) {
        print("called update of metal view")

    }

    // MARK: Make coordinator

    public class Coordinator {
        let context: MTLContext
        let parent: MetalTextureView

        var mtlView: MTLTextureView?
        var canceller: AnyCancellable?

        public init(parent metalView: MetalTextureView, context: MTLContext) {
            self.parent = metalView
            self.context = context

            let canceller = metalView.texture.objectWillChange.receive(on: RunLoop.main).sink { () in
                print("hello I'm from coordinator")

                let texture = self.parent.texture.texture
                self.mtlView?.texture = texture
                self.mtlView?.drawableSize = CGSize(width: texture.width, height: texture.height)

                try! context.schedule { buffer in
                    self.mtlView?.draw(in: buffer)
                }

            }
            
            self.canceller = canceller
        }
    }

    public func makeCoordinator() -> Coordinator {
        print("Coordinator creation called")
        return Coordinator(parent: self, context: self.context.context)
    }
}
