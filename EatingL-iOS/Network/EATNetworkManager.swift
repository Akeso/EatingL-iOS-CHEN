//
//  EATNetworkManager.swift
//  PhotoK-iOS
//
//  Created by star on 2024/10/13.
//

import CommonCrypto
import CryptoKit
import UIKit

private let kProjectPreix                       = "eat"

private let block_size: size_t = 127
private let block_size_min: size_t = 7
private let header: UInt8 = 0x3c
private let trailing: UInt8 = 0xc3

// 公钥数据经过加工处理后的加密数据，
private let eat_aliya: [UInt8] = [
    0x0C, 0x25, 0x81, 0x92, 0x89, 0x1A, 0x02, 0xA4, 0x81, 0xFE,
    0x81, 0x64, 0x00, 0x9A, 0xC7, 0x9B, 0x8A, 0xE9, 0x2B, 0xC9,
    0x1E, 0x55, 0x4D, 0x63, 0xFA, 0x31, 0xEF, 0x6C, 0x9D, 0x31,
    0x21, 0xF0, 0xC3, 0x31, 0x3A, 0x55, 0x66, 0x4A, 0xC2, 0xAB,
    0x97, 0xFD, 0xF0, 0x6D, 0xF0, 0xDA, 0x8C, 0x1B, 0x59, 0xB9,
    0xEC, 0xB7, 0x41, 0x37, 0xFE, 0x34, 0x39, 0x06, 0x18, 0xF7,
    0x6F, 0x54, 0x9B, 0x95, 0xC3, 0x7F, 0x61, 0x8D, 0x6D, 0xB9,
    0x35, 0x9C, 0x6D, 0x79, 0xBC, 0x98, 0x00, 0x7F, 0x01, 0x68,
    0xCF, 0x34, 0x59, 0x3F, 0x61, 0xD8, 0x51, 0x4D, 0xBD, 0x9E,
    0x40, 0x7C, 0x55, 0xE2, 0xB2, 0x2B, 0x08, 0x50, 0x8D, 0x24,
    0x5A, 0x29, 0x0F, 0x05, 0x3C, 0x0A, 0xF6, 0xA8, 0xBE, 0x9F,
    0xAA, 0x8A, 0xF4, 0x64, 0xD1, 0xE8, 0x6A, 0x06, 0xBB, 0x6F,
    0xE9, 0x8D, 0x42, 0x2F, 0xC6, 0x52, 0x2E, 0x8D, 0x3F, 0x46,
    0xE3, 0x13, 0xAB, 0x3A, 0x09, 0x02, 0x03, 0x01, 0x00, 0xC2,
    0x22, 0x6D, 0x65, 0x74, 0x68, 0x6F, 0x64, 0x22, 0x20, 0x3A,
    0x20, 0x22, 0x50, 0x4F, 0x53, 0x54, 0x22, 0x2C, 0x0A, 0x20,
    0x3A
]

// 无用数据，用来混淆
private let eat_malia: [UInt8] = [
    0x40, 0x44, 0xAB, 0x0F, 0x01, 0x00, 0x00, 0x00, 0xA8, 0x2E,
    0x3E, 0x11, 0x01, 0x00, 0x00, 0x00, 0xF0, 0x65, 0x01, 0x11,
    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x02, 0x2B, 0x27, 0x00, 0x40, 0x60, 0x00, 0x00,
    0xB8, 0x44, 0xAB, 0x0F, 0x01, 0x00, 0x00, 0x00, 0xA8, 0x2E,
    0x3E, 0x11, 0x01, 0x00, 0x00, 0x00, 0xF0, 0x65, 0x01, 0x11,
    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x28, 0xA3, 0xAA, 0x0F, 0x01, 0x00, 0x00, 0x00,
    0x58, 0x2E, 0x3E, 0x11, 0x01, 0x00, 0x00, 0x00, 0x58, 0x2E,
    0x3E, 0x11, 0x01, 0x00, 0x00, 0x00, 0xF0, 0x65, 0x01, 0x11,
    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0xE0, 0xA2, 0xAA, 0x0F, 0x01, 0x00, 0x00, 0x00,
    0x58, 0x2E, 0x3E, 0x11, 0x01, 0x00, 0x00, 0x00, 0x38, 0x52,
    0x3E, 0x13, 0x01, 0x00, 0x00, 0x00, 0xA0, 0x20, 0x10, 0x00,
    0x22, 0x6D, 0x65, 0x74, 0x68, 0x6F, 0x64, 0x22, 0x20, 0x3A,
    0x20, 0x22, 0x50, 0x4F, 0x53, 0x54, 0x22, 0x2C, 0x0A, 0x20,
    0x20
]

