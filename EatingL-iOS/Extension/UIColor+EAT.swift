//
//  UIColor+HTR.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import UIKit

@objc extension UIColor {

    /// 字符串初始化
    ///  例: UIColor("#4DA2D9")
    ///  或  UIColor("#4DA2D9CC")
    /// - Parameter hexString: 字符串
    convenience init(_ hexString: String, alpha: Float = 1.0) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var mAlpha: CGFloat = CGFloat(alpha)
        var minusLength = 0

        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 1)
            minusLength = 1
        }
        if hexString.hasPrefix("0x") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 2)
            minusLength = 2
        }
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        switch hexString.count - minusLength {
        case 3:
            red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexValue & 0x00F) / 15.0
        case 4:
            red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
            mAlpha = CGFloat(hexValue & 0x00F) / 15.0
        case 6:
            red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            mAlpha = CGFloat(hexValue & 0x000000FF) / 255.0
        default:
            break
        }
        self.init(displayP3Red: red, green: green, blue: blue, alpha: mAlpha)
    }
}
