//
//  EATToast.swift
//  PhotoK-iOS
//
//  Created by Copper on 2021/1/25.
//

import Toast_Swift
import UIKit

class EATToast: NSObject {

    static func show(in view: UIView, toast: String, completion: ((_ didTap: Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            view.makeToast(toast, duration: 3, position: ToastPosition.center, completion: completion)
        }
    }

    static func showLoading(in view: UIView, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            view.makeToastActivity(.center)
            DispatchQueue.main.asyncAfter(deadline: .now()+ToastManager.shared.style.fadeDuration) {
                completion?()
            }
        }
    }

    static func dismiss(in view: UIView, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            view.hideAllToasts(includeActivity: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+ToastManager.shared.style.fadeDuration) {
                completion?()
            }
        }
    }
}
