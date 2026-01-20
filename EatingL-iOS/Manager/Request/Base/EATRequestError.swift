//
//  EATRequestError.swift
//  PhotoK-iOS
//
//  Created by star on 2025/7/28.
//

/*
 持久化用法

 let error: EATRequestError = .task(.taskResult)

 let data = try JSONEncoder().encode(error)
 let json = String(data: data, encoding: .utf8)!
 print(json)
 // 输出：{"type":"task","value":"taskResult"}

 let decoded = try JSONDecoder().decode(EATRequestError.self, from: data)
 print(decoded)
*/

/*
 保存 UserDefaults
 UserDefaults.standard.set(data, forKey: "lastAPIError")

 if let savedData = UserDefaults.standard.data(forKey: "lastAPIError"),
    let decodedError = try? JSONDecoder().decode(EATRequestError.self, from: savedData) {
     print("恢复错误：\(decodedError)")
 }
 */
enum EATRequestError: Error, Codable, Equatable {

    case image(EATRequestImageError)         // 图片失败
    case task(EATRequestTaskError)           // Task 失败
    case response(EATRequestResponseError)   // 业务逻辑失败
    case other(EATRequestOtherError)         // 其他错误

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    enum ErrorType: String, Codable {
        case image, task, response, other
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .image(let err):
            try container.encode(ErrorType.image, forKey: .type)
            try container.encode(err, forKey: .value)
        case .task(let err):
            try container.encode(ErrorType.task, forKey: .type)
            try container.encode(err, forKey: .value)
        case .response(let err):
            try container.encode(ErrorType.response, forKey: .type)
            try container.encode(err, forKey: .value)
        case .other(let err):
            try container.encode(ErrorType.other, forKey: .type)
            try container.encode(err, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ErrorType.self, forKey: .type)

        switch type {
        case .image:
            let value = try container.decode(EATRequestImageError.self, forKey: .value)
            self = .image(value)
        case .task:
            let value = try container.decode(EATRequestTaskError.self, forKey: .value)
            self = .task(value)
        case .response:
            let value = try container.decode(EATRequestResponseError.self, forKey: .value)
            self = .response(value)
        case .other:
            let value = try container.decode(EATRequestOtherError.self, forKey: .value)
            self = .other(value)
        }
    }
}

enum EATRequestImageError: String, Codable {
    case upload     // 上传失败
    case download   // 下载失败
}

enum EATRequestTaskError: String, Codable {
    case taskId         // 获取 Task id(s) 失败
    case taskResult     // Task 轮询失败
    case taskUnfinish   // Task 轮询未完成
}

enum EATRequestResponseError: String, Codable {
    case cancelled      // 请求取消
    case response       // response 解析错误
    case network        // 请求错误
    case promptInvalid  // 敏感词
    case imageInvalid   // 图片不合规
}

enum EATRequestOtherError: String, Codable {
    case requestParameter // 参数错误
    case apiError         // API 错误
    case fakeRequest      // 假请求
}
