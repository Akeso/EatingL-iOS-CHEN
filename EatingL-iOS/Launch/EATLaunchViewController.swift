//
//  EATLaunchViewController.swift
//  PhotoK-iOS
//
//  Created by star on 2025/12/29.
//

import UIKit

class EATLaunchViewController: EATBaseViewController {
    
    private var launchFinish: Bool = false
    
    private lazy var loadingView: EATLaunchLoadingView = {
        let loadingView = EATLaunchLoadingView()
        loadingView.eat_loadingFinishBlock = { [weak self] in
            if self?.launchFinish == false {
                self?.launchFinish = true
                self?.eat_finishLaunch()
            }
        }
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingView)
        
        loadingView.eat_startLoading()
    }
    
    @objc func eat_finishLaunch() {
        
        if !self.launchFinish {
            return
        }
        
        EATSceneDelegate.eat_shared?.eat_reloadMainController()
    }
}
