//
//  String+HTR.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import UIKit

// MARK: - String
extension String {

    /// 绑定宽度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - att: 属性
    /// - Returns: 高度值
    func eat_boundingWidth(width: CGFloat,
                           att: [NSAttributedString.Key: Any]?) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                 options: [.usesFontLeading, .usesLineFragmentOrigin],
                                 attributes: att,
                                 context: nil).size.height
    }

    /// 绑定高度
    ///
    /// - Parameters:
    ///   - height: 高度值
    ///   - att: 属性
    /// - Returns: 宽度值
    func eat_boundingHeight(height: CGFloat,
                            att: [NSAttributedString.Key: Any]?) -> CGFloat {
        return self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height),
                                 options: [.usesFontLeading, .usesLineFragmentOrigin],
                                 attributes: att,
                                 context: nil).size.width
    }

    /// 本地语言
    func eat_Localized() -> String {
        let lang: String = NSLocalizedString(self, comment: "")
        if lang == self {
            let bundle: Bundle? = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj") ?? "")
            if bundle != nil {
                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: "", comment: "")
            }
        }
        return lang
    }
}

extension String {

    func eat_highlightString(_ highlight: String,
                             originAttributes: [NSAttributedString.Key: Any],
                             highlightAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let range = NSString(string: self).range(of: highlight)
        let attrString = NSMutableAttributedString(string: self, attributes: originAttributes)
        attrString.addAttributes(highlightAttributes, range: range)
        return attrString
    }
    
    /// 是否为纯空格或者换行
    var eat_isWhitespaceOrNewLines: Bool {
        // A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        // Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        let trimmingString = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmingString.isEmpty
    }
}

// MARK: - NSAttributedString
extension NSAttributedString {

    /// 绑定宽度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - att: 属性
    /// - Returns: 高度值
    func eat_boundingWidth(width: CGFloat) -> CGFloat {
        return boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                            options: [.usesLineFragmentOrigin],
                            context: nil).size.height
    }

    /// 绑定高度
    ///
    /// - Parameters:
    ///   - height: 高度值
    ///   - att: 属性
    /// - Returns: 宽度值
    func eat_boundingHeight(height: CGFloat) -> CGFloat {
        return boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height),
                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                            context: nil).size.width
    }
}

extension String {

    func eat_boundWithWithLineHeightMultiple(width: CGFloat,
                                             multiple: CGFloat = 1.13,
                                             font: UIFont) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = multiple

        // 限制行高
        paragraphStyle.maximumLineHeight = font.lineHeight*multiple
        paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight

        // 计算偏移
        let baselineOffset = -font.lineHeight*(1-multiple)/2.0

        return self.eat_boundingWidth(width: width,
                                      att: [.font: font,
                                            .paragraphStyle: paragraphStyle,
                                            .baselineOffset: baselineOffset])
    }
}
