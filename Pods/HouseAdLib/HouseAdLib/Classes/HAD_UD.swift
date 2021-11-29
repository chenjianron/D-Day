//
//  HADVisited.swift
//  AdLib
//
//  Created by Kevin on 2019/11/8.
//

import Foundation

class HAD_UD {
    struct Keys {
        static let IdToViews = "HAD_UD.IdToViews"
        static let IdToTaps = "HAD_UD.IdToTaps"
    }
    
    static func adTaps(id: String) -> Int {
        return idToTaps[id] ?? 0
    }
    
    static func adViews(id: String) -> Int {
        return idToViews[id] ?? 0
    }
    
    @discardableResult
    static func increaseAdTaps(id: String) -> Int {
        var idToTaps = self.idToTaps
        let taps = adTaps(id: id) + 1
        idToTaps[id] = taps
        UserDefaults.standard.set(idToTaps, forKey: Keys.IdToTaps)
        return taps
    }
    
    @discardableResult
    static func increaseAdViews(id: String) -> Int {
        var idToViews = self.idToViews
        let views = adViews(id: id) + 1
        idToViews[id] = views
        UserDefaults.standard.set(idToViews, forKey: Keys.IdToViews)
        return views
    }
}

// MARK: - Private

private extension HAD_UD {
    static var idToTaps: [String: Int] {
        return (UserDefaults.standard.dictionary(forKey: Keys.IdToTaps) as? [String: Int]) ?? [:]
    }
    
    static var idToViews: [String: Int] {
        return (UserDefaults.standard.dictionary(forKey: Keys.IdToViews) as? [String: Int]) ?? [:]
    }
}
