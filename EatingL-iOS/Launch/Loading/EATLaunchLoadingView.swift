//
//  EATLaunchLoadingView.swift
//  PhotoI-iOS
//
//  Created by star on 2025/2/24.
//

import Lottie
import UIKit

class EATLaunchLoadingView: EATBaseView {

    public var eat_loadingFinishBlock: () -> Void = {}

    private var eat_isLoadingFinish: Bool = false

    private lazy var videoView: EATVideoView = {
        let videoView = EATVideoView(urls: [URL(fileURLWithPath: Bundle.main.path(forResource: "eat_launch", ofType: "mp4") ?? "")])
        videoView.isLoop = false
        videoView.eat_playCompletion = {
            self.eat_startInnerLoading()
        }
        return videoView
    }()

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = UIColor("#FFFFFF")
        nameLabel.font = EATFont.eat_VogueAvantGardeDemi(22)
        nameLabel.textAlignment = .center
        nameLabel.text = EATDevice.eat_appName
        nameLabel.alpha = 0.0
        return nameLabel
    }()

    private lazy var loadingView: UIImageView = {
        let loadingView = UIImageView()
        loadingView.contentMode = .scaleAspectFit
        loadingView.image = UIImage(named: "launch_loading")
        loadingView.alpha = 0.0
        return loadingView
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.eat_initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func eat_initViews() {

        layer.masksToBounds = true

        addSubview(videoView)
        addSubview(nameLabel)
        addSubview(loadingView)

        var width = SCREEN_WIDTH
        var height = width*852/393
        if height < SCREEN_HEIGHT {
           height = SCREEN_HEIGHT
            width = height*393/852
        }

        videoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(videoView).offset(397*height/852)
            make.centerX.equalToSuperview()
        }
        loadingView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-135-EATDevice.eat_XBottomSpace)
            make.centerX.equalToSuperview()
            make.size.equalTo(32)
        }
    }

    private func eat_startInnerLoading() {

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi*2
        animation.duration = 1
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        loadingView.layer.add(animation, forKey: "launch_loading_animation")

        UIView.animate(withDuration: 2.5) { [weak self] in
            self?.loadingView.alpha = 1.0
        } completion: { [weak self] _ in
            self?.loadingView.alpha = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
            self.eat_isLoadingFinish = true
            self.eat_loadingFinishBlock()
        }
    }

    private func eat_stopInnerLoading() {
        loadingView.layer.removeAllAnimations()
    }

    private func eat_startNameAnimation() {
        UIView.animate(withDuration: 0.7) { [weak self] in
            self?.nameLabel.alpha = 1.0
        } completion: { [weak self] _ in
            self?.nameLabel.alpha = 1.0
        }
    }

    public func eat_startLoading() {
        videoView.eat_startPlay()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.3) {
            self.eat_startNameAnimation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            self.eat_startInnerLoading()
        }
    }

    public func eat_stopLoading() {
        videoView.eat_stopPlay()
    }
}
