//
//  EATAPIManager.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//


//import AppsFlyerLib
import AppTrackingTransparency
//import FirebaseAnalytics
import RxSwift
import UIKit

class EATAPI {

    static let version = 50

    static let config = "PZhi"
    static let iapOrder = "RedroIos"
    static let user = "GetUser"
    static let feedback = "Feedback"
    static let awsUpload = "AWSUpload"
    static let taskResult = "AITaskResult"

    static let AIEnhance = "AIEnhance"
    static let AIEyeBag = "AIEyeBag"
    static let AINoseJob = "AINoseJob"
    static let AILipFiller = "AILipFiller"
    static let AIBigEye = "AIBigEye"
    static let AIFixExpression = "AIFixExpression"
    static let AIOpenEye = "AIOpenEye"
    static let AIFixGaze = "AIFixGaze"
    static let AISmile = "AISmile"
    static let AIRemove = "AIRemove"
    static let AIMakeup = "AIMakeup"
    static let AIHairStyle = "AIHairStyle"
    static let AIHairColor = "AIHairColor"
    static let AIHairSalon = "AIHairSalon"
    static let AIStyles = "AIStyles"
    static let AIBeard = "AIBeard"
    static let AIFaceColor = "AIFaceColor"
    static let AIFaceShapeGender = "AIFaceShapeGender"

    static let editorTab = "GetData?type=editor&version=\(version)"
    static let styleTab = "GetData?type=styles&version=\(version)"
    static let salonTab = "GetData?type=hairsalon&version=\(version)"

    static let editorMaleTab = "GetData?type=editormale&version=\(version)"
    static let styleMaleTab = "GetData?type=stylesmale&version=\(version)"
    static let salonMaleTab = "GetData?type=hairsalonmale&version=\(version)"
}

class EATAPIManager: NSObject {

    static let shared: EATAPIManager = EATAPIManager()

    // 封装一下，统一错误处理
    private func eat_request(_ path: String,
                             parameters: [String: Any]) -> Observable<[String: Any]> {
        return EATNetworkBase.shared.eat_request(path, parameters: parameters).catch { error in
            if case .network(.cancelled) = error as? EATNetworkError {
                return Observable.error(EATRequestError.response(.cancelled))
            }

            return Observable.error(EATRequestError.response(.network))
        }
    }
}

extension EATAPIManager {

    // 配置
    func eat_refreshConfigs(version: Int) -> Observable<[String: Any]> {
        let parametersObservable = Observable.deferred {
            var parameters: [String: Any] = ["version": version]

            // 在订阅时才获取最新值
//            let campaign = EATAppFlyerManager.eat_shared.afCampaign
//            let ad = EATAppFlyerManager.eat_shared.afAd
//
//            if !campaign.isEmpty {
//                parameters["campaign"] = campaign
//            }
//            if !ad.isEmpty {
//                parameters["ad"] = ad
//            }

            /*
             is_vpn 是否vpn，1是 0否
             is_charging是否在充电， 1是 0否
             battery_status 电量值
             device 设备
             os_version 设备系统版本号
             network_model 网络模式 1 WiFi 2 流量
             */
            parameters["is_vpn"] = EATDevice.eat_isVPNOn ? 1 : 0
            parameters["is_charging"] = EATDevice.eat_isCharging ? 1 : 0
            parameters["battery_status"] = EATDevice.eat_batteryLevel
            parameters["device"] = EATDevice.eat_deviceType
            parameters["os_version"] = EATDevice.eat_systemVersion
            parameters["network_model"] = EATDevice.eat_isWifi ? 1 : 2

            return Observable.just(parameters)
        }

        return parametersObservable.flatMapLatest { parameters in
            self.eat_request(EATAPI.config, parameters: parameters)
        }
    }

    // 用户信息
//    func eat_refreshUser() -> Observable<[String: Any]> {
//        let parameters: [String: Any] = [
//            "device_id": EATDevice.eat_anonymousUserId
//        ]
//        return eat_request(EATAPI.user, parameters: parameters)
//    }
//
//    // 订阅
//    func eat_iapOrders(transactionId: String,
//                       oTransactionId: String) -> Observable<[String: Any]> {
//        var parameters = ["original_transaction_identifier": oTransactionId,
//                          "appsflyer_id": AppsFlyerLib.shared().getAppsFlyerUID(),
//                          "idfa": EATDevice.eat_idfaString,
//                          "idfv": EATDevice.eat_idfvString,
//                          "device_id": EATDevice.eat_anonymousUserId,
//                          "instance_id": Analytics.appInstanceID() ?? "",
//                          "os_version": EATDevice.eat_systemVersion,
//                          "att": "\(ATTrackingManager.trackingAuthorizationStatus.rawValue)",
//                          "campaign": EATAppFlyerManager.eat_shared.afCampaign,
//                          "ad": EATAppFlyerManager.eat_shared.afAd,
//                          "adset": EATAppFlyerManager.eat_shared.afAdset,
//                          "country_code": EATConstant.kCurrentCountryCode]
//            .filter { !$0.value.isEmpty }
//        parameters["transaction_identifier"] = transactionId
//        return eat_request(EATAPI.iapOrder, parameters: parameters)
//    }
//
//    /// Feedback/Review
//    /// - Parameters:
//    ///   - type: feedback == 1; review == 2
//    func eat_uploadFeedback(type: Int) -> Observable<[String: Any]> {
//        var sysinfo = utsname()
//        uname(&sysinfo)
//        let deviceString = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? ""
//
//        var param: [String: Any] = [:]
//        /**
//         title = reviewTitle
//         topic = feedbackTopic
//         content = type == 1 feedbackContent; type == 2 reviewContent
//         type = feedback == 1; review == 2
//         annex: 0, 无图片; 1, 有图片
//         rating = review rate star
//         */
//        param["topic"] = EATFeedbackManager.eat_shared.topic.enName
//        param["content"] = EATFeedbackManager.eat_shared.suggestion
//        param["os_version"] = UIDevice.current.systemVersion
//        param["device_brand"] = deviceString
//        param["device_resolution"] = String(format: "%.0fx%.0f", UIScreen.main.bounds.width, UIScreen.main.bounds.height)
//        param["type"] = type
//        if type == 1 {
//            param["annex"] = EATFeedbackManager.eat_shared.imageDatas.isEmpty ? 0 : 1
//        }
//
//        return eat_request(EATAPI.feedback, parameters: param)
//    }
}

extension EATAPIManager {
    /// AWS 上传图片
    func eat_awsUpload() -> Observable<[String: Any]> {
        return eat_request(EATAPI.awsUpload, parameters: [:])
    }
}

extension EATAPIManager {
    /// 轮询接口
    /// - Parameters:
    ///   - job_id: 任务 id
    /// - Returns: 返回结果
    ///   - 任务状态码，1-排队中，3-处理中，5-处理失败，7-处理完成
    ///   - 1: 'in-queue'
    ///   - 3: 'handling'
    ///   - 5: 'fail'
    ///   - 7: 'success'
    func eat_taskResult(taskId: String) -> Observable<[String: Any]> {
        let parameters: [String: Any] = [
            "job_id": taskId
        ]
        return eat_request(EATAPI.taskResult, parameters: parameters)
    }
}
