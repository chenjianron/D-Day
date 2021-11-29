//
//  Date.swift
//  D-Day
//
//  Created by GC on 2021/10/15.
//

import Foundation

extension Date {
    
    func toStringWithFormat(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: getCurrentLanguage())
        return dateFormatter.string(from: self)
    }
    
    /// a-h:mm
    func toString2() -> String {
        toStringWithFormat("a-h:mm")
    }
    
    /// yyyy-MM-dd
    func toString3() -> String {
        toStringWithFormat("yyyy-MM-dd")
    }
    
    // yyyy-MM
    func toString4() -> String {
        toStringWithFormat("yyyy-MM")
    }
    
    func toDay() -> Date {
        // 去除误差
        let dateFormat = "yyyyMMdd"
        let dateString = toStringWithFormat(dateFormat)
        return dateString.toDateWithFormat(dateFormat)!
    }
    
    func toMonth() -> Date {
        // 去除误差
        let dateFormat = "yyyyMM"
        let dateString = toStringWithFormat(dateFormat)
        return dateString.toDateWithFormat(dateFormat)!
    }
    
    func numberOfDays(to end: Date) -> Int {
        let daysComponents = Calendar.current.dateComponents([.day], from: self.toDay(), to: end.toDay())
        return daysComponents.day ?? 0
    }
}

extension Date{
    
    func getCurrentLanguage() -> String {
       let standard = UserDefaults.standard
       let allLanguages: [String] = standard.object(forKey: "AppleLanguages") as! [String]
       return allLanguages.first ?? "zh-CN"
   }
    
}
