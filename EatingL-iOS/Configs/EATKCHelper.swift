//
//  EATKCHelper.swift
//  PhotoK-iOS
//
//  Created by star on 2025/10/20.
//

import Foundation
import Security

enum EATKCService: String {
    case user = "eat.kc.service.user"
    case limit = "eat.kc.service.limit"
    case rate = "eat.kc.service.rate"
}

class EATKCHelper {

    static func eat_saveUserId(key: String, value: String) {
        eat_saveString(service: .user, key: key, value: value)
    }

    static func eat_getUserId(key: String) -> String? {
        return eat_getString(service: .user, key: key)
    }

    static func eat_saveRate(key: String, value: Int) {
        eat_saveInt(service: .rate, key: key, value: value)
    }

    static func eat_getRate(key: String) -> Int {
        return eat_getInt(service: .rate, key: key) ?? 0
    }

    static func eat_saveLimit(key: String, value: Int) {
        eat_saveInt(service: .limit, key: key, value: value)
    }

    static func eat_getLimit(key: String) -> Int {
        return eat_getInt(service: .limit, key: key) ?? 0
    }
}

extension EATKCHelper {

    static func eat_delete(forService service: EATKCService) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess {
            print("✅ Deleted all items for service: \(service)")
        } else if status == errSecItemNotFound {
            print("ℹ️ No items found for service: \(service)")
        } else {
            print("⚠️ Failed to delete items for service: \(service), status = \(status)")
        }
    }
}

// MARK: - 私有封装
extension EATKCHelper {

    private static func eat_saveString(service: EATKCService, key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        eat_saveData(service: service.rawValue, key: key, data: data)
    }

    private static func eat_getString(service: EATKCService, key: String) -> String? {
        guard let data = eat_getData(service: service.rawValue, key: key),
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private static func eat_saveInt(service: EATKCService, key: String, value: Int) {
        let data = Data("\(value)".utf8)
        eat_saveData(service: service.rawValue, key: key, data: data)
    }

    private static func eat_getInt(service: EATKCService, key: String) -> Int? {
        guard let data = eat_getData(service: service.rawValue, key: key),
              let string = String(data: data, encoding: .utf8),
              let value = Int(string) else {
            return nil
        }

        return value
    }
}

// MARK: - 私有通用封装
extension EATKCHelper {

    private static func eat_saveString(service: String, key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        eat_saveData(service: service, key: key, data: data)
    }

    private static func eat_getString(service: String, key: String) -> String? {
        guard let data = eat_getData(service: service, key: key),
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private static func eat_saveInt(service: String, key: String, value: Int) {
        let data = Data("\(value)".utf8)
        eat_saveData(service: service, key: key, data: data)
    }

    private static func eat_getInt(service: String, key: String) -> Int? {
        guard let data = eat_getData(service: service, key: key),
              let string = String(data: data, encoding: .utf8),
              let value = Int(string) else {
            return nil
        }

        return value
    }

    private static func eat_saveData(service: String, key: String, data: Data) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            // ✅ 本机专属，不随 iCloud 备份
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("❌ 保存 Keychain 失败：\(status)")
            }
        }
    }

    private static func eat_getData(service: String, key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return data
    }
}
