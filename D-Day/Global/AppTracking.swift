//
//  AppTracking.swift
//  SmartMirro2
//
//  Created by Coloring C on 2021/4/21.
//  Copyright © 2021 Coloring C. All rights reserved.
//

import Foundation
import AdSupport
import AppTrackingTransparency
import Toolkit

class AppTracking: NSObject {
    
    static let event = "AppTrackingTap"
    
    static let shared = AppTracking()
    
    var isAllowedIDFA: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isAllowedIDFA")
        }
        get {
            UserDefaults.standard.register(defaults: ["isAllowedIDFA": false])
            return UserDefaults.standard.bool(forKey: "isAllowedIDFA")
        }
    }
    
    var isRequestedIDFA: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isRequestedIDFA")
        }
        get {
            UserDefaults.standard.register(defaults: ["isRequestedIDFA": false])
            return UserDefaults.standard.bool(forKey: "isRequestedIDFA")
        }
    }
    
    var lastRequestDate: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "lastRequestDate")
        }
        get {
            UserDefaults.standard.register(defaults: ["lastRequestDate": "2020-11-11 11:11:11"])
            return UserDefaults.standard.string(forKey: "lastRequestDate")!
        }
    }
    
    func requestIDFA(complete: @escaping () -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .notDetermined: print("授权不确定")
                    break
                case .restricted: print("授权限制")//系统隐私开关关闭
                    break
                case .denied: print("未授权")
                    if !self.isRequestedIDFA {
                        self.isRequestedIDFA = true
                        MobClick.event(AppTracking.event, label: "首次拒绝授权")
                        self.lastRequestDate = Date().toString()
                    } else {
                        let hour = Preset.named(K.ParamName.IDFA_Time).intValue
                        if hour == 0 {
                            self.secondRequestByCount()
                        } else {
                            self.secondRequesByTime()
                        }
                    }
                    break
                case .authorized: print("已授权")
                    if !self.isAllowedIDFA {
                        self.isAllowedIDFA = true
                        MobClick.event(AppTracking.event, label: "首次更改为授权")
                    }
                    if !self.isRequestedIDFA {
                        self.isRequestedIDFA = true
                        MobClick.event(AppTracking.event, label: "首次授权")
                    }
                    break
                @unknown default:
                    break
                }
                complete()
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("允许授权")
            } else {
                print("拒绝授权")
            }
            complete()
        }
    }
}

// MARK: - 二次权限
extension AppTracking {
    
    func secondRequesByTime() {
        let lastDate = lastRequestDate.toDate()
        let hour = Date().hoursBetweenDate(toDate: lastDate)
        if abs(hour) >= Preset.named(K.ParamName.IDFA_Time).intValue {
            lastRequestDate = Date().toString()
            alert()
        }
    }
    
    func secondRequestByCount() {
        let counter = Counter.find(key: K.ParamName.IDFA_Count)
        counter.increase()
        if counter.hitsMax {
            alert()
            counter.reset()
        }
    }
    
    func alert() {
        let alertVC = UIAlertController(title: __("尚未允许“跟踪”权限"), message: __("为了向您提供更优质、喜欢的服务，我们想访问您的相关权限，需要您的同意。"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: __("取消"), style: .cancel) { (_) in
            MobClick.event(AppTracking.event, label: "二次授权取消")
        }
        let confirmAction = UIAlertAction(title: __("去设置"), style: .default) { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    MobClick.event(AppTracking.event, label: "二次授权去设置")
                }
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(confirmAction)
        Util.topViewController().present(alertVC, animated: true, completion: nil)
    }
}


extension Date {
    
    func toString() -> String {
        let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    func hoursBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour],from: self,to: toDate)
        return components.hour ?? 0
    }
    
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day],from: self,to: toDate)
        return components.day ?? 0
    }
}

extension String {
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)!
    }
}
