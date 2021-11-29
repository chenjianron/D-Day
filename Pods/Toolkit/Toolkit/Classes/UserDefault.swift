//
//  Storage.swift
//  Toolkit
//
//  Created by Endless Summer on 2020/10/29.
//

import Foundation

public protocol PlistCompatible {}

// MARK: - UserDefaults Compatibile Types
extension String: PlistCompatible {}
extension Int: PlistCompatible {}
extension Double: PlistCompatible {}
extension Float: PlistCompatible {}
extension Bool: PlistCompatible {}
extension Date: PlistCompatible {}
extension Data: PlistCompatible {}
extension Array: PlistCompatible where Element: PlistCompatible {}
extension Dictionary: PlistCompatible where Key: PlistCompatible, Value: PlistCompatible {}

@propertyWrapper
public struct UserDefault<T: PlistCompatible> {
    private let key: String
    private let defaultValue: T
    
    private let defaults: UserDefaults
    
    public init(key: String, defaultValue: T, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }
    
    public var wrappedValue: T {
        get {
            // Read value from UserDefaults
            return defaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            defaults.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct StoredProperty<T: RawRepresentable> where T.RawValue: PlistCompatible {
    private let key: String
    private let defaultValue: T
    private let defaults: UserDefaults
    
    public init(key: String, defaultValue: T, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }
    
    public var wrappedValue: T {
        get {
            guard let rawValue = defaults.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) else {
                 return defaultValue
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: key)
        }
    }
}
