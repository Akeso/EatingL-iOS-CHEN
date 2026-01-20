//
//  UIScrollView+EAT.swift
//  PhotoK-iOS
//
//  Created by 怦然心动-LM on 2023/3/21.
//

import Foundation
import UIKit

// MARK: Scroll

extension UIScrollView {

    func eat_scrollToTop(animated: Bool = true) {
        var offset = contentOffset
        offset.y = 0 - contentInset.top
        if offset.y > 0 { return }
        setContentOffset(offset, animated: animated)
    }
}
