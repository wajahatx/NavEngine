//
//  NavEngineStyle.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

public class NavEngineStyle: ObservableObject {
    @Published public var isHidden = false
    @Published public var title = ""
    @Published public var backButtonTint = UIColor.tintColor
    @Published public var titleContent: AnyView = AnyView(EmptyView())
    @Published public var backButtonTitleMode: UINavigationItem.BackButtonDisplayMode = .default
    
    public var isHiddenOwner: String = ""
    public var titleOwner: String = ""
    public var backButtonTintOwner: String = ""
    public var titleContentOwner: String = ""
    public var backButtonTitleModeOwner: String = ""
    
    public init() {}
}
