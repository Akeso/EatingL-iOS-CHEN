//
//  EATRequestTaskBaseManager.swift
//  HomeAID-iOS
//
//  Created by star on 2024/6/6.
//

import RxSwift
import UIKit

class EATRequestTaskBaseManager: EATRequestBaseManager {

    /// 轮询结果状态
    enum TaskRequestResult {
        /// 1 排队中（未执行完）
        case waiting
        /// 3 执行中（未执行完）
        case processing
        /// 5 失败
        case failed(TaskRequestErrorCode)
        /// 7 成功
        case succeed([String: Any])
        /// 网络错误
        case networkFailed(Error?)
    }

    enum TaskRequestErrorCode: Int {
        case request = -1
        case imageInvalid = 1
    }

    private var taskStartTime: TimeInterval = 0
    private let taskFirstRequestInterval: Int = 5
    private let taskRequestInterval: Int = 5
    private let taskTotalTimeout: Int = 120

//    private let taskFirstRequestInterval: Int = EATRemoteConfigsManager.shared.configs.taskTimeLimit[0]
//    private let taskRequestInterval: Int = EATRemoteConfigsManager.shared.configs.taskTimeLimit[1]
//    private let taskTotalTimeout: Int = EATRemoteConfigsManager.shared.configs.taskTimeLimit[2]

    public var taskResults: [String: TaskRequestResult] = [:]

    func eat_getUnfinishTaskIds() -> [String] {
        var taskIds: [String] = []
        for taskResult in taskResults {
            switch taskResult.value {
            case .succeed, .failed:
                break
            default:
                taskIds.append(taskResult.key)
            }
        }
        return taskIds
    }

    func eat_startRequestTask(taskId: String) -> Observable<[String: Any]> {
        return eat_startRequestTasks(taskIds: [taskId]).flatMapLatest { results -> Observable<[String: Any]> in
            guard let result = results.first else {
                return Observable.error(EATRequestError.task(.taskResult))
            }

            return Observable.just(result)
        }
    }

    func eat_startRequestTasks(taskIds: [String]) -> Observable<[[String: Any]]> {
        taskStartTime = Date().timeIntervalSince1970

        taskResults.removeAll()
        _ = taskIds.map { taskResults[$0] = .waiting }

        return eat_queryTasks().flatMapLatest { result -> Observable<[[String: Any]]> in
            guard result else {
                return Observable.error(EATRequestError.task(.taskResult))
            }

            let succeeds = self.taskResults.compactMap {
                if case let .succeed(result) = $0.value {
                    return result
                }
                return nil
            }
            let errorCodes = self.taskResults.compactMap {
                if case let .failed(errorCode) = $0.value {
                    return errorCode
                }
                return nil
            }
            let unfinishs = self.taskResults.filter {
                switch $0.value {
                case .waiting, .processing, .networkFailed:
                    return true
                default:
                    return false
                }
            }

            guard !succeeds.isEmpty else {
                if !errorCodes.isEmpty, errorCodes.contains(.imageInvalid) {
                    return Observable.error(EATRequestError.response(.imageInvalid))
                } else if !unfinishs.isEmpty {
                    return Observable.error(EATRequestError.task(.taskUnfinish))
                } else {
                    return Observable.error(EATRequestError.task(.taskResult))
                }
            }

            return Observable.just(succeeds)
        }
    }

    func eat_queryTasks(_ isFirst: Bool = true) -> Observable<Bool> {
        let taskIds = eat_getUnfinishTaskIds()

        let taskTotalTime = Date().timeIntervalSince1970 - taskStartTime

        guard taskTotalTime < TimeInterval(taskTotalTimeout), !taskIds.isEmpty else {
            return Observable<Bool>.just(true)
        }

        let delay = isFirst ? taskFirstRequestInterval : taskRequestInterval

        return eat_requestTasks(taskIds: taskIds).delaySubscription(.seconds(delay), scheduler: MainScheduler.instance).flatMapLatest { results -> Observable<Bool> in
            zip(taskIds, results).forEach { taskId, result in
                self.taskResults[taskId] = result
            }

            return self.eat_queryTasks(false)
        }
    }

    func eat_requestTasks(taskIds: [String]) -> Observable<[TaskRequestResult]> {
        return Observable.zip(taskIds.map { eat_requestTaskResult(taskId: $0) })
    }

    func eat_requestTaskResult(taskId: String) -> Observable<TaskRequestResult> {
        return EATAPIManager.shared.eat_taskResult(taskId: taskId).flatMapLatest { response -> Observable<TaskRequestResult> in
            guard let data = response["data"] as? [String: Any],
                  let status = data["job_status_code"] as? Int
            else {
                return Observable.just(.failed(.request))
            }

            switch status {
            case 1:
                return Observable.just(.waiting)
            case 3:
                return Observable.just(.processing)
            case 5:
                if let result = data["job_result"] as? [String: Any],
                   let code = result["code"] as? Int,
                   let errorCode = TaskRequestErrorCode(rawValue: code) {
                    return Observable.just(.failed(errorCode))
                } else {
                    return Observable.just(.failed(.request))
                }
            default:
                if let result = data["job_result"] as? [String: Any] {
                    return Observable.just(.succeed(result))
                } else {
                    return Observable.just(.failed(.request))
                }
            }
        }.catch { Observable.just(.networkFailed($0)) }
    }
}

// MARK: - 图片轮询
extension EATRequestTaskBaseManager {

    func eat_startRequestImageTask(taskId: String) -> Observable<String> {
        return eat_startRequestImageTasks(taskIds: [taskId]).flatMapLatest { imageUrls -> Observable<String> in
            guard let imageUrl = imageUrls.first else {
                return Observable.error(EATRequestError.task(.taskResult))
            }

            return Observable.just(imageUrl)
        }
    }

    func eat_startRequestImageTasks(taskIds: [String]) -> Observable<[String]> {
        return eat_startRequestTasks(taskIds: taskIds).flatMapLatest { results -> Observable<[String]> in
            let imageUrls = results.compactMap { response in
                if let imageUrls = response["image_urls"] as? [String], !imageUrls.isEmpty {
                    return imageUrls
                }
                return nil
            }.flatMap { $0 }

            guard !imageUrls.isEmpty else {
                return Observable.error(EATRequestError.task(.taskResult))
            }

            return Observable.just(imageUrls)
        }
    }
}
