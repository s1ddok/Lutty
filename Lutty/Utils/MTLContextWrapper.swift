//
//  MTLContextWrapper.swift
//  Lutty
//
//  Created by Andrey Volodin on 29.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import Alloy

public class MTLContextWrapper: ObservableObject {
    let context: MTLContext

    public init(context: MTLContext) {
        self.context = context
    }
}
