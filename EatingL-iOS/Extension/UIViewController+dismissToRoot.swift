//
//  UIView+dismissToRoot.swift
//  PulseF-iOS
//
//  Created by weikunchao on 2022/5/9.
//

import UIKit

extension UIViewController {

    func eat_dismissToRoot(animated: Bool = true) {
        if let navigationController = self.navigationController {
            if let presentingNavVC = navigationController.presentingViewController {
                var presentingVC: UIViewController? = presentingNavVC
                while presentingVC?.presentingViewController != nil {
                    presentingVC = presentingVC?.presentingViewController
                }

                presentingVC?.dismiss(animated: animated)

                if presentingVC is EATMainViewController {
                    let mainVC = presentingVC as? EATMainViewController
                    let mainNavigationVC = mainVC?.selectedViewController as? UINavigationController
                    mainNavigationVC?.popToRootViewController(animated: false)
                }
            } else {
                navigationController.popToRootViewController(animated: animated)
            }
        } else {
            var presentingVC: UIViewController? = self
            while presentingVC?.presentingViewController != nil {
                presentingVC = presentingVC?.presentingViewController
            }
            if presentingVC is EATMainViewController {
                let mainVC = presentingVC as? EATMainViewController
                let mainNavigationVC = mainVC?.selectedViewController as? UINavigationController
                mainNavigationVC?.popToRootViewController(animated: false)
            }
            presentingVC?.dismiss(animated: animated)
        }
    }

    func eat_dismissToWindow() {
        var presentingVC: UIViewController? = self
        while presentingVC?.presentingViewController != nil {
            presentingVC = presentingVC?.presentingViewController
        }
        presentingVC?.dismiss(animated: true)
    }

    /// Dismiss到指定类型的控制器
    func eat_dismissToController<T: UIViewController>(ofType type: T.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        var currentController: UIViewController? = self
        while let presentingVC = currentController?.presentingViewController {
            if presentingVC is T {
                presentingVC.dismiss(animated: animated, completion: completion)
                return
            }
            currentController = presentingVC
        }
    }

    /// tab.navigationcontroler.push->list.present->xxx.present->result.dismiss->list
    func eat_dismissToRootWithoutNavigationController() {
        var presentingVC: UIViewController? = self
        while presentingVC?.presentingViewController != nil {
            presentingVC = presentingVC?.presentingViewController
        }
        presentingVC?.dismiss(animated: true)
    }
}
