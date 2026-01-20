//
//  EATNetworkEventUtil.swift
//  PhotoK-iOS
//
//  Created by star on 2024/3/14.
//

import UIKit

class EATAPIEventItem {

    public var startTime: TimeInterval = 0.0
    public var path: String = ""
    public var name: String = ""
}

class EATNetworkEventUtil {

    static let g_networkLogerQueue = DispatchQueue(label: "com.EAT.network.loger")
    static var events: [String: EATAPIEventItem] = [:]

    class func eat_requestStart(_ requestId: String, path: String, parameters: [String: Any]?) {
        g_networkLogerQueue.async {
            let item = EATAPIEventItem()
            item.startTime = Date().timeIntervalSince1970
            item.path = path
            item.name = eat_requestName(path, parameters: parameters)

            events[requestId] = item
        }
    }

    class func eat_requestComplete(_ requestId: String, success: Bool) {
        g_networkLogerQueue.async {
            if let item = events.removeValue(forKey: requestId) {
                let timeEnd = Date().timeIntervalSince1970
                let duration = min(Int(ceil(timeEnd-item.startTime)), 60)

                let eventName = item.name
                let eventParam = ["result": success ? "success":"failed",
                                  "request_duration": "\(duration)"]

                debugPrint("\(type(of: self)):\(#line) Request Finished\n\(eventName)\n\(eventParam.eat_apiString() ?? "")")
//                if !eventName.isEmpty {
//                    EATEventUtil.eat_event(eventName, values: eventParam)
//                }
            }
        }
    }

    class func eat_requestName(_ path: String, parameters: [String: Any]?) -> String {
        var params: [String: Any] = [:]
        if let parameters = parameters {
            params.merge(parameters) { (_, new) in new }
        }

        let pathComponents = URLComponents(string: path)
        pathComponents?.queryItems?.forEach({ item in
            params[item.name] = item.value
        })

        var name = "api_result_\(path.components(separatedBy: "?").first ?? "")"
        if let type = params["type"] {
            name = name+"/"+String(describing: type)
        }
        if let version = params["version"] {
            name = name+"/"+String(describing: version)
        }

        return name.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "-", with: "_")
    }
}
