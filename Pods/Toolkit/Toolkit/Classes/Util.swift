//
//  Util.swift
//  Toolkit
//
//  Created by lsc on 27/02/2017.
//

import Foundation
import UIKit
import SwiftyJSON
import LocalAuthentication
import StoreKit

public class Util {
    
    /// 是否有刘海
    @available(iOSApplicationExtension, unavailable)
    public static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }
    
    /// 是否有底部Home区域
    @available(iOSApplicationExtension, unavailable)
    public static var hasBottomSafeAreaInsets: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with home indicator: 34.0 on iPhone X, XS, XS Max, XR.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
        }
        
        return false
    }
    
    /// 安全区
    @available(iOSApplicationExtension, unavailable)
    public static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, tvOS 11.0, *) {
            if let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets {
                return safeAreaInsets
            } else if let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
                return safeAreaInsets
            }
        }
    
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    @available(iOSApplicationExtension, unavailable, message: "This is unavailable: Use view controller based solutions where appropriate instead.")
    public static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    public static func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    public static var shareURL: URL? {
        let appID = RT.default.appID
        assert(!appID.isEmpty, "必须设置 appID 才能调用")
        return URL(string: String(format: "https://itunes.apple.com/cn/app/id%@?mt=8&l=%@", appID, Util.languageCode()))
    }
    
    @available(iOSApplicationExtension, unavailable)
    public static var appStoreURL: URL? {
        let appID = RT.default.appID
        assert(!appID.isEmpty, "必须设置 appID 才能调用")
        return URL(string: String(format: "itms-apps://apple.com/app/id%@", appID))
    }
    
    /// 生成指定前景色图片
    public static func tintImage(source: UIImage, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 0.0)
        let rect = CGRect(x: 0, y: 0, width: source.size.width, height: source.size.height)
        source.draw(in: rect)
        
        color.set()
        UIRectFillUsingBlendMode(rect, .sourceAtop)
        let tintImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintImage
    }

    /// 生成指定大小图像
    public static func resizeImage(image: UIImage, width: CGFloat, height: CGFloat = -1) -> UIImage? {
        if height == -1 {
            let newHeight = width*image.size.height/image.size.width
            UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        } else {
            if height/width > image.size.height/image.size.width {
                let expectedWidth = width*image.size.height/height
                let left = image.size.width/2-expectedWidth/2
                
                UIGraphicsBeginImageContext(CGSize(width: width, height: height))
                
                let cropRegion = CGRect(x: left, y: 0, width: expectedWidth, height: image.size.height)
                if let cgImage = image.cgImage?.cropping(to: cropRegion) {
                    let croppedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: image.imageOrientation)
                    croppedImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            } else {
                let expectedHeight = height*image.size.width/width
                let top = image.size.height/2-expectedHeight/2
                
                UIGraphicsBeginImageContext(CGSize(width: width, height: height))
                
                let cropRegion = CGRect(x: 0, y: top, width: image.size.width, height: expectedHeight)
                if let cgImage = image.cgImage?.cropping(to: cropRegion) {
                    let croppedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: image.imageOrientation)
                    croppedImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                }
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    /// 根据文件大小返回可读的字符串
    public static func formattedSize(size: UInt) -> String {
        let kb = Double(size) / 1000.0
        let mb = Double(size) / 1000.0 / 1000.0
        let gb = Double(size) / 1000.0 / 1000.0 / 1000.0
        
        if gb > 1.0 {
            return String(format: "%.1lfG", gb)
        }
        
        if mb > 1.0 {
            return String(format: "%.1lfM", mb)
        }
        
        if kb > 1.0 {
            return String(format: "%.1lfK", kb)
        }
        
        return "0K"
    }

    /// 返回格式化的时间字符串
    public static func formattedTime(from time: Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// 返回最顶层的 view controller
    @available(iOSApplicationExtension, unavailable)
    public static func topViewControllerOptional() -> UIViewController? {
        var keyWinwow = UIApplication.shared.keyWindow
        if keyWinwow == nil {
            keyWinwow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        }
        if #available(iOS 13.0, *), keyWinwow == nil {
            keyWinwow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        }
        
        var top = keyWinwow?.rootViewController
        if top == nil {
            top = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        
        return top
    }
    
    @available(iOSApplicationExtension, unavailable)
    public static func topViewController() -> UIViewController {
        return topViewControllerOptional()!
    }

    /// 返回本地化的app名称
    public static func appName() -> String {
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else {
            return Bundle.main.infoDictionary?["CFBundleName"] as! String
        }
    }
    
    /// 返回版本号
    public static func appVersion() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    public static func buildNumber() -> String {
        return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""
    }

    /// 自定义 UINavigationbar 返回按钮
    public static func customNavigationBarBackIndicator(navigationItem: UINavigationItem, navigationBar: UINavigationBar?, image: UIImage) {
        let backButtonItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        if let navigationBar = navigationBar {
            navigationBar.backIndicatorTransitionMaskImage = image
            navigationBar.backIndicatorImage = image
        }
    }

    /// 检测合法 URL
    public static func isUrlValid(_ text: String) -> Bool {
        let reg = "((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        
        let urlTest = NSPredicate(format: "SELF MATCHES %@", reg)
        
        return urlTest.evaluate(with: text)
    }
    
    /// 检测合法 schemed URL
    public static func isUrlReachable(string urlString: String) -> Bool {
        
        if let url = URL(string: urlString), let _ = url.scheme, let _ = url.host {
            return true
        }
        
        return false
    }

    /// 返回合法的URL
    public static func formatURL(_ string: String, withPrefix prefix: String) -> String {
        
        var urlString = string
        
        let httpRange = string.range(of: "http://")
        let httpsRange = string.range(of: "https://")
        
        if httpRange != nil {
            urlString.removeSubrange(httpRange!)
        } else if httpsRange != nil {
            urlString.removeSubrange(httpsRange!)
        }
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        
        urlString = "\(prefix)\(urlString)"
        
        return urlString
    }

    /// 移动文件
    public static func moveFile(from source: URL, to target: URL) {
        if FileManager.default.fileExists(atPath: source.absoluteString) == false {
            LLog("Souce file does't exist")
            return
        }
        
        if FileManager.default.fileExists(atPath: target.absoluteString) == false {
            LLog("Target file does't exist")
            return
        }
        
        do {
            try FileManager.default.moveItem(at: source, to: target)
        } catch {
            LLog(error)
        }
    }
    
    public static func countryCode() -> String {
        return NSLocale.current.regionCode ?? ""
    }
    
    public static func languageCode() -> String {
        let languageCode = NSLocale.preferredLanguages.first ?? ""
        
        if languageCode.starts(with: "zh-HK") {
            return "zh-Hant"
        }
        
        var components = languageCode.split(separator: "-")
        if components.count >= 2, let suffix = components.last, suffix == suffix.uppercased() { // 如 pt-PT、pt-BR 则输出 pt
            components.removeLast()
            return components.joined(separator: "-")
        }
        
        return languageCode
    }
    
    /// JSON
    public static func parseJSON(rawValue: Any?, localized: Bool = true) -> JSON {
        return Preset.default.parseJSON(rawValue: rawValue, localized: localized)
    }
    
    public static func localizedJSON(_ json: JSON) -> JSON {
        return Preset.default.localizedJSON(json)
    }
    
    // MARK: - Touch ID
    
    /// 设备是否支持Touch ID
    public static func isTouchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError? = nil
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if error?.code == LAError.touchIDNotAvailable.rawValue {
            return false
        }
        
        return true
    }
    
    /// 设备是否已登记Touch ID（打开了Passcode 且 设置了Touch ID）
    public static func isTouchIDEnrolled() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    // MARK: - Path
    
    /// 连接路径
    public static func join(component: String...) -> String {
        let components = component
        var result: NSString = ""
        for c in components {
            if result.length == 0 {
                result = c as NSString
            }
            else {
                result = result.appendingPathComponent(c) as NSString
            }
        }
        
        return result as String
    }
    
    public static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    public static var libraryPath: String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }
    
    public static var cachesPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    public static var moduleName: String? {
        var str = NSStringFromClass(Util.self) as? String
        return str?.components(separatedBy: ".").first
    }
}

