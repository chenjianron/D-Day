//
//  ExtendedAttributes.swift
//  CalculatorPhotoVault
//
//  Created by Kevin on 27/02/2017.
//  Copyright © 2017 com.Flow. All rights reserved.
//

import Foundation
import SwiftyJSON

public func removeExtendedAttribute(name: String, path: String) {
    removexattr(path, name, 0)
}

public func setExtendedAttribute(name: String, value: JSON?, path: String) {
    if value == nil {
        removeExtendedAttribute(name: name, path: path)
    }
    else if let rawString = value?.rawString() {
        if let data = rawString.data(using: .utf8) as NSData? {
            setxattr(path, name, data.bytes, data.length, 0, 0)
        }
    }
}

public func extendedAttribute(name: String, path: String?, attributes: [FileAttributeKey : Any]? = nil) -> JSON {
    var attrs = attributes
    
    if path == nil && attrs == nil {
        return JSON.null
    }
    
    if attrs == nil {
        attrs = try? FileManager.default.attributesOfItem(atPath: path!)
    }
    
    if let dict = attrs?[FileAttributeKey.init("NSFileExtendedAttributes")] as? [String: Any] {
        if let data = dict[name] as? Data {
            
            if let rawString = String.init(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let json = JSON.init(parseJSON: rawString)
                
                if json.dictionary != nil || json.array != nil {
                    return json
                }
                
                return JSON.init(rawValue: rawString) ?? JSON.null
            }
        }
    }
    
    return JSON.null
}
