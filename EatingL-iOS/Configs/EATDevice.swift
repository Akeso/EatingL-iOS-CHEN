//
//  EATDevice.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import AdSupport
import AppTrackingTransparency
import NetworkExtension
import Reachability
import UIKit

// MARK: - User ID
class EATDevice: NSObject {

    @objc private static let kUDKDeviceId = "UDKDeviceId"
    @objc private static let kUDKUUID = "UDKUUID"
    @objc private static let kUDKAnonymousUserId = "UDKAnonymousUserId"

    @objc private static let kUDKKCService = "UDKKCService"
    @objc private static let kUDKKCAnonymousUserId = "UDKKCAnonymousUserId"

    @objc private static let info = Bundle.main.infoDictionary
}

// MARK: - 应用信息
extension EATDevice {

    @objc static var eat_appName: String {
        if let name = info?["CFBundleDisplayName"] as? String, !name.isEmpty {
            return name
        }
        return info?["CFBundleName"] as? String ?? kAppName
    }

    @objc static var eat_appVersion: String {
        return info?["CFBundleShortVersionString"] as? String ?? ""
    }

    @objc static var eat_appIcon: UIImage? {
        let icons = info?["CFBundleIcons"] as? [String: Any]
        let primaryIcons = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        let iconFiles = primaryIcons?["CFBundleIconFiles"] as? [Any]
        let icon = iconFiles?.last as? String
        return UIImage(named: icon ?? "")
    }
}

// MARK: - 用户 ID
extension EATDevice {

    @objc static var eat_idfaString: String {
        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }

        return ""
    }

    @objc static var eat_idfvString: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    @objc static var eat_anonymousUserId: String {
        if let anonymousUserId = EATKCHelper.eat_getUserId(key: kUDKKCAnonymousUserId), !anonymousUserId.isEmpty {
            print("keychain anonymousUserId = \(anonymousUserId)")
            return anonymousUserId
        }

        if let anonymousUserId = UserDefaults.standard.string(forKey: kUDKAnonymousUserId), !anonymousUserId.isEmpty {
            print("user anonymousUserId = \(anonymousUserId)")
            EATKCHelper.eat_saveUserId(key: kUDKKCAnonymousUserId, value: anonymousUserId)
            return anonymousUserId
        }

        let anonymousUserId = "\(Bundle.main.bundleIdentifier!)_\(eat_deviceID.eat_apiMd5())".eat_apiMd5()

        EATKCHelper.eat_saveUserId(key: kUDKKCAnonymousUserId, value: anonymousUserId)

        return anonymousUserId
    }

    // 通过 anoymousUserId 转成 UUID
    @objc static var eat_anoymousUserIdUUID: UUID {
        let data = eat_anonymousUserId.eat_apiHexData()

        var bytes = [UInt8](data)

        // 设置版本号：Version 4 (随机型 UUID)
        bytes[6] = (bytes[6] & 0x0F) | 0x40

        // 设置变体位：RFC 4122 (10xx xxxx)
        bytes[8] = (bytes[8] & 0x3F) | 0x80

        return NSUUID(uuidBytes: bytes) as UUID
    }

    @objc private static var eat_genarateUUIDString: String {
        if let uuid = UserDefaults.standard.string(forKey: kUDKUUID), !uuid.isEmpty {
            return uuid
        }

        let uuid = NSUUID().uuidString
        UserDefaults.standard.set(uuid, forKey: kUDKUUID)

        return uuid
    }

    @objc private static var eat_deviceUUID: String {
        let name: String = UIDevice.current.name
        let sys_name: String = UIDevice.current.systemName
        let sys_ver: String = UIDevice.current.systemVersion
        let model: String = UIDevice.current.model
        let local_model: String = UIDevice.current.localizedModel
        let country: String = NSLocale.current.identifier
        let language: String = NSLocale.preferredLanguages.first ?? ""

        return "\(name)_\(sys_name)_\(sys_ver)_\(model)_\(local_model)_\(country)_\(language)_\(eat_genarateUUIDString)"
    }

    @objc private static var eat_deviceID: String {
        if let deviceId = UserDefaults.standard.string(forKey: kUDKDeviceId),
           !deviceId.isEmpty {
            return deviceId
        }

        let deviceId = eat_deviceUUID.eat_apiMd5()
        UserDefaults.standard.set(deviceId, forKey: kUDKDeviceId)

        return deviceId
    }
}

