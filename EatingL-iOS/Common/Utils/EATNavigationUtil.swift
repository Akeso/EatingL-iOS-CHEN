//
//  EATNavigationUtil.swift
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/24.
//

import Foundation

import UIKit

/// 全局导航工具类
class EATNavigationUtil: NSObject {
    
    /// 跳转到指定 Tab
    /// - Parameters:
    ///   - tab: 目标 Tab
    ///   - animated: 是否使用动画，默认为 true
    static func eat_navigateToTab(_ tab: EATMainTab, animated: Bool = true) {
        DispatchQueue.main.async {
            // 先退出所有 present 出的页面
            eat_dismissAllPresentedViewControllers()

            // 获取主窗口的根视图控制器
            guard let rootViewController = UIApplication.shared.eat_keyWindow?.rootViewController else {
                return
            }

            // 检查根控制器是否是主控制器
            if let mainViewController = rootViewController as? EATMainViewController {
                // 先关闭当前 Tab 的所有 viewController
                eat_closeAllViewControllers(in: mainViewController)

                // 跳转到指定 Tab
                mainViewController.eat_setTabSelected(tab)
            } else {
                // 如果根控制器不是主控制器，尝试查找主控制器
                if let topViewController = UIApplication.shared.eat_topViewController {
                    var currentVC: UIViewController? = topViewController
                    while currentVC?.presentingViewController != nil {
                        currentVC = currentVC?.presentingViewController
                        if let mainVC = currentVC as? EATMainViewController {
                            // 先关闭当前 Tab 的所有 viewController
                            eat_closeAllViewControllers(in: mainVC)
                            mainVC.eat_setTabSelected(tab)
                            break
                        }
                    }

                    // 如果找不到主控制器，关闭当前控制器
                    if currentVC == nil || !(currentVC is EATMainViewController) {
                        topViewController.eat_dismissToRoot()
                    }
                }
            }
        }
    }

    /// 退出所有 present 出的页面
    private static func eat_dismissAllPresentedViewControllers() {
        // 获取当前最顶层的视图控制器
        guard let topViewController = UIApplication.shared.eat_topViewController else {
            return
        }

        // 如果顶层控制器有 presentingViewController，说明它是被 present 出来的
        if topViewController.presentingViewController != nil {
            // 递归关闭所有 present 出的页面
            var currentVC: UIViewController? = topViewController
            while currentVC?.presentingViewController != nil {
                let presentingVC = currentVC?.presentingViewController
                currentVC?.dismiss(animated: false, completion: nil)
                currentVC = presentingVC
            }
        }
    }

    /// 关闭主控制器中所有 Tab 的 viewController
    /// - Parameter mainViewController: 主控制器
    private static func eat_closeAllViewControllers(in mainViewController: EATMainViewController?) {
        guard let mainVC = mainViewController else {
            return
        }

        // 使用 mainVC.tabControllers，确保只处理每个 tab 的导航控制器
        for tab in mainVC.mainTabs {
            if let nav = mainVC.tabControllers[tab] {
                nav.popToRootViewController(animated: false)
                // 再次确保只剩下根控制器
                if nav.viewControllers.count > 1, let rootVC = nav.viewControllers.first {
                    nav.viewControllers = [rootVC]
                }
            }
        }
    }
}
