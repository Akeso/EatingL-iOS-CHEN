//
//  EATBaseView.swift
//  PhotoK-iOS
//
//  Created by star on 2025/7/14.
//

import RxSwift
import UIKit

class EATBaseView: UIView {

    var disposeBag = DisposeBag()

    deinit {
        debugPrint("\(Swift.type(of: self)):\(#line) is dealloc!!!")
    }
}
