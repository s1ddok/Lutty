//
//  SceneDelegate.swift
//  Lutty
//
//  Created by Andrey Volodin on 23.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import UIKit
import SwiftUI
import Alloy

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let context = MTLContext(device: Metal.device)
        let cat = UIImage(named: "women")!

        var filters: [Filter] = []
        for lutName in ["pretty", "bw", "contrast", "temp"] {
            let data = try! Data(contentsOf: Bundle.main.url(forResource: lutName, withExtension: "lut")!)
            filters.append(.init(id: filters.count, data: data))
        }

        let service = try! FilterService(context: context,
                                         image: cat.cgImage!,
                                         filters: filters)

        let contentView = ContentView(texture: ObservableTexture(texture: service.destinationTexture),
                                      filters: filters.map { FilterListEntry(id: $0.id,
                                                                             name: "XB-\($0.id)",
                                                                             imageName: "star.fill")})
                          .environmentObject(MTLContextWrapper(context: context))
                          .environmentObject(service)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

