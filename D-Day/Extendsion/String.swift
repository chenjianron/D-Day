//
//  String.swift
//  D-Day
//
//  Created by GC on 2021/10/15.
//

import Foundation

extension String {
    
    func toDateWithFormat(_ dateFormat:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: getCurrentLanguage())
        return dateFormatter.date(from: self)
    }
    
    func toDate4() -> Date? {
        toDateWithFormat("a-h:mm")
    }
    
    func toDate1() -> Date? {
        toDateWithFormat("yyyy-MM-dd")
    }
}

extension String {
    
    func getCurrentLanguage() -> String {
       let standard = UserDefaults.standard
       let allLanguages: [String] = standard.object(forKey: "AppleLanguages") as! [String]
       return allLanguages.first ?? "zh-CN"
   }
    
}
