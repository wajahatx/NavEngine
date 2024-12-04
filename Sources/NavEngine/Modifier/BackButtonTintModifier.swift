//
//  BackButtonTintModifier.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

struct BackButtonTintModifier: ViewModifier {
    let tint: UIColor
    
    @State var id = UUID().uuidString
    @State var initialValue: UIColor = .tintColor
    
    @Environment(\.navEngineStyle) var navStyle
    
    init(tint: UIColor) {
        self.tint = tint
    }

    func body(content: Content) -> some View {
        if navStyle.backButtonTintOwner == id && navStyle.backButtonTint != tint {
            DispatchQueue.main.async {
                navStyle.backButtonTint = tint
            }
        }

        return content
            .onAppear {
                initialValue = navStyle.backButtonTint
                navStyle.backButtonTint = tint
                navStyle.backButtonTintOwner = id
            }
            .onDisappear {
                if navStyle.backButtonTintOwner == id {
                    navStyle.backButtonTint = initialValue
                    navStyle.backButtonTintOwner = ""
                }
            }
    }
}