// 假的公钥
private let eat_public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1BiHpSf8oFbKK6wLIUO1ToLVkSknbBgjfLAL2f+U79v36bIfNDG8sqhY09w3Z1WJHpLxmWPMlptuWkiqJNsBwC18CZD9rwHlJ4GubtutyjeJJWmEtWh8cHe1fGMpxknAsKiblPUafLFvVZoA1ffm5/2ch08dvo6BVeAh8ATT8YwIDAQAB\0"

/*
 static char *private_key = "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMeKKx5N+u+dIcM6\
 ZsKX8PCMWexB/jkYb5vDYW01bbwAAc9ZYVG9QFWyCI1aDzz2vqr00Wq76ULGLiWS\
 GqT+ZJqb6clVYzFsMfAxVUqr/W3aG7m3NzQG91SVf425nHmYf2g0P9hNnnziK1Ak\
 KQUKqJ+KZOgGb40vUo0/RuMTqzoJAgMBAAECgYEAthmJCin+ROhwpHtKxnHlZ5Ge\
 ivca6746NLuU0RZ+Y6DaBgG6x97ftJU6Ks2ytF82WEv+RdrhoJe+C3mPqV2kLrxs\
 pB48YupwDt9RE/Fc8RkhrnkfqPiTzLty9+09J3tDVFuNKaXY56tdS6XK2qsacE0l\
 07eekv8dvdpXoc4sapUCQQDjV/k/mP8twFEnLWiNApeN4NCLf1hOM7+94fiRK9x5\
 9vTyykCI6np8qM9FVcc0q4/AOUHJoNYHZkRY/G5RjJM3AkEA4LEBWhAHUU+8tGv4\
 Ai/SJCv7nHGC4zVWYP4pW6CoLYGbjzeZu6TJU4P9FYihOo7Ms8M7clTPYjwKIgza\
 fju8vwJAezPlw21qfKTIVe7pxeEtuJmo6rAsbtTkiEa5qhKW/RG0VQ7+QjSwBHaH\
 PQ/rUMPYt1dQK7CZzJDDYWYLcu43qQJAIGRkNX+qDmbYZYpLLsWGHgDZPSyAGhFO\
 ap05iSQYGrdcncD+QLb47zlP+xK/a5m6mQ/EOi9P1nGhZFdGCHzEMQJBAODO1BCt\
 NPIUELM0jYLzBooMOr095RUMC7KmApovhdjgmTVtGQTaibEhRFUUWhSx3RHLTMf3\
 A5tAx1tsmycAVYs=\0"
 */

private let eat_num64_map = "CmVpOwUxqr67uvSTWyXYZ89+DabFst/cdefEPQRg23hiNj4z015klGHIJKABnoLM"

private let eat_num64_dec_map: [UInt8] =
[
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 23, 0, 0, 0, 30, 48, 49,
    40, 41, 46, 50, 10, 11, 21, 22, 0, 0,
    0, 0, 0, 0, 0, 58, 59, 0, 24, 35,
    27, 53, 54, 55, 56, 57, 62, 63, 44, 4,
    36, 37, 38, 14, 15, 6, 2, 16, 18, 19,
    20, 0, 0, 0, 0, 0, 0, 25, 26, 31,
    32, 33, 34, 39, 42, 43, 45, 51, 52, 1,
    60, 61, 3, 8, 9, 28, 29, 12, 13, 5,
    7, 17, 47, 0, 0, 0, 0, 0
]

class EATNetworkManager {

    static let rsaPublicKey: SecKey? = eat_generatePublicKey(eat_public_key)
}

// MARK: - Encrypt
extension EATNetworkManager {

    public static func eat_networkEncrypt(_ dict: [String: Any]) -> String? {
        guard let input = eat_timestampAndSignature(dict) else {
            return nil
        }

        return eat_networkEncrypt(input)
    }

