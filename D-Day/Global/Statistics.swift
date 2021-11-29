//
//  Statistics.swift
//  Smart Mirror
//
//  Created by Kevin on 2020/3/17.
//  Copyright © 2020 SOFTIN. All rights reserved.
//

import Foundation
import AdLib
import MarketingHelper
import Toolkit

class Statistics {
    
    private static var currentPage: String?
    
    static func beginLogPageView(_ name: String) {
        
        if currentPage == name { return }
        currentPage = name
        MobClick.beginLogPageView(name)
        
        #if DEBUG
        print(#function, "页面路径 \(name)")
        #endif
    }
    
    static func endLogPageView(_ name: String) {
        if currentPage != name { return }
        MobClick.endLogPageView(name)
    }
    
    enum Event: String {
        case
        HomePageTap, //首页点击计数
        SettingsTap, //设置页点击计数
        ReviewTap, //预览页点击计数
        EditTap,
        CalendarTap,
        PasswordTap
    }
    
    static func event(_ event: Event, label: String){
        MobClick.event(event.rawValue, label: label)
        #if DEBUG
        print(#function, "事件 \(event.rawValue) - \(label)")
        #endif
    }
}
