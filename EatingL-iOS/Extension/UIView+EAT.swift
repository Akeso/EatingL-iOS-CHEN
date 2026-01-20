//
//  UIView+EAT.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import UIKit
import CoreImage

extension UIView {
    /// 标识
    static var eat_identify: String {
        return NSStringFromClass(self.classForCoder())
    }

    // MARK: - Controller
    var eat_viewController: UIViewController? {
        var next = self.next
        while next != nil {
            if let vc = next as? UIViewController {
                return vc
            }
            next = next?.next
        }
        return nil
    }

    /// 转成图片
    var eat_toImage: UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }

    /// 点击
    func eat_addTap(target: Any?, _ action: Selector?) {
        isUserInteractionEnabled = true
        let t: UITapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(t)
    }

    func eat_screenShot(rect: CGRect) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 0
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)

        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.saveGState()
            cgContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)

            if self.responds(to: #selector(UIView.drawHierarchy(in:afterScreenUpdates:))) {
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
            } else {
                self.layer.render(in: cgContext)
            }

            cgContext.restoreGState()
        }
    }

}

extension UIView {
    func removeAllSubview() {
        while self.subviews.count > 0 {
            self.subviews.last?.removeFromSuperview()
        }
    }

    func removeAllSublayers() {
        while (self.layer.sublayers?.count ?? 0) > 0 {
            self.layer.sublayers?.last?.removeFromSuperlayer()
        }
    }
}

extension UIView {

    /// 渐变边框
    @objc func eat_addGradientBorder(colors: [UIColor],
                           locations: [NSNumber],
                           startPoint: CGPoint,
                           endPoint: CGPoint,
                           width: CGFloat,
                           cornerRadius: CGFloat) {
        guard colors.count == locations.count else {
            fatalError("Number of colors must be equal to number of locations.")
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = width

        let origin = bounds.origin
        let size = bounds.size

        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: origin.x + width/2,
                                                          y: origin.y + width/2,
                                                          width: size.width - width,
                                                          height: size.height - width),
                                      cornerRadius: cornerRadius - width/2).cgPath

        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.shouldRasterize = true
        maskLayer.rasterizationScale = UIScreen.main.scale

        gradientLayer.mask = maskLayer
        gradientLayer.name = "eat_gradientBorder_name"

        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        self.layer.sublayers?.removeAll { $0.name == "eat_gradientBorder_name" }
        self.layer.addSublayer(gradientLayer)
    }

}

extension UIView {
    func eat_setupGradientBackground(colors: [Any] = [UIColor("#0000000A").cgColor, UIColor("#00000005").cgColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 1, y: 0), endPoint: CGPoint = CGPoint(x: 0, y: 1)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            eat_removeGradientBackground()

            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.locations = locations
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.frame = self.bounds
            gradientLayer.name = "eat_gradientLayer_name"
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    func eat_removeGradientBackground() {
        layer.sublayers?.removeAll { layer in
            layer.name == "eat_gradientLayer_name"
        }
    }
}
