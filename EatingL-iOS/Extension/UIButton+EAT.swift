//
//  UIButton+EAT.swift
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/22.
//

import UIKit

@objc extension UIButton {
    
    /// 设置文字和字间距（正常状态）
    /// - Parameters:
    ///   - text: 文字内容
    ///   - kern: 字间距
    @objc func eat_setTitle(_ text: String?, kern: CGFloat) {
        eat_setTitle(text, kern: kern, for: .normal)
    }
    
    /// 设置文字和字间距（指定状态）
    /// - Parameters:
    ///   - text: 文字内容
    ///   - kern: 字间距
    ///   - state: 按钮状态
    @objc func eat_setTitle(_ text: String?, kern: CGFloat, for state: UIControl.State) {
        guard let text = text, !text.isEmpty else {
            self.setTitle(text, for: state)
            return
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            .kern,
            value: kern,
            range: NSRange(location: 0, length: text.count)
        )
        
        // 使用控件本身的字体和颜色
        if let titleLabel = self.titleLabel, let font = titleLabel.font {
            attributedString.addAttribute(
                .font,
                value: font,
                range: NSRange(location: 0, length: text.count)
            )
        }
        
        if let color = self.titleColor(for: state) {
            attributedString.addAttribute(
                .foregroundColor,
                value: color,
                range: NSRange(location: 0, length: text.count)
            )
        }
        
        self.setAttributedTitle(attributedString, for: state)
    }
}
