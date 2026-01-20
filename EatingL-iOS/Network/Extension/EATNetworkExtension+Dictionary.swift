//
//  PLPAPIExtension.swift
//  PhotoK-iOS
//
//  Created by star on 2024/3/15.
//

import CryptoKit
import UIKit

extension Dictionary where Key == String {

    public func eat_apiData() -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }

        do {
            return try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
        } catch {
            print("\(self) convert to data error: \(error)")
            return nil
        }
    }

    public func eat_apiString() -> String? {
        if let data = eat_apiData() {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