public extension Util {
    static let pixelOne: CGFloat = {
        return 1 / UIScreen.main.scale
    }()
    
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }()
    
    static let isIPad: Bool = {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }()
    
    @available(iOSApplicationExtension, unavailable)
    static let isZoomedMode: Bool = {
        if isIPad {
            return false
        }
        let nativeScale = UIScreen.main.nativeScale
        var scale = UIScreen.main.scale
        
        let shouldBeDownsampledDevice = UIScreen.main.nativeBounds.size.equalTo(CGSize(width: 1080, height: 1920))
        if shouldBeDownsampledDevice {
            scale /= 1.15;
        }
        return nativeScale > scale
    }()
    
    @available(iOSApplicationExtension, unavailable)
    static let isRegularScreen: Bool = {
        return isIPad || (!isZoomedMode && (is61InchScreen || is61InchScreen || is55InchScreen))
    }()
    
    /// 是否横竖屏，用户界面横屏了才会返回true
    @available(iOSApplicationExtension, unavailable)
    static var isLandscape: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    /// 屏幕宽度，跟横竖屏无关
    @available(iOSApplicationExtension, unavailable)
    static let deviceWidth = isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width

    /// 屏幕高度，跟横竖屏无关
    @available(iOSApplicationExtension, unavailable)
    static let deviceHeight = isLandscape ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
    
    /// tabbar  高度
    @available(iOSApplicationExtension, unavailable)
    static var tabBarHeight: CGFloat {
        if isIPad {
            if hasBottomSafeAreaInsets {
                return 65
            } else {
                if #available(iOS 12.0, *) {
                    return 50
                } else {
                    return 49
                }
            }
        } else {
            let height: CGFloat
            if isLandscape, !isRegularScreen {
                height = 32
            } else {
                height = 49
            }
            return height + safeAreaInsets.bottom
        }
    }
    
}

