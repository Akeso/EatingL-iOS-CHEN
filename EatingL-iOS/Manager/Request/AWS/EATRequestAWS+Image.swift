//
//  EATRequestAWS+Image.swift
//  PhotoK-iOS
//
//  Created by weikunchao on 2023/8/16.
//

import SDWebImage
import UIKit

/**
 S3上传的图片限制: 2M, 1k
 这里需要受 needResize 控制，默认是 false
 */
let EATRequestAWSImageResizeLevel: Int = 2048

extension UIImage {

    /// 压缩
    /// - Parameter maxSize: 默认2M
    /// - Returns: Data
    func eat_compressed(maxSize: CGFloat = 20*100*1024, type: EATRequestAWSImageType) -> Data? {
        if type == .jpg {
            var compression: CGFloat = 1.0
            var data: Data? = self.eat_toJpegData(compressionQuality: compression)
            while data != nil, CGFloat(data!.count) > maxSize, compression > 0.1 {
                compression -= 0.1
                data = self.eat_toJpegData(compressionQuality: compression)
            }
            return data
        }

        // MARK: 换一种压缩方式(不能用scaleDown,会缩小图片像素)上传线上图片大概20~50kb.
        return self.sd_imageData(as: .PNG, compressionQuality: 1.0)
    }

    /// Resize
    /// - Parameter level: 最大像素
    /// - Returns: new image
    func eat_resizeInputImage(level: Int = EATRequestAWSImageResizeLevel) -> UIImage {
        let actualHeight = self.size.height
        let actualWidth = self.size.width
        var wantWidth: CGFloat = actualWidth
        var wantHeight: CGFloat = actualHeight
        let resizeLevel: CGFloat = CGFloat(level)/self.scale

        if actualHeight > resizeLevel {
            if actualHeight > actualWidth {
                wantHeight = resizeLevel
                wantWidth = wantHeight * actualWidth / actualHeight
            } else {
                wantWidth = resizeLevel
                wantHeight = wantWidth * actualHeight / actualWidth
            }
        } else if actualWidth > resizeLevel {
            wantWidth = resizeLevel
            wantHeight = wantWidth * actualHeight / actualWidth
        } else {
            return self
        }

        if let result = self.sd_resizedImage(with: CGSize(width: floor(wantWidth),
                                                          height: floor(wantHeight)),
                                             scaleMode: .aspectFill) {
            return result
        }

        return self
    }

    func eat_processImage(needResize: Bool) -> UIImage {
        let result = self.eat_fixed
        var resized = result
        if needResize {
            resized = result.eat_resizeInputImage()
        }
        return resized
    }
}

extension Data {

    func eat_path() -> String {
        return "\(self.eat_apiMd5String()).jpg"
    }
}
