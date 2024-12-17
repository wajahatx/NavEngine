//
//  BackButtonDisplayModeModifier.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

struct BackButtonDisplayModeModifier: ViewModifier {
    let displayMode: UINavigationItem.BackButtonDisplayMode
    @State private var id = UUID().uuidString
    @State private var initialValue: UINavigationItem.BackButtonDisplayMode = .default

    @Environment(\.navEngineStyle) private var navStyle

    init(displayMode: UINavigationItem.BackButtonDisplayMode) {
        self.displayMode = displayMode
    }

    func body(content: Content) -> some View {
        if navStyle.backButtonTitleModeOwner == id && navStyle.backButtonTitleMode != displayMode {
            DispatchQueue.main.async {
                navStyle.backButtonTitleMode = displayMode
            }
        }

        return content
            .onAppear {
                initialValue = navStyle.backButtonTitleMode
                navStyle.backButtonTitleMode = displayMode
                navStyle.backButtonTitleModeOwner = id
            }
            .onDisappear {
                if navStyle.backButtonTitleModeOwner == id {
                    navStyle.backButtonTitleMode = initialValue
                    navStyle.backButtonTitleModeOwner = ""
                }
            }
    }
}
