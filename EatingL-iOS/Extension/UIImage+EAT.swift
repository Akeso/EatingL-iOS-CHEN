//
//  UIImage+HTR.swift
//  FancyTranslate
//
//  Created by 高文立 on 2020/8/12.
//  Copyright © 2020 mouos. All rights reserved.
//

import SDWebImage
import UIKit

extension UIImage {

    func eat_toJpegData(compressionQuality: CGFloat) -> Data? {
        autoreleasepool {
            if let cgImage = self.cgImage,
               cgImage.alphaInfo == .none || cgImage.alphaInfo == .noneSkipLast,
               let data = jpegData(compressionQuality: compressionQuality) {
                return data
            }

            let format = UIGraphicsImageRendererFormat.default()
            format.scale = scale
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            let data = renderer.jpegData(withCompressionQuality: compressionQuality) { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
            return data
        }
    }

    /// 更改图片颜色
    func eat_toColor(_ color: UIColor) -> UIImage {
        guard let image = self.sd_tintedImage(with: color) else { return self }
        return image
    }

    /// 图片裁剪
    func eat_cropped(_ rect: CGRect) -> UIImage {
        guard let image = self.sd_croppedImage(with: rect) else { return self }
        return image
    }

    /// 改变图片大小
    func eat_resized(_ size: CGSize, scaleMode: SDImageScaleMode = .aspectFill) -> UIImage {
        guard let image = self.sd_resizedImage(with: size, scaleMode: scaleMode) else { return self }
        return image
    }

    /// 更改图片的透明度
    func eat_toAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return newImage
    }

    /// 压缩图片
    func eat_compress(as format: SDImageFormat, quality: Double = 1.0) -> Data {
        guard let image = self.sd_imageData(as: format, compressionQuality: quality) else { return self.pngData()! }
        return image
    }

    /// 高斯模糊
    func eat_blurred(raidus: CGFloat) -> UIImage {
        guard let image = self.sd_blurredImage(withRadius: raidus) else { return self }
        return image
    }

    /// 翻转
    func eat_flipped(withHorizontal: Bool, vertical: Bool) -> UIImage {
        guard let image = self.sd_flippedImage(withHorizontal: withHorizontal, vertical: vertical) else { return self }
        return image
    }

    /// 旋转
    func eat_rotated(angle: CGFloat, fitSize: Bool) -> UIImage {
        guard let image = self.sd_rotatedImage(withAngle: angle, fitSize: fitSize) else { return self }
        return image
    }

    /// 图片圆角
    func eat_roundedCorner(radius: CGFloat, corners: SDRectCorner, borderWidth: CGFloat = 0, borderColor: UIColor? = nil) -> UIImage {
        guard let image = self.sd_roundedCornerImage(withRadius: radius, corners: corners, borderWidth: borderWidth, borderColor: borderColor) else { return self }
        return image
    }

    var eat_fixed: UIImage {
        let orientation = self.imageOrientation

        if orientation == .up {
            return self
        }

        var transform = CGAffineTransform.identity

        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        default:
            break
        }

        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        guard let cgimage = self.cgImage else { return self }
        guard let colorSpace = self.cgImage?.colorSpace else { return self }
        guard let bitmapInfo = self.cgImage?.bitmapInfo else { return self }
        guard let bitsPerComponent = self.cgImage?.bitsPerComponent else { return self }
        let ctx = CGContext(data: nil,
                            width: Int(self.size.width),
                            height: Int(self.size.height),
                            bitsPerComponent: bitsPerComponent,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo.rawValue)

        ctx?.concatenate(transform)

        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgimage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx?.draw(cgimage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }

        guard let cgimageRef = ctx?.makeImage() else { return self }
        let result = UIImage(cgImage: cgimageRef)
        return result
    }
    
    typealias BlendSetting = (blendMode: CGBlendMode, blendAlpha: CGFloat)

    /// 图片混合(multi blendMode)
    ///
    /// 由于比较占用内存和 cpu, 建议在子线程调用。
    ///
    /// - Parameters:
    ///   - scale: Default is `UIScreen.main.scale`.
    func eat_blendImageWithSettings(_ image: UIImage, settings: [BlendSetting], scale: CGFloat = 0) -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false

        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { _ in
            // 底图（自身）
            self.draw(in: rect, blendMode: .normal, alpha: 1)

            // 叠加图层
            for setting in settings {
                image.draw(in: rect, blendMode: setting.blendMode, alpha: setting.blendAlpha)
            }
        }
    }

}

extension UIImage {

    /// 判断比例是否在21:9或9:21范围内
    func eat_isAspectRatioIn21_9_or_9_21() -> Bool {
        let aspectRatio = self.size.width / self.size.height
        return aspectRatio >= 9.0/21.0 && aspectRatio <= 21.0/9.0
    }
    
    static func eat_from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
