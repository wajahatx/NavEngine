//
//  File.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

extension EnvironmentValues {
    var navEngineStyle: NavEngineStyle {
        get { self[NavEngineStyleKey.self] }
        set { self[NavEngineStyleKey.self] = newValue }
    }

    var navEngineHidden: Binding<Bool> {
        get { self[NavEngineHiddenKey.self] }
        set { self[NavEngineHiddenKey.self] = newValue }
    }
    
    var navEngineTitle: Binding<String> {
        get { self[NavEngineTitleKey.self] }
        set { self[NavEngineTitleKey.self] = newValue }
    }
    
    var navEngineTitleContent: Binding<AnyView> {
        get { self[NavEngineTitleContentKey.self] }
        set { self[NavEngineTitleContentKey.self] = newValue }
    }
}

private struct NavEngineTitleKey: EnvironmentKey {
    static let defaultValue: Binding<String> = .constant("")
}

private struct NavEngineHiddenKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct NavEngineTitleContentKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Binding<AnyView> = .constant(AnyView(EmptyView()))
}


private struct NavEngineStyleKey: EnvironmentKey {
    static var defaultValue: NavEngineStyle {
        get {
            if Thread.isMainThread {
                return NavEngineStyle()
            } else {
                return DispatchQueue.main.sync { NavEngineStyle() }
            }
        }
    }
}

