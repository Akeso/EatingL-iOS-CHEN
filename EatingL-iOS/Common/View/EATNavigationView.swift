//
//  SKPTabNavigationView.swift
//  PhotoK-iOS
//
//  Created by tongshuai on 12/19/25.
//

import UIKit

typealias VoidHandler = () -> Void

let eat_navigation_height = EATDevice.eat_statusBarHeight + 68

enum EATNavigationType {
    case back
    case close
    case downwards

    var icon: String {
        switch self {
        case .back: "nav_back"
        case .close: "nav_close"
        case .downwards: "nav_downwards"
        }
    }
}

class EATNavigationView: EATBaseView {
    public var eat_leftBlock: () -> Void = {}
    public var eat_rightBlock: () -> Void = {}

    public var type: EATNavigationType {
        didSet {
            leftButton.setBackgroundImage(UIImage(named: type.icon), for: .normal)
        }
    }

    public var leftIcon: UIImage? {
        didSet {
            leftButton.setBackgroundImage(leftIcon, for: .normal)
        }
    }

    public var rightIcon: UIImage? {
        didSet {
            rightButton.setBackgroundImage(rightIcon, for: .normal)
        }
    }

    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    private lazy var leftButton: UIButton = {
        let leftButton = UIButton(type: .custom)
        leftButton.setBackgroundImage(UIImage(named: type.icon), for: .normal)
        leftButton.addTarget(self, action: #selector(ptj_actionLeft), for: .touchUpInside)
        return leftButton
    }()

    private lazy var rightButton: UIButton = {
        let leftButton = UIButton(type: .custom)
        leftButton.addTarget(self, action: #selector(ptj_actionRight), for: .touchUpInside)
        return leftButton
    }()

    lazy var titleLabel: EATLabel = {
        let titleLabel = EATLabel()
        titleLabel.textColor = UIColor("#FFFFFF")
        titleLabel.font = EATFont.eat_VogueAvantGardeDemi(22)
        titleLabel.textAlignment = .center
        titleLabel.kern = 0.66
        return titleLabel
    }()
    
    public var blurView : EATGaussianBlurView = {
        let view = EATGaussianBlurView(effectStyle: .systemChromeMaterial)
        return view
    }()

    init(type: EATNavigationType) {
        self.type = type
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: eat_navigation_height))
        ptj_initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func ptj_initViews() {
        layer.masksToBounds = false
        addSubview(blurView)
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(rightButton)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(44)
        }
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(44)
        }
    }

    @objc func ptj_actionLeft() {
        eat_leftBlock()
    }

    @objc func ptj_actionRight() {
        eat_rightBlock()
    }
}
