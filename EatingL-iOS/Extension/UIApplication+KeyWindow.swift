//
//  UIApplication+KeyWindow.swift
//  PhotoK-iOS
//
//  Created by star on 2024/6/20.
//

import UIKit

extension UIApplication {

    @objc var eat_keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .last
    }

    var eat_window: UIWindow? {
        return EATSceneDelegate.eat_shared?.window
    }

    var eat_topViewController: UIViewController? {
        var topViewController = eat_keyWindow?.rootViewController

        while true {
            if let vc = topViewController as? EATMainViewController {
                topViewController = vc.selectedViewController
            } else if let vc = topViewController as? UINavigationController {
                topViewController = vc.topViewController
            } else if let vc = topViewController as? UITabBarController {
                topViewController = vc.selectedViewController
            } else if let vc = topViewController?.presentedViewController {
                topViewController = vc
            } else {
                break
            }
        }

        return topViewController
    }
}
