//
//  AppDelegate.swift
//  PhotoK-iOS
//
//  Created by star on 2025/12/16.
//

import RxSwift
import UIKit

@main
class EATAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.setValue(false, forKey: kUDKAppFirstBecomeActive)

        if UserDefaults.standard.string(forKey: kUDKAppFirstConfig) == nil {
            UserDefaults.standard.set(kUDKAppFirst, forKey: kUDKAppFirstConfig)
        } else if UserDefaults.standard.string(forKey: kUDKAppFirstConfig) == kUDKAppFirst {
            UserDefaults.standard.set(kUDKAppNotFirst, forKey: kUDKAppFirstConfig)
        }

        // 初始化IAP
        // https://developer.apple.com/library/archive/technotes/tn2387/_index.html
//        EATPremiumManager.eat_shared.eat_addObserver()

//        EATAppLaunchUtil.eat_init(application: application, option: launchOptions ?? [:])

        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()

//        EATAsyncManager.shared.eat_restoreAPI()

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "EATSceneConfiguration",
                                    sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // 移除IAP
        // https://developer.apple.com/library/archive/technotes/tn2387/_index.html
//        EATPremiumManager.eat_shared.eat_removeObserver()
//
//        if UIApplication.shared.eat_window?.rootViewController is EATPremiumBaseViewController {
//            EATEventUtil.eat_eventLaunchPremium(kEventLaunchPremiumTerminate)
//        }
    }
}

extension EATAppDelegate: UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        EATEventUtil.eat_event(kEventNotificationDeviceToken)
//        EATAppFlyerManager.eat_shared.eat_registerUninstall(deviceToken: deviceToken)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\(response.notification.request.content.title)")
        print("\(response.notification.request.content.body)")
        print("\(response.notification.request.content.userInfo)")

//        let content = response.notification.request.content
//        if let value = content.userInfo[EATNotificationAction.key] as? Int,
//            let action = EATNotificationAction(rawValue: value) {
//            EATNotificationManager.shared.action = action
//            EATEventUtil.eat_event(kEventNotificationClick, values: ["action": action.rawValue])
//
//            // TD 事件上报
//            EATTDEventUtil.eat_event(kTDEventNotificationListSystemClick,
//                                     values: ["action": action.rawValue])
//        } else {
//            EATEventUtil.eat_event(kEventNotificationClick, values: ["action": "empty"])
//
//            // TD 事件上报
//            EATTDEventUtil.eat_event(kTDEventNotificationListSystemClick,
//                                     values: ["action": EATNotificationAction.none.rawValue])
//        }
//
//        EATNotificationManager.shared.eat_processNotification()
        
        completionHandler()
    }

}
