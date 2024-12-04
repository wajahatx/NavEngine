//
//  NavEngine.swift
//
//  Created by Wajahat on 20/11/2024.
//

import Foundation
import SwiftUI
import UIKit

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
