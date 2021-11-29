//
//  AppStorageGroupsManager.swift
//  D-Day
//
//  Created by GC on 2021/10/13.
//

import UIKit

class AppStorageGroupsManager {
    
    static let `default` = AppStorageGroupsManager()
    
    lazy var userDefaults = UserDefaults(suiteName: K.AppGroups.Identifier)!
    lazy var containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: K.AppGroups.Identifier)!
    
    func setValue(_ value: Any?, forKey key: String){
        userDefaults.setValue(value, forKey: key)
    }
    
    func value(forKey key: String) -> Any? {
        return userDefaults.value(forKey:key)
    }
    
    func set(_ value:Bool, forKey key:String){
        userDefaults.set(value,forKey: key)
    }
    
    func bool(forKey defaultName: String) -> Bool {
        return userDefaults.bool(forKey: defaultName)
    }
}

// MARK: FileManager
extension AppStorageGroupsManager {
    
    func saveImage(_ image: UIImage, withName path:String) -> Bool {
        let imageData = image.jpegData(compressionQuality: 0.8)
        do {
            try imageData?.write(to: containerURL.appendingPathComponent(path))
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    func fetchImage(withName path:String) -> UIImage? {
        return UIImage(contentsOfFile: containerURL.path.appending("/\(path)"))
    }
}
