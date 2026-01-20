//
//  PLPAPIExtension.swift
//  PhotoK-iOS
//
//  Created by star on 2024/3/15.
//

import CryptoKit
import UIKit

extension Data {

    public func eat_apiString() -> String? {
        return String(data: self, encoding: .utf8)
    }

    public func eat_apiBytes() -> [UInt8] {
        return self.map { return $0 }
    }

    public func eat_apiDictionary() -> [String: Any]? {
        if let dict = try? JSONSerialization.jsonObject(with: self) as? [String: Any] {
            return dict
        }
        return nil
    }

    public func eat_apiMd5String() -> String {
        let digestData = Insecure.MD5.hash(data: self)
        return String(digestData.map { String(format: "%02hhx", $0) }.joined().prefix(32))
    }

    public func eat_apiMd5Data() -> Data {
        let digestData = Insecure.MD5.hash(data: self)
        let digest = digestData.map { return $0 }.prefix(32)
        return Data(digest)
    }

    public func eat_apiJsonObject() -> Any? {
        do {
            let object = try JSONSerialization.jsonObject(with: self, options: [.mutableContainers])
            return object
        } catch {
            print("Data to jsonObject error: \(error)")
            return nil
        }
    }
}
