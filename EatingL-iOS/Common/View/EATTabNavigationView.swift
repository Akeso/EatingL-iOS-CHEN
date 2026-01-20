//
//  SKPTabNavigationView.swift
//  PhotoK-iOS
//
//  Created by tongshuai on 12/19/25.
//

import UIKit

extension EATMainTab {
    var navTitle: String {
        switch self {
        case .editor: "EATEditor".eat_Localized()
        case .styles: "EATStyles".eat_Localized()
        case .me: "EATMe".eat_Localized()
        }
    }
}

class EATTabNavigationView: EATBaseView {
    
    var eat_settingBlock: (() -> Void)?
    var eat_isEditChnageBlock: ((Bool) -> Void)?
    
    
    var tab: EATMainTab
    
    var isEditing: Bool = false {
        didSet {
            if tab == .me {
                editLabel.isHidden = !isEditing
                editButton.isHidden = isEditing
                editDoneBtn.isHidden = !isEditing
                titleLabel.isHidden = isEditing
                settingButton.isHidden = isEditing
                eat_isEditChnageBlock?(isEditing)
            }
        }
    }

    lazy var titleLabel: EATLabel = {
        let titleLabel = EATLabel()
        titleLabel.font = EATFont.eat_CinzelBold(28)
        titleLabel.textColor = UIColor("#FFFFFF")
        titleLabel.text = tab.navTitle.uppercased()
        return titleLabel
    }()
    
    lazy var editLabel: EATLabel = {
        let label = EATLabel()
        label.font = EATFont.eat_VogueAvantGardeDemi(22)
        label.textColor = UIColor("#FFFFFF")
        label.text = "EATEdit".eat_Localized()
        label.kern = 0.66
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_settings")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(eat_settingAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(eat_editAction), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 18,
            bottom: 0,
            trailing: 18
        )
        config.background.backgroundColor = UIColor("#FFFFFF0A")
        config.background.cornerRadius = 17
        config.title = "EATEdit".eat_Localized()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = EATFont.eat_VogueAvantGardeDemi(14)
            attr.foregroundColor = UIColor("#FFFFFF")
            return attr
        }
        button.configuration = config
        button.isHidden = true
        return button
    }()
    
    private lazy var editDoneBtn : UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(eat_editDoneAction), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 18,
            bottom: 0,
            trailing: 18
        )
        config.background.backgroundColor = UIColor("#FFFFFF0A")
        config.background.cornerRadius = 17
        config.title = "EATDone".eat_Localized()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = EATFont.eat_VogueAvantGardeDemi(14)
            attr.foregroundColor = UIColor("#FFFFFF")
            return attr
        }
        button.configuration = config
        
        button.isHidden = true
        return button
    }()
    
    convenience init(tab: EATMainTab) {
        self.init(tab: tab, frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EATDevice.eat_statusBarHeight + 62))
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        editButton.eat_addGradientBorder(colors: [UIColor("#FFFFFF1F"), UIColor("#FFFFFF0D")], locations: [0,1], startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1), width: 1, cornerRadius: 17)
        editDoneBtn.eat_addGradientBorder(colors: [UIColor("#FFFFFF1F"), UIColor("#FFFFFF0D")], locations: [0,1], startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1), width: 1, cornerRadius: 17)
    }

    public init(tab: EATMainTab, frame: CGRect) {
        self.tab = tab
        super.init(frame: frame)
        eat_initViews()
    }
    
    func eat_initViews(){
        addSubview(titleLabel)
        addSubview(settingButton)
        addSubview(editButton)
        addSubview(editLabel)
        addSubview(editDoneBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
        settingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.bottom.equalToSuperview().inset(3)
        }
        editButton.snp.makeConstraints { make in
            make.trailing.equalTo(settingButton.snp.leading).offset(-12)
            make.height.equalTo(34)
            make.centerY.equalTo(settingButton)
        }
        editLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
        editDoneBtn.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(-20)
        }
        
        editButton.isHidden = tab != .me
        settingButton.isHidden = tab != .me
    }
    
    @objc func eat_settingAction() {
        eat_settingBlock?()
    }

    @objc func eat_editAction() {
        if tab == .me {
            isEditing = !isEditing
        }
    }
    
    @objc func eat_editDoneAction() {
        isEditing = false
    }
    
}
