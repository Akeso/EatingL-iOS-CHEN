//
//  EATConstant.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import RxCocoa
import RxSwift
import SnapKit
import SwiftDate
import UIKit

let sh_shi = "shi"
let sh_fou = "fou"

let af_organic = "Organic"
let af_no_organic = "Non-organic"
let af_timeout = "timeout"

let kAppBundleId = Bundle.main.bundleIdentifier ?? ""
let kInAppPurchaseVIPProductIdWeek = kAppBundleId+".vip"
let kInAppPurchaseVIPProductIdMonth = kAppBundleId+".vipmonth"
let kInAppPurchaseVIPProductIdYear = kAppBundleId+".vipyear"
let kInAppPurchaseVIPProductPriceWeek = "$9.99"
let kInAppPurchaseVIPProductPriceMonth = "$16.99"
let kInAppPurchaseVIPProductPriceYear = "$39.99"

let kInAppPurchaseVIPProductIdWeek2 = kAppBundleId+".vip2"
let kInAppPurchaseVIPProductIdMonth2 = kAppBundleId+".vipmonth2"
let kInAppPurchaseVIPProductIdYear2 = kAppBundleId+".vipyear2"
let kInAppPurchaseVIPProductPriceWeek2 = "$9.99"
let kInAppPurchaseVIPProductPriceMonth2 = "$16.99"
let kInAppPurchaseVIPProductPriceYear2 = "$39.99"

let kAppleSupportURL = "https://support.apple.com/en-us/HT202039"
let kAppsFlyerDevKey = "jjqxHzaJwzWGK2EtbcpbXN"
let kAppLovinMaxKey = "Owg8bBOamnxFImU5kBVfTcpGodZOABkLWXAK_W4uRto-LBVKQ-7pOSFX6G1b8lCJOW5Ku_DK2CJhd2fphRP-nI"

let kWebTermsUrl = "https://www.herobotlimited.com/terms-of-service-restyle"
let kWebPolicyUrl = "https://www.herobotlimited.com/privacy-policy-restyle"
let kOfficialMail = "feedback@herobotlimited.com"

let kAPIURL = "https://api.restyle.herobotlimited.com"

#if DEBUG || ADHOC
    let kAPIURLTest = "https://dev-photo-k.dev.secretlisa.com"
    let kDefaultAPIURL = kAPIURL

// TODO 订阅
//    let kAppLovinMaxAppOpen = "3e104af841106d5e"
#else
    let kAPIURLTest = kAPIURL
    let kDefaultAPIURL = kAPIURL

// TODO 订阅
//    let kAppLovinMaxAppOpen = "3e104af841106d5e"
#endif

#if DEBUG
    let kShowDebug = true
    var kShowAd = false
    let kEvent = false
#elseif ADHOC
    let kShowDebug = true
    var kShowAd = true
    let kEvent = false
#else
    let kShowDebug = false
    var kShowAd = true
    let kEvent = true
#endif

#if IS_TEST
    let kAppName = "PhotoTest"
    let kAppId = 1000090000
    let kFirebaseRemoteConfigsPrefix = "test"
#elseif IS_RESTYLE
    let kAppName = "ReStyle"
    let kAppId = 6757188199
    let kFirebaseRemoteConfigsPrefix = "photok"
#else
#endif

#if DEBUG
func debugPrint(_ message: String) {
    print(message)
}
func print(_ message: String) {
    print("[\(DateInRegion(Date(), region: .current).toFormat("yyyy-MM-dd HH:mm:ss.SSS"))] \(message)", separator: " ", terminator: "\n")
}
#else
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
#endif

class EATConstant: NSObject {

    @objc static var kBaseAPIURL: String {
        if kShowDebug {
            if let url = UserDefaults.standard.string(forKey: EATConstant.eat_udk_app_url) {
                return url
            } else {
                return kDefaultAPIURL
            }
        } else {
            return kDefaultAPIURL
        }
    }

    @objc static var kBaseAppId: Int {
        return kAppId
    }

    @objc static var kBaseAppName: String {
        return kAppName
    }

    @objc static var kBaseOfficialMail: String {
        return kOfficialMail
    }

    @objc static var kCurrentLanguage: String {
        var result: String?
        let language = NSLocale.preferredLanguages.first
        let languageDic = NSLocale.components(fromLocaleIdentifier: language ?? "")
        let languageCode = languageDic["kCFLocaleLanguageCodeKey"]
        let scriptCode = languageDic["kCFLocaleScriptCodeKey"]
        result = languageCode
        if scriptCode != nil {
            result = String(format: "%@-%@", languageCode ?? "", scriptCode ?? "")
            // 使用的language参数, 与本地多语言对应
            if result!.hasPrefix("zh") {
                result = result == "zh-Hant" ? "zh-Hant" : "en"
            }
        }

        return (result?.lowercased())!
    }

    @objc static var eat_isRightToLeftLayout: Bool {
        return kCurrentLanguage.hasPrefix("ar")
    }

    @objc static var eat_sh_shi: String {
        return sh_shi
    }

    @objc static var eat_sh_fou: String {
        return sh_fou
    }

    @objc static var eat_af_organic: String {
        return af_organic
    }

    @objc static var eat_af_no_organic: String {
        return af_no_organic
    }

    @objc static var eat_udk_app_first_config: String {
        return kUDKAppFirstConfig
    }

    @objc static var eat_udk_app_first: String {
        return kUDKAppFirst
    }

    @objc static var eat_udk_app_url: String {
        return kUDKAppURL
    }

    @objc static var eat_web_terms_url: String {
        return kWebTermsUrl
    }

    @objc static var eat_web_policy_url: String {
        return kWebPolicyUrl
    }
}

// MARK: - Notification

let kNotificationBecomePremium = "kNotificationBecomePremium"
let kNotificationCancelPremium = "kNotificationCancelPremium"
let kNotificationRateBecomePremium = "kNotificationRateBecomePremium"
let kNotificationFirstRemoteParams = "kNotificationFirstRemoteParams"

let kUDKAppURL = "eat_app_url"

let kUDKAppFirstConfig = "eat_app_first_config"
let kUDKAppFirst = "eat_app_first"
let kUDKAppNotFirst = "eat_app_not_first"
let kUDKAppFirstBecomeActive = "eat_app_first_become_active"
let kUDKAppMainPage = "eat_app_main_page"