// MARK: - 各种高度
extension EATDevice {

    /// 实际状态栏高度
    @objc public static var eat_statusBarHeight: CGFloat {
        guard let statusBarManager = eat_window?.windowScene?.statusBarManager else {
            return 0
        }
        return statusBarManager.statusBarFrame.height
    }

    /// 实际下巴高度
    public static var eat_homeIndicatorHeight: CGFloat {
        guard let keyWindow = eat_window else {
            return 0.0
        }
        return keyWindow.safeAreaInsets.bottom
    }

    public static var eat_screenScale: CGFloat {
        return UIScreen.main.scale
    }

    public static var eat_screenScaleInt: Int {
        return Int(UIScreen.main.scale)
    }

    /// 适配下巴高度
    @objc static var eat_XBottomSpace: CGFloat {
        if eat_isXSeries {
            return eat_homeIndicatorHeight
        } else {
            return 13.0
        }
    }

    /// 无下巴 Tab 高度
    @objc static var eat_tabHeight: CGFloat {
        return 74
    }

    /// 有下巴 Tab 高度
    @objc static var eat_tabBarHeight: CGFloat {
        return eat_XBottomSpace+eat_tabHeight
    }
}

// MARK: - Window
extension EATDevice {

    @objc private static var eat_window: UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }

        if let window = UIApplication.shared.eat_window {
            return window
        }

        return nil
    }
}

// MARK: - 机型
extension EATDevice {

    @objc static var eat_isSE: Bool {
        return SCREEN_HEIGHT == 480 || SCREEN_HEIGHT == 568
    }

    @objc static var eat_is8: Bool {
        return SCREEN_HEIGHT == 667
    }

    @objc static var eat_is8P: Bool {
        return SCREEN_HEIGHT == 736
    }

    @objc static var eat_isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    /// 当前设备是否是 touch
    @objc static var eat_isTouch: Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        return UIDevice.current.model == "iPod touch"
    }

    /// 当前设备是否是手机
    @objc static var eat_isPhone: Bool {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return false
        }
        return UIDevice.current.model == "iPhone"
    }

    /// 当前设备是否是模拟器
    @objc static var eat_isSimulator: Bool {
        var isSim = false
#if arch(i386) || arch(x86_64)
        isSim = true
#endif
        return isSim
    }

    /// 当前设备是否是模拟器
    @objc static var eat_isSimulatorEnvironment: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    public static var eat_isXSeries: Bool {
        guard let keyWindow = eat_window else {
            return false
        }
        return keyWindow.safeAreaInsets.bottom > 0
    }

    @objc static var eat_isLargeScreen: Bool {
        return SCREEN_WIDTH > 375
    }

    @objc static var eat_isSmallScreen: Bool {
        return SCREEN_HEIGHT < 812
    }

    // 896 <= 11 pro max
    @objc static var eat_isProMaxScreen: Bool {
        return SCREEN_HEIGHT > 896 && !eat_isPad
    }

    @objc static var eat_isNotSmallSreen: Bool {
        if !eat_isLargeScreen && eat_isSmallScreen {
            return false
        }

        return true
    }
}

// MARK: - 状态
extension EATDevice {

    /// 判断设备是否在充电
    @objc static var eat_isCharging: Bool {
        UIDevice.current.isBatteryMonitoringEnabled = true
        // 充电或满电都表示在充电
        return UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
    }

