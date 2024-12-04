//
//  NavEngineHost.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import SwiftUI

public struct NavEngineHost<T: Equatable, Screen: View>: View {
    @StateObject var navigationStyle = NavEngineStyle()
    
    let engine: NavEngine<T>
    @ViewBuilder
    let routeMap: (T) -> Screen
    
    /**
     Initializes a `NavEngineHost` view.

     - Parameters:
       - engine: An instance of `NavEngine` that manages the navigation state.
       - routeMap: A closure that maps a route of type `T` to a `Screen` view.
     
     - Note: The route map closure determines the view displayed for each route in the navigation engine.
     */
    public init(_ engine: NavEngine<T>, @ViewBuilder _ routeMap: @escaping (T) -> Screen) {
        self.engine = engine
        self.routeMap = routeMap
    }

    public var body: some View {
        NavigationControllerHost(
            navigationStyle: navigationStyle,
            engine: engine,
            routeMap: routeMap
        )
        .environmentObject(engine)
        .environment(\.navEngineStyle, navigationStyle)
    }
}
struct NavigationControllerHost<T: Equatable, Screen: View>: UIViewControllerRepresentable {
    @ObservedObject var navigationStyle: NavEngineStyle
    let engine: NavEngine<T>
    
    @ViewBuilder
    var routeMap: (T) -> Screen

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigation = PopAwareUINavigationController()
        
        navigation.popHandler = {
            engine.onSystemPop()
        }
        navigation.stackSizeProvider = {
            engine.routes.count
        }
        
        for routeWithTitle in engine.routes {
            let vc = NavEngineHostingViewController(rootView: routeMap(routeWithTitle.route))
            vc.title = routeWithTitle.navigationConfig.titleSettings?.title ?? ""
            vc.navigationItem.backButtonDisplayMode = routeWithTitle.navigationConfig.titleSettings?.backButtonDisplayMode ?? .default
            vc.navigationItem.titleView = routeWithTitle.navigationConfig.titleContent
            navigation.pushViewController(vc, animated: true)
        }
        
        engine.onPush = { routeWithTitle in
            let vc = NavEngineHostingViewController(rootView: routeMap(routeWithTitle.route))
            vc.title = routeWithTitle.navigationConfig.titleSettings?.title ?? ""
            vc.navigationItem.backButtonDisplayMode = routeWithTitle.navigationConfig.titleSettings?.backButtonDisplayMode ?? .default
            vc.navigationItem.titleView = routeWithTitle.navigationConfig.titleContent
            navigation.pushViewController(vc, animated: true)
        }
        
     
        
        engine.onPopLast = { numToPop, animated in
            if numToPop == navigation.viewControllers.count {
                navigation.viewControllers = []
            } else {
                let popTo = navigation.viewControllers[navigation.viewControllers.count - numToPop - 1]
                navigation.popToViewController(popTo, animated: animated)
            }
        }
                        
        return navigation
    }
    
    func updateUIViewController(_ navigation: UINavigationController, context: Context) {
        navigation.topViewController?.navigationController?.navigationBar.tintColor = navigationStyle.backButtonTint
        navigation.navigationBar.isHidden = navigationStyle.isHidden
    }
    
    static func dismantleUIViewController(_ navigation: UINavigationController, coordinator: ()) {
        navigation.viewControllers = []
        (navigation as! PopAwareUINavigationController).popHandler = nil
    }
        
    typealias UIViewControllerType = UINavigationController
}
