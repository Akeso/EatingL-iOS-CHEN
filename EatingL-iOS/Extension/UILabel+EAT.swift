//
//  UILabel+EAT.swift
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/22.
//

import UIKit

@objc extension UILabel {
    
    /// 设置文字和字间距
    /// - Parameters:
    ///   - text: 文字内容
    ///   - kern: 字间距
    @objc func eat_setText(_ text: String?, kern: CGFloat) {
        guard let text = text, !text.isEmpty else {
            self.text = text
            return
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .kern,
            value: kern,
            range: NSRange(location: 0, length: text.count)
        )
        
        // 使用控件本身的字体和颜色
        if let font = self.font {
            attributedString.addAttribute(
                .font,
                value: font,
                range: NSRange(location: 0, length: text.count)
            )
        }
        
        if let color = self.textColor {
            attributedString.addAttribute(
                .foregroundColor,
                value: color,
                range: NSRange(location: 0, length: text.count)
            )
        }
        
        self.attributedText = attributedString
    }
}
