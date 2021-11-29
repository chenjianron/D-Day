//
//  RT.swift
//  Camera
//
//  Created by lsc on 16/01/2017.
//  Copyright © 2017 lsc. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(iOSApplicationExtension, unavailable)
public class RT: NSObject {
    
    public typealias RatedCompleted = (_ hasRated: Bool, _ canceled: Bool) -> Void
    
    public static let `default` = RT()
    
    private var _appID: String = ""
    public var appID: String {
        return Preset.named("S.RT.AppID").string ?? _appID
    }
    
    private var action: RatedCompleted?
    private var appEnterBackgroundDate = Date(timeIntervalSince1970: 0)
    private var isUserRTing = false
    
    public var persistentKey = "RT.1" // 记录用户是否评论过的 UserDefault Key
    public var minTime: TimeInterval {
        let param = Preset.named("S.RT.minTime")
        if param != JSON.null {
            return param.doubleValue
        }
        
        return 3
    }
    
    public var isEnabled: Bool = true
    
    public var hasUserRTed: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: persistentKey)
        }
        get {
            return self.isEnabled ? UserDefaults.standard.bool(forKey: persistentKey) : true
        }
    }
    
    public var hasUserRTedCurrentVersion: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: persistentKey+Util.appVersion())
        }
        get {
            return self.isEnabled ? UserDefaults.standard.bool(forKey: persistentKey+Util.appVersion()) : true
        }
    }
    
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    public func setup(appID: String) {
        _appID = appID
    }
    
    // 弹出评论 alert
    // 如果已经评论，则直接回掉 action，除非 force 设为 true
    public func showAlert(from controller: UIViewController, data: JSON, force: Bool = false, action: RatedCompleted? = nil) {
        if self.hasUserRTed && force == false {
            action?(true, false)
            return
        }
        
        self.action = action
        
        let title = data["title"].stringValue
        
        let appName = Util.appName()
        let messageFormat = data["message"].stringValue
        var message = String.init(format: messageFormat, appName, appName, appName, appName, appName)
        message = self.removeNote(text: message)
        
        let ok = data["ok"].stringValue
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancel = data["cancel"].string {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                self.action?(false, true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: { (action) in
            if let link = data["link"].string {
                self.rateApp(link: link)
            }
            else {
                self.rateApp(appID: self.appID)
            }
            self.isUserRTing = true
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    public func showAlert(from controller: UIViewController, dataKey: String, force: Bool = false, action: RatedCompleted? = nil) {
        self.showAlert(from: controller, data: Preset.named(dataKey), force: force, action: action)
    }
    
    public func rateApp(_ action: RatedCompleted? = nil) {
        self.action = action
        self.rateApp(appID: self.appID)
        self.isUserRTing = true
    }
    
    // MARK: - Notification
    
    @objc func appWillEnterForeground(notification: Notification) {
        if self.isUserRTing {
            let leaveTime = Date(timeIntervalSinceNow: 0).timeIntervalSince1970 - self.appEnterBackgroundDate.timeIntervalSince1970
            if leaveTime >= self.minTime {
                self.hasUserRTed = true
                self.postRTedEvent()
                self.action?(true, false)
            } else {
                self.action?(false, false)
            }
            
            self.isUserRTing = false
            self.appEnterBackgroundDate = Date(timeIntervalSince1970: 0)
        }
    }
    
    @objc func appDidEnterBackground(notification: Notification) {
        if self.isUserRTing {
            self.appEnterBackgroundDate = Date()
        }
    }
    
    // MARK: - Private
    
    private func rateApp(appID: String) {
        if let url = URL(string: "https://itunes.apple.com/us/app/id\(appID)?action=write-review") {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func rateApp(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func postRTedEvent() {
        request("http://rt.softinkit.com/rt/rted", method: .post, parameters: [
            "appID": self.appID,
            "countryCode": Util.countryCode()
        ]) { (_, success, _, _) in
            print(#function, success)
        }
    }

    // 移除备注
    // 备注样式如 #Webuff# You’re currently using Premium with a trial period of 7days ...
    private func removeNote(text: String) -> String {
        let range = NSRange.init(location: 0, length: text.count)
        let result = (text as NSString).replacingOccurrences(of: "^#.*?#", with: "", options: .regularExpression, range: range)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
