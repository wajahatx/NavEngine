//
//  PopAwareUINavigationController.swift
//  NavEngine
//
//  Created by Amish on 04/12/2024.
//

import UIKit

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
