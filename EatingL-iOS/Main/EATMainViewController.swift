//
//  EATMainViewController.swift
//  AlmightyE-iOS
//
//  Created by star on 2022/6/30.
//

import RxCocoa
import RxSwift
import UIKit

class EATMainViewController: EATTabBarController {

    private lazy var editorController: EATBaseNavigationController = {
        let editorController = EATBaseNavigationController(rootViewController: EATEditorMainController())
        editorController.tabBarItem = eat_createTabItem(.editor)
        return editorController
    }()

    private lazy var stylesController: EATBaseNavigationController = {
        let stylesController = EATBaseNavigationController(rootViewController: EATStylesMainController())
        stylesController.tabBarItem = eat_createTabItem(.styles)
        return stylesController
    }()

    private lazy var meController: EATBaseNavigationController = {
        let meController = EATBaseNavigationController(rootViewController: EATMeMainController())
        meController.tabBarItem = eat_createTabItem(.me)
        return meController
    }()

    var mainTabs: [EATMainTab] {
        return [.editor, .styles, .me]
    }

    lazy private(set) var tabControllers: [EATMainTab: EATBaseNavigationController] = {
        return [
            .editor: editorController,
            .styles: stylesController,
            .me: meController
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        eat_initTabs()
        
        // 监听 PointManager 状态，动态更新 Me tab 图标
        eat_observePointManager()

        view.isUserInteractionEnabled = false
        EATAppLaunchUtil.eat_showEULA { [weak self] in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            print("finish EULA")
            self.eat_showLaunchAd()

// TODO 订阅
//            EATPremiumManager.eat_shared.eat_reportPremiumStatus()
        }

// TODO 订阅
//        EATEventUtil.eat_event(kEventAppMainPage)
//        if eat_isAppFirstLaunch() {
//            EATEventUtil.eat_event(kEventAppMainPageFirst)
//        }

        UserDefaults.standard.setValue(true, forKey: kUDKAppMainPage)

//        EATNotificationManager.shared.eat_processNotification()
    }

    func eat_setTabSelected(_ tab: EATMainTab) {
        if let index = mainTabs.firstIndex(of: tab) {
            selectedIndex = index
        }
    }

    private func eat_initTabs() {
        viewControllers = mainTabs.compactMap { tabControllers[$0] }

        if let tab = mainTabs.first {
            eat_setTabSelected(tab)
            eat_reloadTabAppearance(tab)
            eat_eventTab(tab)
        }
        
        eat_setupAllGeneratingViews()
    }
    
    private func eat_setupAllGeneratingViews() {
//        for type in EATMainTab.allCases {
//            guard type != .me else { continue }
//            if let vc = tabControllers[type]?.viewControllers.first as? EATBaseViewController {
//                EATGenerateStateManager.shared.eat_setupGenerateStateView(in: vc, for: type)
//            }
//        }
    }

    private func eat_eventTab(_ tab: EATMainTab) {
// TODO 订阅
//        switch tab {
//        case .explore:
//            EATEventUtil.eat_event(kEventTabExploreClick)
//        case .home:
//            EATEventUtil.eat_event(kEventTabhomeClick)
//        case .outfit:
//            EATEventUtil.eat_event(kEventTabAIOutfitClick)
//        case .me:
//            EATEventUtil.eat_event(kEventTabMineClick)
//        }
    }

    override func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tab = mainTabs[selectedIndex]

        eat_reloadTabAppearance(tab)
        eat_eventTab(tab)
    }
}

// MARK: - 广告
extension EATMainViewController {

    private func eat_showLaunchAd() {
// TODO 订阅
//        // 测试使用
//        if !kShowAd {
//            return
//        }
//
//        guard !eat_isAppFirstLaunch() else {
//            return
//        }
//
//        EATAppOpenAdManager.eat_shared.adStatus
//            .observe(on: MainScheduler.asyncInstance)
//            .filter({ $0 == .loaded })
//            .take(1)
//            .subscribe(onNext: { status in
//                if status == .loaded {
//                    print("launch ad loaded")
//                    EATAppOpenAdManager.eat_shared.eat_show(true)
//                }
//            }).disposed(by: disposeBag)
    }
}

class EATAppLaunchUtil {

    static func eat_showEULA(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
            // 临时解决方案：直接调用完成回调，确保用户交互能够恢复
            completion()
            // TODO: 需要实现EULA弹窗逻辑
//            EATEULAPopUpView {
//                completion()
//                eat_showPush(completion)
//            } cancelCompletion: {
//
//            }.eat_show()
        }
    }

    static func eat_showPush(_ completion: @escaping () -> Void) {
//        EATNotificationManager.shared.eat_requestAuth { _ in
//            completion()
//        }
    }
}
