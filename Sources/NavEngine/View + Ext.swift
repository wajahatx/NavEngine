//
//  File.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

extension View {
    public func navEngineBarHidden(_ hidden: Bool) -> some View {
        return modifier(NavHiddenModifier(isHidden: hidden))
    }
    
    public func navEngineBackButtonTint(_ tint: UIColor) -> some View {
        return modifier(BackButtonTintModifier(tint: tint))
    }
    
    private func navEngineTitle(_ title: String) -> some View {
        return modifier(NavTitleModifier(title: title))
    }
    
    private func navEngineBackButtonDisplayMode(_ displayMode: UINavigationItem.BackButtonDisplayMode) -> some View {
        return modifier(BackButtonDisplayModeModifier(displayMode: displayMode))
    }
    
    private func navEngineTitleContent(_ titleContent: AnyView) -> some View {
        modifier(NavTitleContentModifier(view: titleContent))
    }
}

extension AnyView {
    @MainActor
    func convertToUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
              hostingController.view.backgroundColor = .clear
              hostingController.view.translatesAutoresizingMaskIntoConstraints = false
              return hostingController.view
    }
}
