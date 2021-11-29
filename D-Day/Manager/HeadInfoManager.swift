//
//  HeadInfoManager.swift
//  D-Day
//
//  Created by GC on 2021/10/13.
//

import UIKit

class HeadInfoManager {
    
    static let `default` = HeadInfoManager()
    
    var manHead:UIImage? {
        set {
            if let image = newValue{
                let imageName = "ManHead.jpg"
                if AppStorageGroupsManager.default.saveImage(image,withName: imageName) {
                    AppStorageGroupsManager.default.setValue(imageName, forKey: K.AppGroupsKey.ManHead)
                }
            }
        }
        get {
            if let imageName = AppStorageGroupsManager.default.value(forKey: K.AppGroupsKey.ManHead) as? String {
                return AppStorageGroupsManager.default.fetchImage(withName: imageName)
            }
            return nil
        }
    }
    
    var womenHead:UIImage? {
        set {
            if let image = newValue {
                let imageName = "WomenHead.jpg"
                if AppStorageGroupsManager.default.saveImage(image, withName: imageName) {
                    AppStorageGroupsManager.default.setValue(imageName, forKey: K.AppGroupsKey.WomenHead)
                }
            }
        }
        get {
            if let imageName = AppStorageGroupsManager.default.value(forKey: K.AppGroupsKey.WomenHead) as? String {
                return AppStorageGroupsManager.default.fetchImage(withName: imageName)
            }
            return nil
        }
    }
    
    var loveDate: Date {
        set {
            AppStorageGroupsManager.default.setValue(newValue, forKey: K.UserDefaultsKey.FirstKnowingTime)
        }
        get {
            if let date = AppStorageGroupsManager.default.value(forKey: K.UserDefaultsKey.FirstKnowingTime) as? Date {
                return date
            }
            let date = Date()
            AppStorageGroupsManager.default.setValue(date, forKey: K.UserDefaultsKey.FirstKnowingTime)
            return date
        }
    }
}
