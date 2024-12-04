//
//  NavTitleModifier.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

struct NavTitleModifier: ViewModifier {
    let title: String
    
    @State var id = UUID().uuidString
    @State var initialValue: String = ""
    
    @Environment(\.navEngineStyle) var navStyle
    
    init(title: String) {
        self.title = title
    }

    func body(content: Content) -> some View {
        if navStyle.titleOwner == id && navStyle.title != title {
            DispatchQueue.main.async {
                navStyle.title = title
            }
        }

        return content
            .onAppear {
                initialValue = navStyle.title
                navStyle.title = title
                navStyle.titleOwner = id
            }
            .onDisappear {
                if navStyle.titleOwner == id {
                    navStyle.title = initialValue
                    navStyle.titleOwner = ""
                }
            }
    }
}
