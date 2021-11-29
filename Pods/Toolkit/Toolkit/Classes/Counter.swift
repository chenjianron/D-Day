//
//  Counter.swift
//  
//  计数器
//
//  Created by Kevin on 01/04/2017.
//  Copyright © 2017 Kevin. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
1. 简单计数器，实现“每n次计数后触发”
     let counter = Counter.find("p1-1") // p1-1在线参数值为整数 n
     counter.increase()
     if counter.hitsMax {
        work()
        counter.reset()
     }
 
 2. 实现“间隔10小时才能重新触发”逻辑
    if counter.hitsMax {
        work()
        counter.reset()
        counter.pausedUntilDate = Date().addingTimeInterval(10 * 60 * 60)
    }
 
 3. 通过参数实现“n次计数后触发，每触发m次后暂停h小时”逻辑
    let counter = Counter.find("p1-1") // p1-1在线参数值为JSON { "maxTimes": n, "pauseHitTimes": m, "pauseHours": h }
 
 4. 使用本地参数(不使用在线参数)配置counter
    let counter = Counter.find("a key") // 注意key避免与在线参数key(如p1-1)重复
    counter.cacheParams(2)
    或
    counter.cacheParams([
        Counter.ParamsKey.maxTimes.rawValue: 3,
        Counter.ParamsKey.pauseHitTimes.rawValue: 2,
        Counter.ParamsKey.pauseHours.rawValue: 1.0/60/60*30 // 30s
    ])
 */

public class Counter: NSObject {

    public static var isEnabled = true
    
    // 持久化属性
    public var pausedUntilDate = Date.distantPast { // 暂停触发直到某个时间，用于实现“间隔n小时/天后才能重新触发”的逻辑
        didSet {
            self.save()
        }
    }
    
    public private(set) var maxTimes: Int = 0 // 计数n
    public private(set) var currentTimes: Int = 0
    
    public private(set) var hitTimes: Int = 0 // 已触发次数
    
    public private(set) var pauseHitTimes: Int = 0 // 每pauseHitTimes次触发后暂停
    public private(set) var pauseHours: TimeInterval = 0 // 暂停的小时数
    public private(set) var pauseDays: Int = 0 // 暂停的天数，当pauseDays=1时表示暂停到当天24点，如pauseHours>0会忽略pauseDays
    
    public private(set) var cachedParams = JSON.null
    
    enum PersistentKey: String {
        case maxTimes, currentTimes
        case hitTimes
        case pausedUntilDate
        case pauseHitTimes, pauseHours, pauseDays
        case cachedParams
    }
    
    // 可配置参数
    public enum ParamsKey: String {
        case maxTimes
        case pauseHitTimes, pauseHours, pauseDays
    }
    
    //
    private var key: String!
    private static var all = [Counter]()
    
    //
    public static func find(key: String) -> Counter {
        var counter = self.all.first(where: { $0.key == key })
        
        if counter == nil {
            let newCounter = Counter()
            newCounter.key = key
            newCounter.loadPersistentProperties()
            self.all.append(newCounter)
            
            counter = newCounter
        }
        
        counter?.updateByParams()
        
        return counter!
    }
    
    private override init() {
        //
    }
    
    // 缓存参数配置
    public func cacheParams(_ params: JSON) {
        self.cachedParams = params
        self.updateByParams()
    }
    
    public func cleanCachedParams() {
        self.cacheParams(nil)
    }
    
    // 增加计数
    public func increase() {
        if self.isActive {
            self.currentTimes += 1
            
            if self.hitsMax {
                self.hitTimes += 1
            }
            
            self.save()
        }
    }
    