@available(iOSApplicationExtension, unavailable)
public extension Util {
    static let is65InchScreen: Bool = {
        if CGSize(width: deviceWidth, height: deviceHeight) != screenSizeFor65Inch {
            return false
        }
        let deviceModel = Util.deviceModel()
        if deviceModel != "iPhone11,4" && deviceModel == "iPhone11,6" && deviceModel != "iPhone12,5" {
            return false
        }
        return true
    }()
    
    static let is61InchScreen: Bool = {
        if CGSize(width: deviceWidth, height: deviceHeight) != screenSizeFor61Inch {
            return false
        }
        let deviceModel = Util.deviceModel()
        if deviceModel != "iPhone11,8" && deviceModel == "iPhone12,1" {
            return false
        }
        return true
    }()
    
    static let is58InchScreen: Bool = {
        return CGSize(width: deviceWidth, height: deviceHeight) == screenSizeFor58Inch
    }()
    
    static let is55InchScreen: Bool = {
        return CGSize(width: deviceWidth, height: deviceHeight) == screenSizeFor55Inch
    }()
    
    static let is47InchScreen: Bool = {
        return CGSize(width: deviceWidth, height: deviceHeight) == screenSizeFor47Inch
    }()
    
    static let is40InchScreen: Bool = {
        return CGSize(width: deviceWidth, height: deviceHeight) == screenSizeFor40Inch
    }()
    
    static var is35InchScreen: Bool {
        return CGSize(width: deviceWidth, height: deviceHeight) == screenSizeFor35Inch
    }
    
    static var screenSizeFor65Inch: CGSize {
        return CGSize(width: 414, height: 896)
    }
    
    static var screenSizeFor61Inch: CGSize {
        return CGSize(width: 414, height: 896)
    }

    static var screenSizeFor58Inch: CGSize {
        return CGSize(width: 375, height: 812)
    }

    static var screenSizeFor55Inch: CGSize {
        return CGSize(width: 414, height: 736)
    }

    static var screenSizeFor47Inch: CGSize {
        return CGSize(width: 375, height: 667)
    }
    
    static var screenSizeFor40Inch: CGSize {
        return CGSize(width: 320, height: 568)
    }

    static var screenSizeFor35Inch: CGSize {
        return CGSize(width: 320, height: 480)
    }

}
