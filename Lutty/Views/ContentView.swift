//
//  ContentView.swift
//  Lutty
//
//  Created by Andrey Volodin on 23.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import SwiftUI
import Alloy

struct ContentView: View {
    @State var selectedFilter: Int? = nil
    @State var shouldShowOriginal: Bool = false
    @State var intensity: Float = 1.0

    @ObservedObject var texture: ObservableTexture

    @EnvironmentObject var context: MTLContextWrapper
    @EnvironmentObject var service: FilterService

    let filters: [FilterListEntry]

    var body: some View {
        let intensityBinding = Binding<Float>(get: { self.intensity },
                                              set: { newValue in
                                                self.intensity = newValue
                                                try! self.updateLUT()
                                              })

        let selectedFilterBinding = Binding<Int?>(get: { self.selectedFilter },
                                                  set: { newValue in
                                                     self.selectedFilter = newValue
                                                     try! self.updateLUT()
                                                  })

        return VStack {
            ZStack {
                MetalTextureView(texture: self.$texture.texture)

                if self.selectedFilter != nil {
                    VStack {
                        ZStack {
                            // This is a hack so that gesture is recognized,
                            // .clear doesn't work
                            Color.black.opacity(0.001)
                            Spacer()
                        }.gesture(self.holdToSeeOriginalGesture)
                        Slider(value: intensityBinding)
                    }
                }
            }
            FilterList(filters: self.filters, selectedFilter: selectedFilterBinding)
        }
    }

    var holdToSeeOriginalGesture: some Gesture {
        let longPressDrag = LongPressGesture()
                            .onEnded { value in
                                self.shouldShowOriginal = value
                                try! self.updateLUT()
                            }.sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded { value in
                                self.shouldShowOriginal = false
                                try! self.updateLUT()
                            })

        return longPressDrag
    }

    private func updateLUT() throws {
        guard let filterId = self.selectedFilter, !self.shouldShowOriginal else {
            self.texture.texture = self.service.originalTexture
            return
        }

        try self.service.apply(filterId: filterId, intensity: self.intensity) { texture in
            DispatchQueue.main.async {
                self.texture.texture = texture
            }
        }
    }
}
