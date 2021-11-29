//
//  RemindManager.swift
//  D-Day
//
//  Created by GC on 2021/10/25.
//

import Toolkit
import Foundation

class RemindManager {
    
    enum Frequency: Int {
        case OnlyTheSameToday = 0
        case BeforeThreeDays = 1
        case BeforeSevenDays = 2
    }
    
    static let `default` = RemindManager()

    lazy var frequencys = [__("当天提醒"), __("提前三天提醒"), __("提前一周提醒")]
//    let defaultSelectTime = "10:00".toDate4()!
    let defaultSelectTime = Date().toString2().toDate4()
//    let defaultSelectTime = "PM-12:00".toDate4()
    let defaultFrequencySelectIndex = Frequency.OnlyTheSameToday.rawValue
    
}

// MARK: 有关提醒的操作
extension RemindManager {
    
    func createRequestIdentifier(index: Int) -> String {
        return UUID().uuidString + ".D-Day" + String(index)
    }
    
    func addLocalRemind(anniversary: AnniversaryModel) {
        // 是否重复
        var repeats: Bool
        // 提醒时间
        var remindDateComponents = Calendar.current.dateComponents([.hour, .minute], from: anniversary.remindDate!)
        // 设置通知内容
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = ""
        notificationContent.badge = 0
        switch Frequency(rawValue: anniversary.remindType!)! {
        case Frequency.OnlyTheSameToday:
            repeats = false
            let anniversaryDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: anniversary.date)
            remindDateComponents.year = anniversaryDateComponents.year
            remindDateComponents.month = anniversaryDateComponents.month
            remindDateComponents.day = anniversaryDateComponents.day
            let identifier = createRequestIdentifier(index: 0)
            notificationContent.body = String(format: __("%@就是今天"), __(anniversary.title))
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: remindDateComponents, repeats: repeats)
            let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(notificationRequest) { error in
                if let error = error {
                    debugPrint("Add remind fail: \(error)")
                } else {
                    debugPrint("1事件通知插入成功")
                }
            }
        case Frequency.BeforeThreeDays:
            repeats = false
            let anniversaryDate = Calendar.current.date(byAdding: .day, value: -1 * 3, to: anniversary.date)!
            let anniversaryDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: anniversaryDate)
            remindDateComponents.year = anniversaryDateComponents.year
            remindDateComponents.month = anniversaryDateComponents.month
            remindDateComponents.day = anniversaryDateComponents.day
            let identifier = createRequestIdentifier(index: 1)
            notificationContent.title = String(format: __("距离%@ 还有%d天"), anniversary.title, 3)
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: remindDateComponents, repeats: repeats)
            let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(notificationRequest) { error in
                if let error = error {
                    debugPrint("Add remind fail: \(error)")
                } else {
                    debugPrint("2事件通知插入成功")
                }
            }
        case Frequency.BeforeSevenDays:
            repeats = false
            let anniversaryDate = Calendar.current.date(byAdding: .day, value: -1 * 7, to: anniversary.date)!
            let anniversaryDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: anniversaryDate)
            remindDateComponents.year = anniversaryDateComponents.year
            remindDateComponents.month = anniversaryDateComponents.month
            remindDateComponents.day = anniversaryDateComponents.day
            let identifier = createRequestIdentifier(index: 2)
            notificationContent.title = String(format: __("距离%@ 还有%d天"), anniversary.title, 7)
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: remindDateComponents, repeats: repeats)
            let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(notificationRequest) { error in
                if let error = error {
                    debugPrint("Add remind fail: \(error)")
                } else {
                    debugPrint("3事件通知插入成功")
                }
            }
        }
    }
    
    func removeLocalRemind(anniversary: AnniversaryModel) {
        if anniversary.remindType != nil {
            var identifiers = [String]()
            switch Frequency(rawValue: anniversary.remindType!)! {
            case Frequency.OnlyTheSameToday:
                identifiers.append(createRequestIdentifier(index: 0))
            case Frequency.BeforeThreeDays:
                identifiers.append(createRequestIdentifier(index: 1))
            case Frequency.BeforeSevenDays:
                identifiers.append(createRequestIdentifier(index: 2))
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}