    /// 当前手机电量
    @objc static var eat_batteryLevel: Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }

    /// 判断VPN是否打开
    @objc static var eat_isVPNOn: Bool {

        guard let cfDict = CFNetworkCopySystemProxySettings() else {
            return false
        }

        let nsDict = cfDict.takeRetainedValue() as NSDictionary

        guard let keys = nsDict["__SCOPED__"] as? [String: Any] else {
            return false
        }

        let keyValues: [String] = [
            "tap",
            "tun",
            "ppp",
            "ipsec",
            "ipsec0"
        ]

        var result: Bool = false
        for key in keys.keys {
            keyValues.forEach { (value) in
                if key.contains(value) {
                    result = true
                }
            }
        }

        return result
    }

    /// 判断当前设备是否使用 wifi
    @objc static var eat_isWifi: Bool {
        guard let reachability = try? Reachability() else {
            return false
        }
        return reachability.connection == .wifi
    }

    /// 判断当前设备是否使用流量
    @objc static var eat_isCellular: Bool {
        guard let reachability = try? Reachability() else {
            return false
        }
        return reachability.connection == .cellular
    }

    /// 判断当前设备是否联网
    @objc static var eat_isNetworkAvailable: Bool {
        guard let reachability = try? Reachability() else {
            return false
        }
        return reachability.connection != .unavailable
    }
}

// MARK: - 硬件信息
extension EATDevice {

    /// 用户设置的手机昵称
    @objc static var eat_nickName: String {
        return UIDevice.current.name
    }

    /// 设备名称
    @objc static var eat_deviceName: String {
        print("model name \(UIDevice.current.modelName)")
        return UIDevice.current.modelName
    }

    /// 设备类型
    @objc static var eat_deviceType: String {
        if self.eat_isPad {
            return "iPad"
        } else if self.eat_isPhone {
            return "iPhone"
        } else if self.eat_isTouch {
            return "iPod touch"
        }

        return ""
    }

    /// 设备系统名称
    @objc static var eat_systemName: String {
        return UIDevice.current.systemName
    }

    /// 系统版本号
    @objc static var eat_systemVersion: String {
        return UIDevice.current.systemVersion
    }

    @objc static var eat_batteryCapacity: Int {
        return UIDevice.current.batteryCapacity
    }
}

extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { (identifier, element) -> String in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        let dict: [String: String] = [
            "i386": "Simulator",
            "x86_64": "Simulator",
            "iPhone1,1": "iPhone 2G",
            "iPhone1,2": "iPhone 3G",
            "iPhone2,1": "iPhone 3GS",
            "iPhone3,1": "iPhone 4",
            "iPhone3,2": "iPhone 4",
            "iPhone3,3": "iPhone 4",
            "iPhone4,1": "iPhone 4S",
            "iPhone5,1": "iPhone 5",
            "iPhone5,2": "iPhone 5",
            "iPhone5,3": "iPhone 5c",
            "iPhone5,4": "iPhone 5c",
            "iPhone6,1": "iPhone 5s",
            "iPhone6,2": "iPhone 5s",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone7,2": "iPhone 6",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE",
            "iPhone9,1": "iPhone 7",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone12,8": "iPhone SE2",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13"
        ]
        return dict[identifier] ?? identifier
    }

    var batteryCapacity: Int {

        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { (identifier, element) -> String in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        let dict: [String: Int] = [
            "i386": 0,
            "x86_64": 0,
            "iPhone4,1": 1420,
            "iPhone4,2": 1420,
            "iPhone4,3": 1420,
            "iPhone5,1": 1440,
            "iPhone5,2": 1440,
            "iPhone5,3": 1480,
            "iPhone5,4": 1480,
            "iPhone6,1": 1550,
            "iPhone6,2": 1550,
            "iPhone7,1": 2915,
            "iPhone7,2": 1821,
            "iPhone8,1": 1821,
            "iPhone8,2": 2750,
            "iPhone8,4": 1624,
            "iPhone9,1": 1821,
            "iPhone9,2": 2900,
            "iPhone10,1": 1821,
            "iPhone10,4": 1821,
            "iPhone10,2": 2675,
            "iPhone10,5": 2675,
            "iPhone10,3": 2716,
            "iPhone10,6": 2716,
            "iPhone11,8": 2942,
            "iPhone11,2": 2658,
            "iPhone11,4": 3174,
            "iPhone11,6": 3174,
            "iPhone12,1": 3110,
            "iPhone12,3": 3190,
            "iPhone12,5": 3969,
            "iPhone12,8": 1821,
            "iPhone13,1": 2227,
            "iPhone13,2": 2815,
            "iPhone13,3": 2815,
            "iPhone13,4": 3687,
            "iPhone14,2": 3095,
            "iPhone14,3": 4352,
            "iPhone14,4": 2406,
            "iPhone14,5": 3227,
            "iPhone14,6": 2018,
            "iPhone14,7": 3279,
            "iPhone14,8": 4325,
            "iPhone15,2": 3200,
            "iPhone15,3": 4323,
            "iPhone15,4": 3349,
            "iPhone15,5": 4383,
            "iPhone16,1": 3274,
            "iPhone16,2": 4422,

            // iPad
            "iPad1,1": 6613,
            "iPad2,1": 6944,
            "iPad2,2": 6944,
            "iPad2,3": 6944,
            "iPad2,4": 6944,
            "iPad3,1": 11560,
            "iPad3,2": 11560,
            "iPad3,3": 11560,
            "iPad3,4": 11560,
            "iPad3,5": 11560,
            "iPad3,6": 11560,
            "iPad6,11": 8827,
            "iPad6,12": 8827,
            "iPad7,5": 8594,
            "iPad7,6": 8594,
            "iPad7,11": 8594,
            "iPad7,12": 8594,
            "iPad11,6": 8594,
            "iPad11,7": 8594,

            // iPad Air
            "iPad4,1": 8827,
            "iPad4,2": 8827,
            "iPad4,3": 8827,
            "iPad5,3": 7340,
            "iPad5,4": 7340,
            "iPad11,3": 8162,
            "iPad11,4": 8162,
            "iPad13,1": 7796,
            "iPad13,2": 7796,

             // iPad mini
            "iPad2,5": 4440,
            "iPad2,6": 4440,
            "iPad2,7": 4440,
            "iPad4,4": 6471,
            "iPad4,5": 6471,
            "iPad4,6": 6471,
            "iPad4,7": 6471,
            "iPad4,8": 6471,
            "iPad4,9": 6471,
            "iPad5,1": 5124,
            "iPad5,2": 5124,
            "iPad11,1": 5124,
            "iPad11,2": 5124,

            // iPad Pro
            "iPad6,3": 7306,
            "iPad6,4": 7306,
            "iPad7,3": 8134,
            "iPad7,4": 8134,
            "iPad8,1": 7812,
            "iPad8,2": 7812,
            "iPad8,3": 7812,
            "iPad8,4": 7812,
            "iPad8,9": 7599,
            "iPad8,10": 7599,
            "iPad13,4": 7599,
            "iPad13,5": 7599,
            "iPad13,6": 7599,
            "iPad13,7": 7599,
            "iPad6,7": 10307,
            "iPad6,8": 10307,
            "iPad7,1": 10875,
            "iPad7,2": 10875,
            "iPad8,5": 9720,
            "iPad8,6": 9720,
            "iPad8,7": 9720,
            "iPad8,8": 9720,
            "iPad8,11": 9763,
            "iPad8,12": 9763,
            "iPad13,8": 10872,
            "iPad13,9": 10872,
            "iPad13,10": 10872,
            "iPad13,11": 10872
        ]

        return dict[identifier] ?? 0
    }
}

extension EATDevice {

    static func eat_gotoSetting() {
        guard let URL = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
    }
}
