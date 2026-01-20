
//
//  EATGaussianBlurView.swift
//  PhotoK-iOS
//
//  Created by tongshuai on 12/22/25.
//
import UIKit

class EATGaussianBlurView: EATBaseView {

    private var effect: UIBlurEffect?
    private lazy var effectView = UIVisualEffectView(effect: nil)
    private var animator: UIViewPropertyAnimator?
    private var _intensity: CGFloat = 0

    /// 模糊度
    public var intensity: CGFloat {
        get { _intensity }
        set {
            _intensity = (newValue > 1) ? 1 : (newValue < 0 ? 0 : newValue)
            eat_resetAnimator()
        }
    }

    func eat_reload() {
        self.intensity = 0.25
    }

    convenience init(effectStyle: UIBlurEffect.Style) {
        self.init()

        self.effect = UIBlurEffect(style: effectStyle)
        eat_setupEffectView()

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(eat_willEnterForegroundHandle),
                         name: UIApplication.willEnterForegroundNotification,
                         object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        animator?.stopAnimation(true)
    }

    @objc func eat_willEnterForegroundHandle() {
        guard animator?.state != .active else { return }
        animator?.stopAnimation(true)
        eat_resetAnimator()
    }

    private func eat_setupEffectView() {
        addSubview(effectView)

        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func eat_resetAnimator() {
        DispatchQueue.main.async {
            self.effectView.effect = nil
            self.animator?.stopAnimation(true)

            self.animator = UIViewPropertyAnimator(duration: 0.0,
                                                   curve: .linear,
                                                   animations: { [weak self] in
                self?.effectView.effect = self?.effect
            })
            self.animator?.pausesOnCompletion = true
            self.animator?.fractionComplete = self.intensity
        }
    }
}
