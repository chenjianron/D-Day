//
//  MarkitingLocalPush.swift
//  Toolkit
//
//  Created by Kenji on 3/9/21.
//

import UIKit

enum MarketingLocalPushType: CaseIterable {
    case nextDay
    case sevenDays
    case thirtyDays
    
    var identifier: String {
        switch self {
        case .nextDay:
            return "nextDayAfterFirstLaunched"
        case .sevenDays:
            return "sevenDaysNotLaunched"
        case .thirtyDays:
            return "thirtyDaysTimeInterval"
        }
    }
}

@available(iOS 10.0, *)
open class MarkitingLocalPush: NSObject {
    
    let onlineIdentifier = "S.Ad.运营本地推送"
    
    public static let `default` = MarkitingLocalPush()
    
    public static  var firstLaunchDate: Date? {
        get {
            return UserDefaults.standard.value(forKey: "FirstLaunchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FirstLaunchDate")
        }
    }
    
    public override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupLocalPush), name: JSONUpdatedNotification, object: nil)
    }
    
    public static func localPushNotification() {
        let localPush = MarkitingLocalPush.default
        localPush.setupLocalPush()
    }
    
    @objc func setupLocalPush() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
            guard let self = self else { return }
            
            if granted {
                if MarkitingLocalPush.firstLaunchDate == nil {
                    MarkitingLocalPush.firstLaunchDate = Date()
                }
                
                let json = Preset.named(self.onlineIdentifier)
                let localPush = MarkitingLocalPush.default
                
                for type in MarketingLocalPushType.allCases {
                    localPush.cancelNotification(type: type)
                }
                
                if json["sevenDayPush"].boolValue {
                    localPush.addLocalPushNotification(type: .sevenDays)
                } else {
                    localPush.cancelNotification(type: .sevenDays)
                }
                if json["thirtyDayPush"].boolValue {
                    localPush.addLocalPushNotification(type: .thirtyDays)
                } else {
                    localPush.cancelNotification(type: .thirtyDays)
                }
                if json["nextDayPush"].boolValue {
                    localPush.addLocalPushNotification(type: .nextDay)
                } else {
                    localPush.cancelNotification(type: .nextDay)
                }
            } else {
                LLog("🔥 关闭了通知")
            }
        }
    }
    
    func addLocalPushNotification(type: MarketingLocalPushType) {
        
        let json = Preset.named(onlineIdentifier)[type.identifier]
        
        var trigger: UNNotificationTrigger
        switch type {
        case .nextDay:
            guard let date = MarkitingLocalPush.firstLaunchDate else { return }
            
            guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return }
            var dateComponents: DateComponents = DateComponents()
            let nextDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
            dateComponents.year = nextDateComponents.year
            dateComponents.month = nextDateComponents.month
            dateComponents.day = nextDateComponents.day
            dateComponents.hour = json["hour"].int ?? 21
            dateComponents.minute = json["minute"].int ?? 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .sevenDays:
            guard let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
            var dateComponents = DateComponents()
            dateComponents.weekday = Calendar.current.dateComponents([.weekday], from: lastDay).weekday
            dateComponents.hour = json["hour"].int ?? 21
            dateComponents.minute = json["minute"].int ?? 0
            
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true)
        case .thirtyDays:
            var dateComponents = DateComponents()
            dateComponents.day = json["day"].int ?? 1
            dateComponents.hour = json["hour"].int ?? 22
            dateComponents.minute = json["minute"].int ?? 0
            
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true)
        }
        
        let content = UNMutableNotificationContent()
        content.title = Util.localizedJSON(json["title"]).stringValue
        content.body = Util.localizedJSON(json["content"]).stringValue
        content.badge = 0
        
        let request = UNNotificationRequest(identifier: type.identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                LLog(error)
            } else {
                LLog("""
                        运营通知插入成功:
                        title: \(content.title)
                        body:  \(content.body)
                        dateComponents: \(String(describing: (trigger as? UNCalendarNotificationTrigger)?.dateComponents))
                        type: \(type.identifier)
                        """)
            }
        }
        
    }

    func cancelNotification(type: MarketingLocalPushType) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [type.identifier])
    }
}
