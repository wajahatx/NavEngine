//
//  EngineRoute.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

/**
 A configuration object for navigation settings, including title settings and custom title content.
 */
public struct NavigationConfig: Equatable {
    /// Configuration for the title settings, such as the title text and back button display mode.
    var titleSettings: TitleConfiguration?
    
    /// A custom UIView for the navigation title content.
    let titleContent: UIView?
    
    /**
     Initializes a `NavigationConfig` with optional title settings and custom title content.
     
     - Parameters:
       - titleSettings: A `TitleConfiguration` instance containing the title text and back button display mode.
       - titleContent: An `AnyView` representing the custom title content for the navigation bar.
     */
    @MainActor
    public init(titleSettings: TitleConfiguration? = nil, titleContent: AnyView? = nil) {
        self.titleSettings = titleSettings
        self.titleContent = titleContent?.convertToUIView()
    }
}

/**
 A configuration for the title in the navigation bar, including the title text and back button display mode.
 */
public struct TitleConfiguration: Equatable {
    /// The title text to display in the navigation bar.
     let title: String?
    
    /// The display mode for the back button in the navigation bar.
     let backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode
    
    /**
     Initializes a new `TitleConfiguration` instance.
     
     - Parameters:
       - title: The title text to display in the navigation bar. Pass `nil` for no title.
       - backButtonDisplayMode: The display mode for the back button in the navigation bar.
     */
    public init(title: String?, backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode = .default) {
        self.title = title
        self.backButtonDisplayMode = backButtonDisplayMode
    }
}

/**
 A route object for the navigation engine, containing the route data and associated navigation configuration.
 
 - Note: The route data must conform to `Equatable` to allow comparison.
 */
public struct EngineRoute<T: Equatable>: Equatable {
    /// The route data.
    let route: T
    
    /// The configuration for navigation settings specific to this route.
    let navigationConfig: NavigationConfig
    
    /**
     Initializes an `EngineRoute` with a route and an optional navigation configuration.
     
     - Parameters:
       - route: The route data of type `T`.
       - navigationConfig: A `NavigationConfig` instance for configuring navigation settings. If `nil`, a default configuration is used.
     */
    @MainActor
    public init(route: T, navigationConfig: NavigationConfig?) {
        self.route = route
        self.navigationConfig = navigationConfig ?? NavigationConfig(titleSettings: nil, titleContent: nil)
    }
}
