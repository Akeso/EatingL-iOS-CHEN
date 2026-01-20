//
//  SceneDelegate.swift
//  PhotoK-iOS
//
//  Created by star on 2025/12/16.
//

import UIKit

class EATSceneDelegate: UIResponder, UIWindowSceneDelegate {

    static weak var eat_shared: EATSceneDelegate?

    var window: UIWindow?

    private var isPremiumClose = false

    @objc func eat_closePremiumController() {
        self.isPremiumClose = true
    }

    lazy var mainController: EATMainViewController = EATMainViewController()

    @objc func eat_reloadMainController() {
        DispatchQueue.main.async {
//            var controller: UIViewController?
//            if eat_isRetinaScreen() // 审核
//                || EATPremiumUserManager.eat_shared.eat_isPremium(isPurchased: true) // 是会员
//                || self.isPremiumClose { // 非强制模式点了x
//                controller = self.mainController
//            } else {
//                if eat_isLargeScreen() {
//                    let proController = EATPremiumDoubleViewController(source: .Launch)
//                    controller = proController
//                } else {
//                    let proController = EATPremiumViewController(source: .Launch)
//                    controller = proController
//                }
//            }

            self.window?.rootViewController = self.mainController
            self.window?.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        EATSceneDelegate.eat_shared = self

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = EATLaunchViewController()
        window?.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
//        EATAppFlyerManager.eat_shared.eat_didApplicationBeActive()
//        AppEvents.shared.activateApp()
//
//        // 刷新订阅状态
//        EATPremiumSubscriptionManager.shared.eat_refreshStatus()
//
//        EATNotificationManager.shared.eat_refreshAuthStatus()
//        EATNotificationManager.shared.eat_stopAllNotification()
//
//        // !!!优先添加此判断
//        if !UserDefaults.standard.bool(forKey: kUDKAppFirstBecomeActive) {
//            UserDefaults.standard.setValue(true, forKey: kUDKAppFirstBecomeActive)
//            return
//        }
//
//        // MARK: 处理系统弹框时弹广告的问题
//        if !EATSystemAlertManager.shared.isSystemAlertShowing {
//            EATAppOpenAdManager.eat_shared.eat_show(false)
//        }
//        EATSystemAlertManager.shared.isSystemAlertShowing = false
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
//        EATNotificationManager.shared.eat_stopAllNotification()
//        EATNotificationManager.shared.eat_addFunctionNotifications()
//        EATNotificationManager.shared.eat_addPeriodNotifications()
//        EATAsyncManager.shared.ptj_addBackgroudNotification()
//
//        if window?.rootViewController is EATPremiumBaseViewController {
//            EATEventUtil.eat_eventLaunchPremium(kEventLaunchPremiumTerminate)
//        }
    }
}
