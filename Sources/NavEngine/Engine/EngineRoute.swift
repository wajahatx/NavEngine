//
//  EngineRoute.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

public struct NavigationConfig: Equatable {
    var titleSettings: TitleConfiguration?
    let titleContent: UIView?

    @MainActor
    init(titleSettings: TitleConfiguration?, titleContent: AnyView?) {
        self.titleSettings = titleSettings
        self.titleContent = titleContent?.convertToUIView()
    }
}

public struct TitleConfiguration: Equatable  {
    let title: String?
    let backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode
}

public struct EngineRoute<T: Equatable>: Equatable {
    let route: T
    let navigationConfig: NavigationConfig
    
    @MainActor
       public init(route: T, navigationConfig: NavigationConfig?) {
           self.route = route
           self.navigationConfig = navigationConfig ?? NavigationConfig(titleSettings: nil, titleContent: nil)
       }
}
