//
//  EATRequestAWSUploadManager.swift
//  PhotoK-iOS
//
//  Created by star on 2025/10/29.
//

import RxSwift

enum EATRequestAWSImageType: Int {
    case jpg
    case png

    var contentType: String {
        switch self {
        case .jpg: return "image/jpeg"
        case .png: return "image/png"
        }
    }
}

class EATRequestAWSUploadManager: NSObject {

    static let shared = EATRequestAWSUploadManager()
    private override init() {}

    private var tasks: [URLSessionUploadTask] = []

    /// 上传单张
    func eat_uploadImage(image: UIImage,
                         imageType: EATRequestAWSImageType = .jpg,
                         needResize: Bool = false) -> Observable<String> {
        debugPrint("====== \(self) 开始上传 ======")

        let image = image.eat_processImage(needResize: needResize)
        let imageKey = image.eat_toJpegData(compressionQuality: 0.1)?.eat_path()
        if let imageKey = imageKey,
           let cacheValue = EATRequestAWSMemoryCache.shared.object(key: imageKey as AnyObject) as? String {
            debugPrint("====== \(self) photo已经上传过, key是:\(cacheValue) ======")
            return Observable.just(cacheValue)
        }

        return EATAPIManager.shared.eat_awsUpload().flatMapLatest { response -> Observable<String> in
            guard let data = response["data"] as? [String: Any],
                  let uploadUrl = data["upload_url"] as? String,
                  let imageUrl = data["file_name"] as? String else {
                return Observable.error(EATRequestError.response(.response))
            }

            return self.eat_uploadImage(image: image,
                                        imageType: imageType,
                                        imageUrl: imageUrl,
                                        imageKey: imageKey,
                                        uploadUrl: uploadUrl)
        }
    }

    /// 上传多张
    func eat_uploadImages(images: [(UIImage, EATRequestAWSImageType)],
                          needResize: Bool = true) -> Observable<[String]> {
        let sequence = images.compactMap { image in
            return self.eat_uploadImage(image: image.0.eat_processImage(needResize: needResize),
                                        imageType: image.1)
        }
        return Observable.zip(sequence)
    }

    func eat_cancelAllTasks() {
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }

    private func eat_uploadImage(image: UIImage,
                                 imageType: EATRequestAWSImageType,
                                 imageUrl: String,
                                 imageKey: String?,
                                 uploadUrl: String) -> Observable<String> {
        return Observable.create { observer in

            guard let url = URL(string: uploadUrl) else {
                observer.onError(EATRequestError.image(.upload))
                return Disposables.create {}
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue(imageType.contentType, forHTTPHeaderField: "Content-Type")

            let data = image.eat_compressed(type: imageType)

            let task = URLSession.shared.uploadTask(with: request, from: data) { _, response, error in
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                        observer.onError(EATRequestError.response(.cancelled))
                    } else {
                        observer.onError(EATRequestError.image(.upload))
                    }
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    if let imageKey = imageKey {
                        EATRequestAWSMemoryCache.shared.save(value: imageUrl as AnyObject,
                                                         key: imageKey as AnyObject)
                    }
                    debugPrint("====== AWS上传成功 key是: \(imageUrl)")
                    observer.onNext(imageUrl)
                    observer.onCompleted()
                } else {
                    observer.onError(EATRequestError.image(.upload))
                }
            }

            self.tasks.append(task)
            task.resume()

            return Disposables.create {
                self.tasks.removeAll { $0 == task }
            }
        }
    }
}
