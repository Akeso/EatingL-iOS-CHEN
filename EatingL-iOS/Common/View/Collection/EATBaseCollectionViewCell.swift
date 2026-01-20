//
//  EATBaseCollectionViewCell.swift
//  PhotoK-iOS
//
//  Created by star on 2025/5/27.
//

import RxSwift
import UIKit

class EATBaseCollectionViewCell: UICollectionViewCell {

    var disposeBag = DisposeBag()

    deinit {
        debugPrint("\(Swift.type(of: self)):\(#line) is dealloc!!!")
    }
}
