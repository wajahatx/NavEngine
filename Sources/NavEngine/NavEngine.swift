//
//  NavEngine.swift
//
//  Created by Wajahat on 20/11/2024.
//

import Foundation
import SwiftUI
import Combine
import UIKit

protocol Logger {
    func log(_ value: String)
}

class DebugLog: Logger {
    func log(_ value: String) {
        print(value)
    }
}

class EmptyLog: Logger {
    func log(_ value: String) {
        
    }
}


public struct EngineRoute<T: Equatable>: Equatable {
    let route: T
    let title: TitleContent

    public enum TitleContent: Equatable {
        case text(String)
        case view(AnyView)

        public static func == (lhs: TitleContent, rhs: TitleContent) -> Bool {
            switch (lhs, rhs) {
            case let (.text(l), .text(r)): return l == r
            case let (.view(l), .view(r)): return false
            default: return false
            }
        }
    }

    public init(route: T, title: TitleContent) {
        self.route = route
        self.title = title
    }
}

public class NavEngine<T: Equatable>: ObservableObject {
    private let logger: Logger
    private var _routes: [EngineRoute<T>] = []
    
    public var routes: [EngineRoute<T>] {
        return _routes
    }
    
    var onPush: ((EngineRoute<T>) -> Void)?
    var onPopLast: ((Int, Bool) -> Void)?

    public init(initial: EngineRoute<T>? = nil, debug: Bool = false) {
        logger = debug ? DebugLog() : EmptyLog()
        logger.log(" - engine Initialized.")
        
        if let initial = initial {
            push(initial)
        }
    }

    public func push(_ route: EngineRoute<T>) {
           logger.log(" - Pushing \(route) route.")
           self._routes.append(route)
           self.onPush?(route)
       }
   
       public func pop(animated: Bool = true) {
           if !self._routes.isEmpty {
               let popped = self._routes.removeLast()
               logger.log(" - \(popped) route popped.")
               onPopLast?(1, animated)
           }
       }
   
       public func popTo(_ route: EngineRoute<T>, inclusive: Bool = false, animated: Bool = true) {
           logger.log(": Popping route \(route).")
   
           if _routes.isEmpty {
               logger.log(" - Path is empty.")
               return
           }
   
           guard var found = _routes.lastIndex(where: { $0 == route }) else {
               logger.log(" - Route not found.")
               return
           }
   
           if !inclusive {
               found += 1
           }
   
           let numToPop = (found..<_routes.endIndex).count
           logger.log(" - Popping \(numToPop) routes")
           _routes.removeLast(numToPop)
           onPopLast?(numToPop, animated)
       }
   
       public func onSystemPop() {
           if !self._routes.isEmpty {
               let popped = self._routes.removeLast()
               logger.log(" - \(popped) route popped by system")
           }
       }

    public func updateRoute(at index: Int, with newRoute: EngineRoute<T>) {
        guard _routes.indices.contains(index) else { return }
        _routes[index] = newRoute
        objectWillChange.send()
    }
}
public struct NavEngineHost<T: Equatable, Screen: View>: View {
    @StateObject var navigationStyle = NavigationStyle()
    
    let engine: NavEngine<T>
    @ViewBuilder
    let routeMap: (T) -> Screen
    
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
        .environment(\.uipNavigationStyle, navigationStyle)
    }
}

struct NavigationControllerHost<T: Equatable, Screen: View>: UIViewControllerRepresentable {
    @ObservedObject var navigationStyle: NavigationStyle
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
            let vc = NavEngineHostingViewController<T, Screen>(rootView: routeMap(routeWithTitle.route))
            vc.titleContent = routeWithTitle.title
            navigation.pushViewController(vc, animated: true)
        }
        
        engine.onPush = { routeWithTitleContent in
            let vc = NavEngineHostingViewController<T, Screen>(rootView: routeMap(routeWithTitleContent.route))
            vc.titleContent = routeWithTitleContent.title

            switch routeWithTitleContent.title {
            case .text(let title):
                navigation.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
            case .view:
                navigation.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            }

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

class PopAwareUINavigationController: UINavigationController, UINavigationControllerDelegate {
    var popHandler: (() -> Void)?
    var stackSizeProvider: (() -> Int)?
    
    var popGestureBeganController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let stackSizeProvider = stackSizeProvider, stackSizeProvider() > navigationController.viewControllers.count {
            self.popHandler?()
        }
    }
}

extension View {
    public func uipNavigationBarHidden(_ hidden: Bool) -> some View {
        return modifier(NavHiddenModifier(isHidden: hidden))
    }
    
    public func uipNavigationTitle(_ title: String) -> some View {
        return modifier(NavTitleModifier(title: title))
    }
    public func uiNavigationBackButtonTint(_ tint: UIColor) -> some View {
        return modifier(BackButtonTintModifier(tint: tint))
    }
}

private struct NavigationTitleKey: EnvironmentKey {
    static let defaultValue: Binding<String> = .constant("")
}

private struct NavigationHiddenKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct NavigationStyleKey: EnvironmentKey {
    static var defaultValue: NavigationStyle {
        get {
            if Thread.isMainThread {
                return NavigationStyle()
            } else {
                return DispatchQueue.main.sync { NavigationStyle() }
            }
        }
    }
}

extension EnvironmentValues {
    var uipNavigationStyle: NavigationStyle {
        get { self[NavigationStyleKey.self] }
        set { self[NavigationStyleKey.self] = newValue }
    }

    var upNavigationHidden: Binding<Bool> {
        get { self[NavigationHiddenKey.self] }
        set { self[NavigationHiddenKey.self] = newValue }
    }
    
    var upNavigationTitle: Binding<String> {
        get { self[NavigationTitleKey.self] }
        set { self[NavigationTitleKey.self] = newValue }
    }
}

public class NavigationStyle: ObservableObject {
    @Published public var isHidden = false
    @Published public var title = ""
    @Published public var backButtonTint = UIColor.tintColor
    
    public var isHiddenOwner: String = ""
    public var titleOwner: String = ""
    public var backButtonTintOwner: String = ""
    
    public init() {}
}

struct BackButtonTintModifier: ViewModifier {
    let tint: UIColor
    
    @State var id = UUID().uuidString
    @State var initialValue: UIColor = .tintColor
    
    @Environment(\.uipNavigationStyle) var navStyle
    
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
    
    @Environment(\.uipNavigationStyle) var navStyle
    
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

    @Environment(\.uipNavigationStyle) var navStyle
    
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

class NavEngineHostingViewController<T: Equatable, Content: View>: UIHostingController<Content> {
    var titleContent: EngineRoute<T>.TitleContent?
    private var titleHostingController: UIHostingController<AnyView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitleContent()
    }

    func updateTitleContent() {
        switch titleContent {
        case .text(let title):
            self.title = title
            self.navigationItem.titleView = nil
        case .view(let titleView):
            if titleHostingController == nil {
                titleHostingController = UIHostingController(rootView: titleView)
                titleHostingController?.view.backgroundColor = .clear
                navigationItem.titleView = titleHostingController?.view
            } else {
                titleHostingController?.rootView = titleView
            }
        case .none:
            break
        }
    }
}