    // 复位重新计数
    public func reset() {
        
        self.currentTimes = 0
        
        // 判断自动暂停
        if self.hitTimes >= self.pauseHitTimes {
            if self.pauseHours > 0 {
                let seconds = self.pauseHours * 60 * 60
                self.pausedUntilDate = Date().addingTimeInterval(seconds)
                self.hitTimes = 0
            }
            else if self.pauseDays > 0 {
                if let beginingOfToday = beginingOfDate(Date()) {
                    let seconds = TimeInterval(self.pauseDays) * 24 * 60 * 60
                    self.pausedUntilDate = beginingOfToday.addingTimeInterval(seconds)
                    self.hitTimes = 0
                }
            }
        }
        
        //
        self.save()
    }
    
    // 计数是否达到最大值
    public var hitsMax: Bool {
        if self.isActive == false {
            return false
        }
        
        var hits = false
        
        if self.maxTimes > 0 && self.currentTimes >= self.maxTimes && Date().timeIntervalSince(self.pausedUntilDate) >= 0 {
            hits = true
        }
        
        return hits
    }
    
    // MARK: - Private
    
    private var isActive: Bool {
        if Counter.isEnabled == false {
            return false
        }
        
        return self.maxTimes > 0
    }
    
    private func updateByParams() {
        var params = self.cachedParams != JSON.null ? self.cachedParams : Preset.named(self.key)
        
        if params.dictionary != nil {
            self.maxTimes = params[ParamsKey.maxTimes.rawValue].intValue
            self.pauseHitTimes = params[ParamsKey.pauseHitTimes.rawValue].intValue
            self.pauseHours = params[ParamsKey.pauseHours.rawValue].doubleValue
            self.pauseDays = params[ParamsKey.pauseDays.rawValue].intValue
        }
        else {
            self.maxTimes = params.intValue
            self.pauseHitTimes = 0
            self.pauseHours = 0
            self.pauseDays = 0
        }
        
        self.save()
    }
}

// MARK: - Persistent

extension Counter {
    
    private func save() {
        var rawValue: [String: Any] = [
            PersistentKey.maxTimes.rawValue: self.maxTimes,
            PersistentKey.currentTimes.rawValue: self.currentTimes,
            PersistentKey.hitTimes.rawValue: self.hitTimes,
            PersistentKey.pausedUntilDate.rawValue: self.pausedUntilDate.timeIntervalSince1970,
            PersistentKey.pauseHitTimes.rawValue: self.pauseHitTimes,
            PersistentKey.pauseHours.rawValue: self.pauseHours,
            PersistentKey.pauseDays.rawValue: self.pauseDays
            ]
        
        if self.cachedParams != JSON.null {
            rawValue[PersistentKey.cachedParams.rawValue] = self.cachedParams.object
        }
        
        UserDefaults.standard.set(rawValue, forKey: self.userDefaultsKey())
    }
    
    private func loadPersistentProperties() {
        var json = JSON.null
        if let rawValue = UserDefaults.standard.dictionary(forKey: self.userDefaultsKey()) {
            json = JSON.init(rawValue: rawValue) ?? JSON.null
        }
        
        self.maxTimes = json[PersistentKey.maxTimes.rawValue].int ?? json["times"].intValue // 使用 "times" key 是因为历史遗留问题
        self.currentTimes = json[PersistentKey.currentTimes.rawValue].intValue
        self.hitTimes = json[PersistentKey.hitTimes.rawValue].intValue
        self.pausedUntilDate = Date(timeIntervalSince1970: json[PersistentKey.pausedUntilDate.rawValue].doubleValue)
        self.pauseHitTimes = json[PersistentKey.pauseHitTimes.rawValue].intValue
        self.pauseHours = json[PersistentKey.pauseHours.rawValue].doubleValue
        self.pauseDays = json[PersistentKey.pauseDays.rawValue].intValue
        self.cachedParams = json[PersistentKey.cachedParams.rawValue]
    }
    
    private func userDefaultsKey() -> String {
        return "Counter.\(self.key)"
    }
}

// MARK: - Private

extension Counter {
    func beginingOfDate(_ date: Date) -> Date? {
        let compoment = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: compoment)
    }
}