    private static func eat_networkEncrypt(_ string: String) -> String? {
        guard let data = eat_encrypt(string.eat_apiBytes()) else {
            debugPrint("\(type(of: self)):\(#line) Encrypt Error")
            return nil
        }

        guard let result = data.eat_apiString() else {
            debugPrint("\(type(of: self)):\(#line) Encrypt Error String")
            return nil
        }

        return result
    }

    private static func eat_encrypt(_ input: [UInt8]) -> Data? {
        guard !input.isEmpty else {
            return nil
        }

        let key = eat_generateAESKey()
        guard let aes = eat_aesEncrypt(input, key: key) else {
            return nil
        }

        let database64 = eat_tf_data(aes).base64EncodedData()

        guard let rsa = eat_rsaEncrypt(key) else {
            return nil
        }

        let keybase64 = rsa.base64EncodedData()

        guard let result = eat_encodeDataAndKey(database64, keyBase64: keybase64) else {
            return nil
        }

        return result
    }

    private static func eat_encodeDataAndKey(_ dataBase64: Data, keyBase64: Data) -> Data? {
        guard !dataBase64.isEmpty && !keyBase64.isEmpty else {
            return nil
        }

        let data_length = dataBase64.count
        let key_length = keyBase64.count
        var out_length = 0

        // 计数第一个字符串末尾有几个'='
        var dc1 = 0
        for idx in stride(from: data_length-1, through: 0, by: -1) {
            if dataBase64[idx] != Character("=").asciiValue {
                dc1 = data_length-1-idx
                break
            }
        }

        // 计数第二个字符串末尾有几个'='
        var dc2 = 0
        for idx in stride(from: key_length-1, through: 0, by: -1) {
            if keyBase64[idx] != Character("=").asciiValue {
                dc2 = key_length-1-idx
                break
            }
        }

        // 计数第二个字符串替换'='字符后有多长
        let sizemap: [Int] = [1, 0, -1]
        let b2length = key_length + sizemap[dc2]
        out_length = 2 + data_length + sizemap[dc1] + b2length

        // 把第二个字符串替换'='后的长度用64进制两位下列字符串表示
        var b2lengthidicator: [UInt8] = [UInt8](repeating: 0x00, count: 2)
        let b2idmap = eat_num64_map.eat_apiBytes()

        b2lengthidicator[0] = b2idmap[key_length/64]
        b2lengthidicator[1] = b2idmap[key_length%64]

        // 拼接： <表示长度的两位64进制字符> + <替换'='后的字符串1> + <替换'='后的字符串2>
        var retbuf: [UInt8] = [UInt8](repeating: 0x00, count: out_length)
        let eqsmap: [Character] = ["s", "A", "M"]
        var writeidx = 0

        retbuf[0] = b2lengthidicator[0]
        retbuf[1] = b2lengthidicator[1]
        writeidx += 2

        retbuf[writeidx] = eqsmap[dc1].asciiValue!
        writeidx += 1

        for i in 0..<data_length-dc1 {
            retbuf[writeidx+i] = dataBase64[i]
        }
        writeidx += data_length-dc1

        retbuf[writeidx] = eqsmap[dc2].asciiValue!
        writeidx += 1

        for i in 0..<key_length-dc2 {
            retbuf[writeidx+i] = keyBase64[i]
        }
        writeidx += key_length-dc2

        return Data(retbuf)
    }

    private static func eat_timestampAndSignature(_ dict: [String: Any]) -> String? {
        let signature: [String: Any] = ["od": dict,
                                        "tt": "\(Int(Date().timeIntervalSince1970))"]

        guard let string = signature.eat_apiString() else {
            return nil
        }

        return string+(string+"error").eat_apiMd5()
    }
}

// MARK: - Decode
extension EATNetworkManager {

    class func eat_decodeBase64FromService(_ string: String) -> [String: Any]? {
        guard !string.isEmpty else {
            return nil
        }

        guard let data = Data(base64Encoded: string) else {
            return nil
        }

        let bytes = data.enumerated().map { (index, byte) in
            return byte^UInt8((index+2)&0xFF)
        }

        return Data(bytes).eat_apiDictionary()
    }
}

// MARK: - AES Encrypt
extension EATNetworkManager {

