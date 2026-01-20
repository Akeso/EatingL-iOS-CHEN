//
//  EATLabel.swift
//  PhotoK-iOS
//
//  Created by star on 2024/7/22.
//

import UIKit

class EATLabel: UILabel {

    override var text: String? {
        didSet {
            super.text = text
            eat_refreshContent()
        }
    }

    override var textColor: UIColor! {
        didSet {
            super.textColor = textColor
            eat_refreshContent()
        }
    }

    override var font: UIFont! {
        didSet {
            super.font = font
            eat_refreshContent()
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            super.textAlignment = textAlignment
            eat_refreshContent()
        }
    }

    override var lineBreakMode: NSLineBreakMode {
        didSet {
            super.lineBreakMode = lineBreakMode
            eat_refreshContent()
        }
    }

    /// 建议最后设置
    var lineHeightMultiple: CGFloat = 1.0 {
        didSet {
            eat_refreshContent()
        }
    }

    /// 建议最后设置
    var kern: CGFloat = 0.0 {
        didSet {
            eat_refreshContent()
        }
    }

    func eat_refreshContent() {
        guard (lineHeightMultiple != 1.0 && lineHeightMultiple != 0.0) || (kern != 0.0) else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = textAlignment

        // 限制行高
        paragraphStyle.maximumLineHeight = font.lineHeight*lineHeightMultiple
        paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight

        paragraphStyle.lineBreakMode = lineBreakMode

        // 计算偏移
        let baselineOffset = -font.lineHeight*(1-lineHeightMultiple)/2.0

        attributedText = NSMutableAttributedString(string: text ?? "",
                                                   attributes: [.paragraphStyle: paragraphStyle,
                                                                .baselineOffset: baselineOffset,
                                                                .kern: kern,
                                                                .font: font as Any,
                                                                .foregroundColor: textColor as Any])
    }
}
