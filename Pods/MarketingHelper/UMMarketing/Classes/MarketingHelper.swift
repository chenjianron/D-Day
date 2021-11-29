//
//  MarketingHelper.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/8/20.
//

import Foundation
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKit) // DCG
import DCGKit
#endif

public final class MarketingHelper {
    /// 打印开关，只在 Debug 模式有效
    static public var logEnable = false
    
    static let shared = MarketingHelper()
    
    /// 系统通知弹窗封装，超过预定时长后弹出 alert 提醒开启通知，默认 14 天
    static public func setupNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        STHelper.registerForRemoteNotifications(launchOptions: launchOptions) { (granted, error) in
            DLog("推送开关: ", granted)
            if let error = error {
                DLog(error.localizedDescription)
            }

            self.handleRegisterRemoteNotification(granted: granted)
        }
        
        NotificationCenter.default.addObserver(shared, selector: #selector(jsonUpdated), name: JSONUpdatedNotification, object: nil)
    }
    
    /// 通知弹窗间隔天数
    static private var offsetDay: Int {
        let day = Preset.named("S.AD.通知间隔").intValue
        if day > 0 {
            return day
        } else {
            return 14
        }
    }
    
    private static func handleRegisterRemoteNotification(granted: Bool) {
        let lastRegisterDateKey = "com.ummarketing.lastRegisterDate"
        
        if granted {
            UserDefaults.standard.set(nil, forKey: lastRegisterDateKey)
            return
        }
        let seconds = UserDefaults.standard.double(forKey: lastRegisterDateKey)
        
        if seconds <= 0 {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastRegisterDateKey)
            return
        }
        
        let hitMax = Date().timeIntervalSince1970 - seconds > Double(offsetDay * 60 * 60 * 24)
        
        if hitMax {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastRegisterDateKey)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.presentSettingNotificationAlert()
            })
        }
    }
    
    private static func presentSettingNotificationAlert() {
        let alert = UIAlertController(title: __("您还没有开启消息通知"),
                                      message: __("“通知”可能包括提醒、声音和图标标记。这些可在“设置”中配置。"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: __("稍后再说"), style: .default, handler: nil))
        let openAction = UIAlertAction(title: __("立即设置"), style: .default, handler: { (_) in
            Util.openSettings()
        })
        alert.addAction(openAction)
        alert.preferredAction = openAction
        Util.topViewController().present(alert, animated: true)
    }
}

extension MarketingHelper {
    @objc func jsonUpdated() {
        UpdateAppAlertController.prefetchImage()
        MarketingAlertController.prefetchImage()
    }
}

extension MarketingHelper {
    @discardableResult
    static public func presentUpdateAlert() -> Bool {
        return UpdateAppAlertController.presentIfNeed()
    }
    
    @discardableResult
    static public func presentMarketingAlert() -> Bool {
        return MarketingAlertController.presentIfNeed()
    }
}
