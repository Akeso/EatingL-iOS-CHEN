//
//  EATTabBarController.swift
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/2.
//

import RxSwift
import UIKit

class EATTabBarController: UITabBarController, UITabBarControllerDelegate {

    let disposeBag = DisposeBag()

    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return selectedViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        weak var weakself = self
        if let ws = weakself {
            delegate = ws
        }

        view.backgroundColor = UIColor("#000000")

        tabBar.tintColor = .clear

        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }

        // 强制 iPad 也使用 iPhone 的 TabBar 样式
        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
    }

    func eat_createTabItem(_ tab: EATMainTab) -> UITabBarItem {
        let icon = UIImage(named: tab.icon)?.withRenderingMode(.alwaysOriginal)
        let iconSelected = UIImage(named: tab.iconSelected)?.withRenderingMode(.alwaysOriginal)

        let item = UITabBarItem(title: tab.title,
                                image: icon,
                                selectedImage: iconSelected)
        item.tag = tab.rawValue
        return item
    }

    func eat_reloadTabAppearance(_ tab: EATMainTab) {
        let appearance = UITabBarAppearance()

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: tab.titleColor,
            .font: tab.titleFont
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes

        // 选中状态
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: tab.titleSelectedColor,
            .font: tab.titleSelectedFont
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        // 应用外观
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    
    func eat_observePointManager() {
//        EATTabPointManager.shared.pointReplay
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] hasRedPoint in
//                self?.eat_updateMineTabIcon(hasRedPoint: hasRedPoint)
//            })
//            .disposed(by: disposeBag)
    }
    
    private func eat_updateMineTabIcon(hasRedPoint: Bool) {
        guard let meVC = viewControllers?.first(where: { return $0.tabBarItem.tag == EATMainTab.me.rawValue }) else {
            return
        }

        if hasRedPoint {
            let redImage = UIImage(named: EATMainTab.me.iconBadge)?.withRenderingMode(.alwaysOriginal)
            meVC.tabBarItem.image = redImage
            meVC.tabBarItem.selectedImage = redImage
        } else {
            let normalImage = UIImage(named: EATMainTab.me.icon)?.withRenderingMode(.alwaysOriginal)
            let selectedImage = UIImage(named: EATMainTab.me.iconSelected)?.withRenderingMode(.alwaysOriginal)
            meVC.tabBarItem.image = normalImage
            meVC.tabBarItem.selectedImage = selectedImage
        }
    }
}
