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
    let title: String
    
    public init(route: T, title: String) {
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
            let vc = NavEngineHostingViewController(rootView: routeMap(routeWithTitle.route))
            vc.titleText = routeWithTitle.title
            navigation.pushViewController(vc, animated: true)
        }
        
        engine.onPush = { routeWithTitle in
            let vc = NavEngineHostingViewController(rootView: routeMap(routeWithTitle.route))
            vc.titleText = routeWithTitle.title
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

class NavEngineHostingViewController<Content: View>: UIHostingController<Content> {
    private let popGestureDelegate = InteractivePopGestureDelegate()
    var titleText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInteractivePopGestureCallbacks()
        if let titleText = titleText {
            self.title = titleText
        }
    }
    
    private func setupInteractivePopGestureCallbacks() {
        guard let navigationController = self.navigationController else { return }
        navigationController.delegate = popGestureDelegate
        navigationController.interactivePopGestureRecognizer?.delegate = popGestureDelegate

        popGestureDelegate.onInteractivePopStarted = { [weak self] in
            print("Interactive pop gesture started")
            self?.view.resignFirstResponder() // Dismiss keyboard
        }

        popGestureDelegate.onInteractivePopCancelled = { [weak self] in
            print("Interactive pop gesture cancelled")
            self?.reopenKeyboardIfNeeded() // Reopen keyboard
        }

        popGestureDelegate.onInteractivePopCompleted = {
            print("Interactive pop gesture completed")
            // No need to reopen the keyboard if the gesture completes
        }
    }

    private func reopenKeyboardIfNeeded() {
        // Assuming you have a reference to your text field or input view
        if let textField = self.view.findFirstResponder() as? UITextField {
            textField.becomeFirstResponder()
        }
    }

}
extension UIView {
    // Helper to find the first responder
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

class InteractivePopGestureDelegate: NSObject, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var onInteractivePopStarted: (() -> Void)?
    var onInteractivePopCancelled: (() -> Void)?
    var onInteractivePopCompleted: (() -> Void)?

    private var isInteractivePopInProgress = false

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.transitionCoordinator, coordinator.isInteractive {
            coordinator.notifyWhenInteractionChanges { context in
                if context.isCancelled {
                    // User cancelled the pop gesture
                    self.isInteractivePopInProgress = false
                    self.onInteractivePopCancelled?()
                } else {
                    // Pop gesture completed successfully
                    self.isInteractivePopInProgress = false
                    self.onInteractivePopCompleted?()
                }
            }
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let navigationController = gestureRecognizer.view?.findNavigationController(),
           navigationController.viewControllers.count > 1 {
            isInteractivePopInProgress = true
            onInteractivePopStarted?()
        }
        return true
    }
}

extension UIView {
    /// Recursively find the nearest `UINavigationController` in the view hierarchy.
    func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let navController = r as? UINavigationController {
                return navController
            }
            responder = r.next
        }
        return nil
    }
}
