//
//  File.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

extension View {
    /**
     Hides or shows the navigation bar for the current view.

     - Parameter hidden: A boolean value indicating whether the navigation bar should be hidden.
     - Returns: A view with the navigation bar visibility modified.
    */
    public func navEngineBarHidden(_ hidden: Bool) -> some View {
        return modifier(NavHiddenModifier(isHidden: hidden))
    }
    
    /**
     Sets the tint color of the back button in the navigation bar.

     - Parameter tint: A `UIColor` value representing the color to use for the back button.
     - Returns: A view with the back button tint color modified.
    */
    public func navEngineBackButtonTint(_ tint: UIColor) -> some View {
        return modifier(BackButtonTintModifier(tint: tint))
    }
    
    /**
     Sets the title for the navigation bar.

     - Parameter title: A `String` representing the title to display in the navigation bar.
     - Returns: A view with the navigation bar title modified.
    */
    private func navEngineTitle(_ title: String) -> some View {
        return modifier(NavTitleModifier(title: title))
    }
    
    /**
     Sets the display mode of the back button in the navigation bar.

     - Parameter displayMode: A `UINavigationItem.BackButtonDisplayMode` value specifying the display mode of the back button.
     - Returns: A view with the back button display mode modified.
    */
    private func navEngineBackButtonDisplayMode(_ displayMode: UINavigationItem.BackButtonDisplayMode) -> some View {
        return modifier(BackButtonDisplayModeModifier(displayMode: displayMode))
    }
    
    /**
     Adds a custom view as the title content for the navigation bar.

     - Parameter titleContent: An `AnyView` representing the custom content to display as the title in the navigation bar.
     - Returns: A view with the navigation bar title content modified.
    */
    private func navEngineTitleContent(_ titleContent: AnyView) -> some View {
        modifier(NavTitleContentModifier(view: titleContent))
    }
}

extension AnyView {
    /**
     Converts an `AnyView` into a `UIView` using a `UIHostingController`.

     - Note: This method runs on the main thread, as it modifies the UI.

     - Returns: A `UIView` instance that wraps the SwiftUI `AnyView`.
    */
    @MainActor
    func convertToUIView() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        return hostingController.view
    }
}
