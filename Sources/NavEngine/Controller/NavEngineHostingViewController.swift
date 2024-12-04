//
//  NavEngineHostingViewController.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

class NavEngineHostingViewController<Content: View>: UIHostingController<Content> {
    var navigationConfig: NavigationConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titleConfig = navigationConfig?.titleSettings {
            self.title = titleConfig.title
            self.navigationItem.backButtonDisplayMode = titleConfig.backButtonDisplayMode
        } else {
            self.title = nil
            self.navigationItem.backButtonDisplayMode = .generic
        }
        
        if let titleContent = navigationConfig?.titleContent {
            self.navigationItem.titleView = titleContent
        }
    }
}
