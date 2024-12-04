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

struct NavHiddenModifier: ViewModifier {
    let isHidden: Bool
    
    @State var id = UUID().uuidString
    @State var initialValue: Bool = false

    @Environment(\.navEngineStyle) var navStyle
    
    func body(content: Content) -> some View {
        if navStyle.isHiddenOwner == id && navStyle.isHidden != isHidden {
            DispatchQueue.main.async {
                navStyle.isHidden = isHidden
            }
        }

        return content
            .onAppear {
                initialValue = navStyle.isHidden
                navStyle.isHidden = isHidden
                navStyle.isHiddenOwner = id
            }
            .onDisappear {
                if navStyle.isHiddenOwner == id {
                    navStyle.isHidden = initialValue
                    navStyle.isHiddenOwner = ""
                }
            }
    }
}
