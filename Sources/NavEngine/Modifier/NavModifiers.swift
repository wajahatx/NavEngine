//
//  File.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

struct NavTitleContentModifier: ViewModifier {
    let view: AnyView
    
    @State var id = UUID().uuidString
    @State var initialValue: AnyView = AnyView(EmptyView())
    
    @Environment(\.navEngineStyle) var navStyle
    
    init(view: AnyView) {
        self.view = view
    }
    
    func body(content: Content) -> some View {
        
        return content
            .onAppear {
                initialValue = navStyle.titleContent
                navStyle.titleContent = view
                navStyle.titleContentOwner = id
            }
            .onDisappear {
                if navStyle.titleContentOwner == id {
                    navStyle.titleContent = initialValue
                    navStyle.titleContentOwner = ""
                }
            }
    }
}