    private static func eat_aesEncrypt(_ input: [UInt8], key: [UInt8]) -> Data? {
        guard !input.isEmpty && !key.isEmpty else {
            return nil
        }

        var ukey: [UInt8] = [UInt8](repeating: 0x00, count: key.count)

        for i in 0..<key.count {
            ukey[i] ^= key[i]^UInt8(i)
        }

        let cryptLength = input.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        var encryptedSize = 0

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            input.withUnsafeBytes { inputBytes in
                ukey.withUnsafeBytes { ukeyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            CCOptions(kCCOptionPKCS7Padding),
                            ukeyBytes.baseAddress,
                            key.count,
                            ukeyBytes.baseAddress?.advanced(by: 16),
                            inputBytes.baseAddress,
                            input.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &encryptedSize)
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            return nil
        }

        return cryptData.subdata(in: 0..<encryptedSize)
    }

    private static func eat_generateAESKey() -> [UInt8] {
        var out: [UInt8] = [UInt8](repeating: 0x00, count: 32)

        for i in out.indices {
            var tempc: UInt8 = 0
            let arcn = UInt8.random(in: 0..<36)
            if arcn < 10 {
                tempc = arcn + (Character("0").asciiValue ?? 0)
            } else {
                tempc = arcn - 10 + (Character("a").asciiValue ?? 97)
            }
            out[i] = tempc
        }

        return out
    }
}

// MARK: - RSA Encrypt
extension EATNetworkManager {

    private static func eat_rsaEncrypt(_ input: [UInt8]) -> Data? {
        guard let key = rsaPublicKey, !input.isEmpty else {
            return nil
        }

        let blockSize = SecKeyGetBlockSize(key)
        let srcBlockSize = blockSize - 11

        var encryptedData = Data()

        var idx = 0
        while idx < input.count {
            let dataLen = min(input.count - idx, srcBlockSize)
            let chunk = Data(input[idx..<idx+dataLen])

            let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1

            guard SecKeyIsAlgorithmSupported(key, .encrypt, algorithm) else {
                return nil
            }

            var error: Unmanaged<CFError>?
            guard let encryptedChunk = SecKeyCreateEncryptedData(key, algorithm, chunk as CFData, &error) as Data? else {
                return nil
            }

            encryptedData.append(encryptedChunk)
            idx += dataLen
        }

        return encryptedData
    }

    class func eat_stripPublicKeyHeader(_ data: Data) -> Data? {
        guard !data.isEmpty else {
            return nil
        }

        var idx: Int = 0
        var bytes = data.eat_apiBytes()
        guard bytes[idx] == 0x30 else {
            return nil
        }

        idx += 1

        if bytes[idx] > 0x80 {
            idx += Int(bytes[idx] - 0x80 + 1)
        } else {
            idx += 1
        }

        let seqiod: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]

        for i in 0..<seqiod.count {
            bytes[idx+i] = seqiod[i]
        }

        idx += 15

        guard bytes[idx] == 0x03 else {
            return nil
        }

        idx += 1

        if bytes[idx] > 0x80 {
            idx += Int(bytes[idx] - 0x80 + 1)
        } else {
            idx += 1
        }

        guard bytes[idx] == 0x00 else {
            return nil
        }

        idx += 1

