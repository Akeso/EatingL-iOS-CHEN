//
//  Color+EAT.swift
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/22.
//

import SwiftUI

extension Color {
    
    /// 字符串初始化
    ///  例: Color(hex: "#4DA2D9")
    ///  或  Color(hex: "#4DA2D9CC")
    ///  或  Color(hex: "#4DA2D9", alpha: 0.8)
    /// - Parameters:
    ///   - hex: 16进制字符串
    ///   - alpha: 透明度 (0.0 - 1.0)，默认1.0
    init(hex: String, alpha: Double = 1.0) {
        var red: Double = 0
        var green: Double = 0
        var blue: Double = 0
        var mAlpha: Double = alpha
        var minusLength = 0
        
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(hex.startIndex, offsetBy: 1)
            minusLength = 1
        }
        if hex.hasPrefix("0x") {
            scanner.currentIndex = hex.index(hex.startIndex, offsetBy: 2)
            minusLength = 2
        }
        
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        
        switch hex.count - minusLength {
        case 3:
            red = Double((hexValue & 0xF00) >> 8) / 15.0
            green = Double((hexValue & 0x0F0) >> 4) / 15.0
            blue = Double(hexValue & 0x00F) / 15.0
        case 4:
            red = Double((hexValue & 0xF000) >> 12) / 15.0
            green = Double((hexValue & 0x0F00) >> 8) / 15.0
            blue = Double((hexValue & 0x00F0) >> 4) / 15.0
            mAlpha = Double(hexValue & 0x00F) / 15.0
        case 6:
            red = Double((hexValue & 0xFF0000) >> 16) / 255.0
            green = Double((hexValue & 0x00FF00) >> 8) / 255.0
            blue = Double(hexValue & 0x0000FF) / 255.0
        case 8:
            red = Double((hexValue & 0xFF000000) >> 24) / 255.0
            green = Double((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = Double((hexValue & 0x0000FF00) >> 8) / 255.0
            mAlpha = Double(hexValue & 0x000000FF) / 255.0
        default:
            break
        }
        
        self.init(.displayP3, red: red, green: green, blue: blue, opacity: mAlpha)
    }
}
