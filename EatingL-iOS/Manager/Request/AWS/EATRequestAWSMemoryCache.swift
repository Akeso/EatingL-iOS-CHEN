//
//  EATRequestAWSMemoryCache.swift
//  SwiftFuck
//
//  Created by Micheal on 2025/12/22.
//

import UIKit

class EATRequestAWSMemoryCache: NSObject {

    static let shared: EATRequestAWSMemoryCache = EATRequestAWSMemoryCache()

    private var cache: NSCache<AnyObject, AnyObject> = NSCache<AnyObject, AnyObject>()

    func save(value: AnyObject, key: AnyObject) {
        cache.setObject(value, forKey: key)
    }

    func object(key: AnyObject) -> AnyObject? {
        return cache.object(forKey: key)
    }

    func save(image: UIImage, key: String) {
        if self.image(key: key) == nil {
            self.save(value: image.eat_toJpegData(compressionQuality: 1.0)! as AnyObject, key: key as AnyObject)
        }
    }

    func image(key: String) -> UIImage? {
        let data: Data? = self.object(key: key as AnyObject) as? Data
        guard let d = data else { return nil }
        return UIImage(data: d)
    }
}
