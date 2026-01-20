//
//  CALayer+EAT.swift
//  PhotoK-iOS
//
//  Created by 怦然心动-LM on 2022/11/10.
//

import Foundation

extension CALayer {
    public func setShadowWithoutRasterization(shadowColor: UIColor, shadowOpacity: Float = 1, shadowOffset: CGSize = CGSize(width: 0, height: 1), blur: CGFloat = 2) {
        self.masksToBounds = false
        self.shadowColor = shadowColor.cgColor
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.shadowRadius = blur / 2
    }
}
