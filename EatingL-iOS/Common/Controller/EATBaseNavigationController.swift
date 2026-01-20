//
//  EATBaseNavigationController.swift
//  PhotoK-iOS
//
//  Created by Copper on 2021/1/25.
//

import UIKit

@objc protocol EATNavigationProtocol: NSObjectProtocol {
    /// 是否应该隐藏导航栏
    @objc optional func eat_isNavigationHidden() -> Bool
    /// 是否要返回根控制器
    @objc optional func eat_isPopToRoot() -> Bool
    /// 侧滑手势是否有效
    @objc optional func eat_isInteractivePopGestureEnable() -> Bool
}

class EATBaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置背景色，防止切换tab时闪白
        view.backgroundColor = UIColor("#000000")

        weak var weakself = self
        if let ws = weakself {
            delegate = ws
        }

        navigationBar.isTranslucent = true
        setNeedsStatusBarAppearanceUpdate()

        // 禁用系统滑动，替换成 popPanGesture
        interactivePopGestureRecognizer?.isEnabled = false
        view.addGestureRecognizer(popPanGesture)
    }

    /// 状态栏样式 -> 返回topViewController
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    fileprivate lazy var popGestureDelegate: UIGestureRecognizerDelegate? = {
        return interactivePopGestureRecognizer?.delegate
    }()

    lazy var popPanGesture: UIPanGestureRecognizer = {
        let sel: Selector? = Selector(("handleNavigationTransition:"))
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: popGestureDelegate, action: sel)
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        return pan
    }()

    // 是否重写了toRoot并且为true -> 返回root,侧滑root
    fileprivate var isPopToRoot: Bool {
        if let vc = topViewController as? EATNavigationProtocol,
           let result = vc.eat_isPopToRoot?() {
            return result
        } else {
            return false
        }
    }

    // 是否打开了手势
    fileprivate var isInteractiveEnable: Bool {
        if let vc = topViewController as? EATNavigationProtocol,
           let result = vc.eat_isInteractivePopGestureEnable?() {
            return result
        } else {
            return false
        }
    }

    // 是否隐藏导航栏
    fileprivate var isNavigationHidden: Bool {
        if let vc = topViewController as? EATNavigationProtocol,
           let result = vc.eat_isNavigationHidden?() {
            return result
        } else {
            return false
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true // push后隐藏TarBar
        }
        super.pushViewController(viewController, animated: animated)
    }

}

extension EATBaseNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view)
        let restrictedArea = CGRect(x: 0, y: 0, width: SCREEN_WIDTH*0.2, height: SCREEN_HEIGHT)
        return restrictedArea.contains(location)
    }
}

extension EATBaseNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        if isNavigationBarHidden != isNavigationHidden {
            setNavigationBarHidden(isNavigationHidden, animated: true)
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        let isRoot: Bool = viewController == navigationController.viewControllers.first
        popPanGesture.isEnabled = isInteractiveEnable && !isRoot

        if isInteractiveEnable && !isRoot && isPopToRoot {
            for vc in viewControllers {
                if !vc.isMember(of: (navigationController.viewControllers.first?.classForCoder)!)
                    && !vc.isMember(of: viewController.classForCoder) {
                    vc.removeFromParent()
                }
            }
        }
    }
}
