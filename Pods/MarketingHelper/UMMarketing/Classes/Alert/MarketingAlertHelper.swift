//
//  MarketingAlertHelper.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/9/19.
//

import Foundation
import SwiftyJSON
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKit) // DCG
import DCGKit
#endif

enum AlertType: String {
    case updateApp
    case activity
    
    var defaultLaunchTimes: Int {
        switch self {
        case .updateApp:
            return 4
        case .activity:
            return 4
        }
    }
    
    var defaultMaxShownTimes: Int {
        switch self {
        case .updateApp:
            return 3
        case .activity:
            return 3
        }
    }
    
    var defaultIntervalDay: Int {
        switch self {
        case .updateApp:
            return 3
        case .activity:
            return 1
        }
    }
}

class MarketingAlertHelper {
    
    let launchTimesKey: String
    let maxShownTimesKey: String
    let lastShownDateKey: String
    
    let json: JSON
    
    let alertType: AlertType
    init(alertType: AlertType, json: JSON) {
        self.json = json
        self.alertType = alertType
        launchTimesKey = "com.ummarketing.launchTimes." + alertType.rawValue
        maxShownTimesKey = "com.ummarketing.maxShownTimesKey." + alertType.rawValue + "." + Util.appVersion()
        lastShownDateKey = "com.ummarketing.lastShownDateKey." + alertType.rawValue
        
    }
    
    func detectShouldPresentAlert() -> Bool {
        if launchTimesMeet() == false {
            LLog("启动次数不达标")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: launchTimesKey) + 1, forKey: launchTimesKey)
            return false
        }
        if daysIntervalMeet() == false {
            LLog("启动时间间隔不达标")
            return false
        }
        if maxShownTimesMeet() == false {
            LLog("已超过最大显示次数")
            return false
        }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastShownDateKey)
        UserDefaults.standard.set(0, forKey: launchTimesKey)
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: maxShownTimesKey) + 1, forKey: maxShownTimesKey)
        return true
    }
    
    /// 启动次数符合要求
    private func launchTimesMeet() -> Bool {
        var launchTimes = UserDefaults.standard.integer(forKey: launchTimesKey)
        launchTimes += 1
        let target = json["launchTimes"].intValue
        if target == 0 {
            return false
        }
        return launchTimes >= target
    }
    
    /// 天数间隔符合要求
    private func daysIntervalMeet() -> Bool {
        let lastDateInterval = UserDefaults.standard.double(forKey: lastShownDateKey)
        let days = json["daysInterval"].int ?? alertType.defaultIntervalDay
        #if DEBUG
        return Date().timeIntervalSince1970 - lastDateInterval > Double(days) * 10
        #else
        return Date().timeIntervalSince1970 - lastDateInterval > Double(days) * 86400
        #endif
    }
    
    /// 最多显示次数符合要求
    private func maxShownTimesMeet() -> Bool {
        let maxShownTimes = UserDefaults.standard.integer(forKey: maxShownTimesKey)
        return maxShownTimes < json["maxShownTimes"].int ?? alertType.defaultMaxShownTimes
    }
    
}
