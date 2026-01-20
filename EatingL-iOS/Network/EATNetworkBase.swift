//
//  EATNetworkBase.swift
//  PhotoK-iOS
//
//  Created by star on 2024/10/18.
//

import RxSwift

typealias EATEncryptResult = (originParameters: [String: Any],
                              encryptParameters: [String: Any])

private let eat_api_timeout: TimeInterval = 40
private let eat_api_config_timeout: TimeInterval = 15

private let eat_api_entry   = "entry"

class EATNetworkBase {

    static let g_networkQueue = DispatchQueue(label: "com.EAT.network")
    static let g_networkScheduler = SerialDispatchQueueScheduler(queue: g_networkQueue, internalSerialQueueName: "com.EAT.network.scheduler")
    static let shared: EATNetworkBase = EATNetworkBase()
    static var task: URLSessionTask?

    static let configSessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = eat_api_config_timeout
        configuration.timeoutIntervalForResource = eat_api_config_timeout
        configuration.httpAdditionalHeaders = ["User-Agent": eat_defaultUserAgent]
        let configSessionManager = URLSession(configuration: configuration)
        return configSessionManager
    }()

    static let sessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = eat_api_timeout
        configuration.timeoutIntervalForResource = eat_api_timeout
        configuration.httpAdditionalHeaders = ["User-Agent": eat_defaultUserAgent]
        let sessionManager = URLSession(configuration: configuration)
        return sessionManager
    }()

    static let eat_defaultUserAgent: String = {
        return String(format: "ios/%@/%li/%@/%@",
                      EATConstant.kBaseAppName,
                      EATConstant.kBaseAppId,
                      EATDevice.eat_appVersion,
                      EATDevice.eat_anonymousUserId)
    }()

    static func eat_sessionManagerWithUrl(_ url: String) -> URLSession {
        if url == EATAPI.config {
            debugPrint("\(type(of: self)):\(#line) Session Config Timeout \(Self.configSessionManager.configuration.timeoutIntervalForRequest), \(Self.configSessionManager.configuration.timeoutIntervalForResource)")
            return Self.configSessionManager
        } else {
            debugPrint("\(type(of: self)):\(#line) Session Normal Timeout \(Self.sessionManager.configuration.timeoutIntervalForRequest), \(Self.sessionManager.configuration.timeoutIntervalForResource)")
            return Self.sessionManager
        }
    }

    func eat_cancelCurrentTask() {
        Self.task?.cancel()
    }

    func eat_cancelAllTasks() {
        Self.configSessionManager.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
        Self.sessionManager.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    private func eat_processParameters(_ path: String,
                                       parameters: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]

        URLComponents(string: path)?.queryItems?.forEach { item in
            result[item.name] = item.value
        }

//        let status = EATAppFlyerManager.eat_shared.afStatus
//        if !status.isEmpty {
//            if status == EATConstant.eat_af_no_organic {
//                result["aq"] = EATConstant.eat_sh_fou
//            } else {
//                result["aq"] = EATConstant.eat_sh_shi
//            }
//        }
//
//        let media = EATAppFlyerManager.eat_shared.afMediaSource
//        if !media.isEmpty {
//            result["media"] = media
//        }

        let language = EATConstant.kCurrentLanguage
        if !language.isEmpty {
            result["language"] = language
        }

        result.merge(parameters) { _, new in new }

        return result
    }
}

extension EATNetworkBase {

    func eat_generateEncryptParams(_ path: String,
                                   parameters: [String: Any]) -> Observable<EATEncryptResult> {
        return Observable<EATEncryptResult>.create { observer in
            let originParameters = self.eat_processParameters(path, parameters: parameters)
            let originalData = ["path": path.components(separatedBy: "?").first ?? "",
                                "body": originParameters]

            debugPrint("\(type(of: self)):\(#line) Request Parameters\n"+(originalData.eat_apiString() ?? ""))

            if let data = EATNetworkManager.eat_networkEncrypt(originalData) {
                observer.onNext((originParameters, ["data": data]))
                observer.onCompleted()
            } else {
                observer.onError(EATNetworkError.request(.encrypt))
            }

            return Disposables.create()
        }.subscribe(on: Self.g_networkScheduler).observe(on: MainScheduler.instance)
    }

    func eat_serverUrl() -> URL? {
        return URL(string: eat_api_entry, relativeTo: URL(string: EATConstant.kBaseAPIURL))
    }

    private func eat_requestPath(_ path: String,
                                 encryptResult: EATEncryptResult) -> Observable<[String: Any]> {
        return Observable<[String: Any]>.create { observer in
            if let url = self.eat_serverUrl() {
                let requestId = UUID().uuidString
                let session = Self.eat_sessionManagerWithUrl(path)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = encryptResult.encryptParameters.eat_apiData()
                request.timeoutInterval = session.configuration.timeoutIntervalForRequest
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                debugPrint("\(type(of: self)):\(#line) Request URL = \(url) timeout = \(request.timeoutInterval)")

                EATNetworkEventUtil.eat_requestStart(requestId,
                                                 path: path,
                                                 parameters: encryptResult.originParameters)

                Self.task = session.dataTask(with: request) { data, _, error in
                    if let error = error {
                        debugPrint("\(type(of: self)):\(#line) Request End Error\nPath = \(path)\n\(error)")
                        EATNetworkEventUtil.eat_requestComplete(requestId, success: false)
                        if let error = error as? URLError, error.code == .cancelled {
                            observer.onError(EATNetworkError.network(.cancelled))
                        } else {
                            observer.onError(EATNetworkError.network(.error))
                        }
                    } else {
                        guard let responseDict = data?.eat_apiDictionary() else {
                            debugPrint("\(type(of: self)):\(#line) Request End Error Decode Dict")
                            EATNetworkEventUtil.eat_requestComplete(requestId, success: false)
                            observer.onError(EATNetworkError.response(.decode))
                            return
                        }

                        guard let data = responseDict["data"] as? String else {
                            debugPrint("\(type(of: self)):\(#line) Request End Error Decode Data\n\(responseDict.eat_apiString() ?? "")")
                            EATNetworkEventUtil.eat_requestComplete(requestId, success: false)
                            observer.onError(EATNetworkError.response(.decode))
                            return
                        }

                        guard let result = EATNetworkManager.eat_decodeBase64FromService(data) else {
                            debugPrint("\(type(of: self)):\(#line) Request End Error Decrypt\n\(responseDict.eat_apiString() ?? "")")
                            EATNetworkEventUtil.eat_requestComplete(requestId, success: false)
                            observer.onError(EATNetworkError.response(.decrypt))
                            return
                        }

                        EATNetworkEventUtil.eat_requestComplete(requestId, success: true)

                        debugPrint("\(type(of: self)):\(#line) Request End Success\nPath = \(path)\n"+(result.eat_apiString() ?? ""))

                        observer.onNext(result)
                        observer.onCompleted()
                    }
                }
                Self.task?.resume()
            } else {
                observer.onError(EATNetworkError.request(.path))
            }

            return Disposables.create()
        }
    }

    func eat_request(_ path: String, parameters: [String: Any]) -> Observable<[String: Any]> {
        debugPrint("\(type(of: self)):\(#line) Request Start")
        return eat_generateEncryptParams(path, parameters: parameters)
            .flatMapLatest { result -> Observable<[String: Any]> in
                return self.eat_requestPath(path, encryptResult: result)
            }.observe(on: MainScheduler.instance)
    }
}
