//
//  String.swift
//  JM-Music
//
//  Created by Kevin on 2019/3/21.
//  Copyright © 2019 Kevin. All rights reserved.
//

import Foundation

public extension String {
    func toURL() -> URL? {
        if self.hasPrefix("http://") || self.hasPrefix("https://") {
            return URL(string: self)
        }
        
        return URL(fileURLWithPath: self)
    }
    
    func preset(_ name: String) -> String {
        return Preset.named(name).string ?? self
    }
}
