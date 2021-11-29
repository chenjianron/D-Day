//
//  Preset.swift
//
//  Created by kevin on 06/12/2019.
//  Copyright ©2019. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Preset: NSObject {
    
    public static let `default` = Preset()
    
    private var defaults: [String: Any]?
    private var versionMappingRawPMs: [String: Any]?
    
    // 如果不需要取本地化参数，则 localized = false
    static public func named(_ name: String, localized: Bool = true) -> JSON {
        return Preset.default.named(name, localized: localized)
    }
    
    public func setup(defaults: [String: Any]?) {
        Preset.default.defaults = defaults
    }

    private override init() {
        super.init()
        
        self.updateVersionMappingRawPMs()
        NotificationCenter.default.addObserver(self, selector: #selector(jsonUpdated), name: JSONUpdatedNotification, object: nil)
    }
    
    public func named(_ name: String, localized: Bool = true) -> JSON {
        let rawValue = self.versionMappingRawPMs?[name] ?? JSON.rawPMs?[name] ?? self.defaults?[name]
        return self.parseJSON(rawValue: rawValue, localized: localized)
    }
    
    // MARK: - Notification
    
    @objc func jsonUpdated() {
        self.updateVersionMappingRawPMs()
    }
    
    // MARK: - Internal
    
    internal func parseJSON(rawValue: Any?, localized: Bool = true) -> JSON {
        guard let rawValue = rawValue else {
            return JSON.null
        }
        
        var json: JSON? = nil
        
        if var stringJSON = (rawValue as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            // Replace the URL of the specified language or country/region
            stringJSON = stringJSON.replacingOccurrences(of: "{language}", with: Util.languageCode())
            stringJSON = stringJSON.replacingOccurrences(of: "{country}", with: Util.countryCode())
            
            let j = JSON.init(parseJSON: stringJSON)
            
            if j.dictionary != nil || j.array != nil { // JSON string
                json = j
            } else {
                json = JSON.init(rawValue: rawValue) // string
            }
        }
        
        let p = json ?? JSON.init(rawValue: rawValue) ?? JSON.null
        
        return localized == false ? p : localizedJSON(p)
    }
    
    internal func localizedJSON(_ json: JSON) -> JSON {
        var p = json
        
        if p.dictionary != nil { 
            if self.isLanguageLocalizable(json: p) {
                let jsonForCurrentLanguage = p[Util.languageCode()]
                p = jsonForCurrentLanguage != JSON.null ? jsonForCurrentLanguage : p["others"]
            }
            else if self.isCountryLocalizable(json: p) {
                let jsonForCurrentCountry = p[Util.countryCode()]
                p = jsonForCurrentCountry != JSON.null ? jsonForCurrentCountry : p["OTHERS"]
            }
        }
        
        return p
    }
    
    private func isLanguageLocalizable(json: JSON) -> Bool {
        return json["others"] != JSON.null
    }
    
    private func isCountryLocalizable(json: JSON) -> Bool {
        return json["OTHERS"] != JSON.null
    }
    
    private func updateVersionMappingRawPMs() {
        if let str = JSON.rawPMs?["pv\(Util.appVersion())"] as? String {
            let json = self.parseJSON(rawValue: str)
            self.versionMappingRawPMs = json.rawValue as? [String: Any]
        }
        else {
            self.versionMappingRawPMs = nil
        }
    }
}