        return Data(bytes: bytes, count: data.count-idx)
    }

    private static func eat_generatePublicKey(_ key: String) -> SecKey? {
        var k = key.replacingOccurrences(of: "\r", with: "")
        k = k.replacingOccurrences(of: "\n", with: "")
        k = k.replacingOccurrences(of: "\t", with: "")
        k = k.replacingOccurrences(of: " ", with: "")

        guard let data = Data(base64Encoded: k, options: .ignoreUnknownCharacters) else {
            return nil
        }

        guard eat_stripPublicKeyHeader(data) != nil else {
            debugPrint("\(type(of: self)):\(#line) Encrypt Error Public Key Header")
            return nil
        }

        var tag = String(format: "%@_RSA_PublicKey", kProjectPreix)
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            tag = tag+"_"+name
        }

        let d_tag = tag.data(using: .utf8)

        // Delete any old lingering key with the same tag
        var publicKey: [String: Any] = [:]
        publicKey[kSecClass as String] = kSecClassKey
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA
        publicKey[kSecAttrApplicationTag as String] = d_tag
        SecItemDelete(publicKey as CFDictionary)

        // Add persistent version of the key to system keychain
        var udt = eat_tf_reverse_data(Data(bytes: eat_aliya, count: 140))
        publicKey[kSecValueData as String] = udt

        udt = eat_tf_reverse_data(Data(bytes: eat_malia, count: 140))
        publicKey[kSecAttrKeyClass as String] = kSecAttrKeyClassPublic
        publicKey[kSecReturnPersistentRef as String] = true

        var persistKey: CFTypeRef?
        var status = SecItemAdd(publicKey as CFDictionary, &persistKey)
        guard status == noErr || status == errSecDuplicateItem else {
            debugPrint("\(type(of: self)):\(#line) Encrypt Error Sec Add \(status)")
            return nil
        }

        publicKey.removeValue(forKey: kSecValueData as String)
        publicKey.removeValue(forKey: kSecReturnPersistentRef as String)
        publicKey[kSecReturnRef as String] = true
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA

        // Now fetch the SecKeyRef version of the key
        var keyRef: CFTypeRef?
        status = withUnsafeMutablePointer(to: &keyRef) {
            SecItemCopyMatching(publicKey as CFDictionary, UnsafeMutablePointer($0))
        }

        guard status == noErr else {
            debugPrint("\(type(of: self)):\(#line) Encrypt Error Sec Match \(status)")
            return nil
        }

        guard let value = keyRef, CFGetTypeID(value) == SecKeyGetTypeID() else {
            return nil
        }

        return unsafeBitCast(value, to: SecKey.self)
    }
}

// MARK: - TF Data
extension EATNetworkManager {

    private static func eat_tf_data(_ data: Data) -> Data {
        var bytes = data.eat_apiBytes()
        let length = bytes.count

        bytes[0] ^= header
        bytes[length-1] ^= trailing

        if data.count < block_size_min {
            return Data(bytes)
        }

        let tfsize = length < block_size ? length : block_size

        var tpbuf: [UInt8] = [UInt8](repeating: 0x00, count: tfsize)

        if tfsize%2 == 1 {
            let midnum = (tfsize-1)/2+1
            for idx in 1...tfsize {
                if tfsize == idx {
                    tpbuf[idx-1] = bytes[(idx-1)/2]
                } else if idx%2 == 1 {
                    tpbuf[idx-1] = bytes[(idx+1)/2 - 1]
                } else {
                    tpbuf[idx-1] = bytes[midnum + idx/2 - 1]
                }
            }
        } else {
            let midnum = tfsize/2
            for idx in 1...tfsize {
                if idx%2 == 1 {
                    tpbuf[idx-1] = bytes[(idx+1)/2 - 1]
                } else {
                    tpbuf[idx-1] = bytes[midnum + idx/2 - 1]
                }
            }
        }

        for i in 0..<tfsize {
            bytes[i] = tpbuf[i]
        }

        return Data(bytes)
    }

    private static func eat_tf_reverse_data(_ data: Data) -> Data {
        guard !data.isEmpty else {
            return data
        }

        var bytes = data.eat_apiBytes()
        let length = bytes.count

        if bytes.count >= block_size_min {
            let tfsize = length < block_size ? length : block_size
            var tpbuf: [UInt8] = [UInt8](repeating: 0x00, count: tfsize)

            if tfsize%2 == 1 {
                let midnum = (tfsize-1)/2 + 1
                for idx in 1...tfsize {
                    if idx == midnum {
                        tpbuf[idx-1] = bytes[tfsize-1]
                    } else if idx < midnum {
                        tpbuf[idx-1] = bytes[2*idx - 1 - 1]
                    } else {
                        tpbuf[idx-1] = bytes[(idx-midnum)*2 - 1]
                    }
                }
            } else {
                let midnum = tfsize/2
                for idx in 1...tfsize {
                    if idx <= midnum {
                        tpbuf[idx-1] = bytes[2*idx - 1 - 1]
                    } else {
                        tpbuf[idx-1] = bytes[(idx-midnum)*2 - 1]
                    }
                }
            }

            for i in 0..<tfsize {
                bytes[i] = tpbuf[i]
            }
        }

        bytes[0] ^= header
        bytes[length-1] ^= trailing

        return Data(bytes)
    }
}
