//
//  EATRequestBaseManager.swift
//  PhotoK-iOS
//
//  Created by Winn on 2024/9/12.
//

import RxSwift
import SDWebImage
import UIKit

class EATRequestBaseManager {
    func eat_cancelTask() {
        SDWebImageDownloader.shared.cancelAllDownloads()
        EATRequestAWSUploadManager.shared.eat_cancelAllTasks()
        EATNetworkBase.shared.eat_cancelAllTasks()
    }
}

// MARK: - 上传图片
extension EATRequestBaseManager {

    func eat_uploadImage(_ image: UIImage,
                         imageType: EATRequestAWSImageType = .jpg,
                         needResize: Bool = false) -> Observable<String> {
        return EATRequestAWSUploadManager.shared.eat_uploadImage(image: image,
                                                             imageType: imageType,
                                                             needResize: needResize).catch { _ in
            return Observable.error(EATRequestError.image(.upload))
        }
    }

    func eat_uploadImages(_ images: [(UIImage, EATRequestAWSImageType)],
                          needResize: Bool = false) -> Observable<[String]> {
        return EATRequestAWSUploadManager.shared.eat_uploadImages(images: images,
                                                              needResize: needResize).catch { _ in
            return Observable.error(EATRequestError.image(.upload))
        }
    }
}

// MARK: - 下载图片
extension EATRequestBaseManager {

    func eat_downloadImages(_ urls: [String]) -> Observable<[UIImage]> {

        let downloadImageBlock: ((String) -> (Observable<UIImage?>)) = { url in
            return Observable<UIImage?>.create { observer in
                SDWebImageDownloader.shared.config.downloadTimeout = 20
                // 只下载, (不压缩、不缓存、不解码)减少一些额外操作, 提升速度
                SDWebImageDownloader.shared.downloadImage(with: URL(string: url),
                                                          options: [.highPriority, .useNSURLCache, .decodeFirstFrameOnly, .continueInBackground],
                                                          progress: nil) { image, _, _, _ in
                    observer.onNext(image)
                    observer.onCompleted()

                }
                return Disposables.create()
            }
        }

        return Observable.zip(urls.map { downloadImageBlock($0) }).flatMapLatest { images -> Observable<[UIImage]> in
            let images = images.compactMap {$0}
            guard !images.isEmpty else {
                return Observable.error(EATRequestError.image(.download))
            }

            return Observable.just(images)
        }
    }

    func eat_downloadImage(_ url: String) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            SDWebImageDownloader.shared.config.downloadTimeout = 20
            // 只下载, (不压缩、不缓存、不解码)减少一些额外操作, 提升速度
            SDWebImageDownloader.shared.downloadImage(with: URL(string: url),
                                                      options: [.highPriority, .useNSURLCache, .decodeFirstFrameOnly, .continueInBackground],
                                                      progress: nil) { image, _, _, _ in
                guard let image = image else {
                    observer.onError(EATRequestError.image(.download))
                    return
                }

                observer.onNext(image)
                observer.onCompleted()

            }
            return Disposables.create()
        }
    }
}
