//
//  FilterList.swift
//  Lutty
//
//  Created by Andrey Volodin on 28.10.2019.
//  Copyright © 2019 Andrey Volodin. All rights reserved.
//

import SwiftUI

struct FilterList: View {
    let filters: [FilterListEntry]
    @Binding var selectedFilter: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<self.filters.count) { idx in
                    VStack {
                        Image(systemName: self.filters[idx].imageName)
                            .resizable()
                            .padding(4.0)
                            .frame(width: 48, height: 48)
                        Text(self.filters[idx].name)
                            .foregroundColor(Color.white)
                    }
                    .onTapGesture {
                        self.selectedFilter = idx == self.selectedFilter ? nil : idx
                    }
                    .padding(6.0)
                    .background(idx == self.selectedFilter ? Color.green : Color.blue)
                    .cornerRadius(6.0)
                }
            }
        }.frame(height: 96)
    }
}

