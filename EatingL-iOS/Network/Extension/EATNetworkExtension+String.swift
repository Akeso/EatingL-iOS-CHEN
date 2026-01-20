//
//  PLPAPIExtension.swift
//  PhotoK-iOS
//
//  Created by star on 2024/3/15.
//

import CryptoKit
import UIKit

extension String {

    public func eat_apiData() -> Data? {
        return self.data(using: String.Encoding.utf8)
    }

    public func eat_apiBytes() -> [UInt8] {
        return Array(self.utf8)
    }
    
    public func eat_apiMd5() -> String {
        let messageData = self.data(using: .utf8)!
        let digestData = Insecure.MD5.hash(data: messageData)
        return String(digestData.map { String(format: "%02hhx", $0) }.joined().prefix(32))
    }

    public func eat_apiJsonObject() -> Any? {
        return eat_apiData()?.eat_apiJsonObject()
    }

    public func eat_apiHexData() -> Data {
        let bytes: [UInt8] = stride(from: 0, to: count, by: 2).compactMap { i -> UInt8? in
            let start = index(startIndex, offsetBy: i)
            let end = index(start, offsetBy: 2)
            return UInt8(self[start..<end], radix: 16)
        }
        return Data(bytes)
    }
}
