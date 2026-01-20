//
//  EATBaseViewController.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import RxSwift
import UIKit

class EATBaseViewController: UIViewController, EATNavigationProtocol {

    var disposeBag = DisposeBag()

    func eat_isNavigationHidden() -> Bool {
        return true
    }

    func eat_isInteractivePopGestureEnable() -> Bool {
        return true
    }

    func eat_isPopToRoot() -> Bool {
        return false
    }

    var eat_showBg: Bool {
        return true
    }

    func eat_popCompletion() {}

    private lazy var bgView: UIImageView = {
        let bgView = UIImageView()
        bgView.contentMode = .scaleAspectFill
        bgView.backgroundColor = UIColor("#000000")
        if eat_showBg {
            bgView.image = UIImage(named: "tab_bg")
        }
        return bgView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(bgView)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 禁用隐式动画，避免iOS 16+ push时的隐式动画问题
        UIView.performWithoutAnimation {
            view.layoutIfNeeded()
        }
    }

    deinit {
        debugPrint("\(Swift.type(of: self)):\(#line) is dealloc!!!")
        NotificationCenter.default.removeObserver(self)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        let parentClassName = parent.map { String(describing: type(of: $0)) } ?? "nil"
        let parentAddress = parent.map { String(format: "%p", unsafeBitCast($0, to: Int.self)) } ?? "nil"
        debugPrint("\(Swift.type(of: self)):\(#line) will move to parent: \(parentClassName) [address: \(parentAddress)]")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        let parentClassName = parent.map { String(describing: type(of: $0)) } ?? "nil"
        let parentAddress = parent.map { String(format: "%p", unsafeBitCast($0, to: Int.self)) } ?? "nil"
        debugPrint("\(Swift.type(of: self)):\(#line) did move to parent: \(parentClassName) [address: \(parentAddress)]")
        if parent == nil {
            debugPrint("\(Swift.type(of: self)):\(#line) push controller leave")
            eat_popCompletion()
        }
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if UIDevice.current.userInterfaceIdiom == .pad
            && viewControllerToPresent.modalPresentationStyle != .fullScreen {
            viewControllerToPresent.modalPresentationStyle = .formSheet
            viewControllerToPresent.preferredContentSize = SCREEN_BOUNDS.size
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
