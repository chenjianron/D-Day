//
//  Def.swift
//  Ad
//
//  Created by Kevin on 16/10/2017.
//

import UIKit

public enum Platform: Int {
    case Admob = 0
    case Facebook = 1
    case ByteDance = 2
}

public struct PlatformOptions: Equatable {
    var platform: Platform = .Admob
    var adAppID: String?
    var defaultBannerUnitID: String?
    var defaultInterstitialUnitID: String?
    var interstitialSignalKeyToSpecifiedUnitID: [String: String]?
    var openAdUnitID: String?
    var rewardAdUnitID: String?
    var delay: Double = 0
    
    //
    var interstitialAllUnitIDs: [String] {
        var results = [String]()
        
        if let unitID = defaultInterstitialUnitID {
            results.append(unitID)
        }
        
        let specifiedUnitIDs = interstitialSignalKeyToSpecifiedUnitID?.map({ $0.value })
        for unitID in specifiedUnitIDs ?? [] {
            if results.contains(unitID) == false {
                results.append(unitID)
            }
        }
        
        return results
    }
}

public func ==(l: PlatformOptions, r: PlatformOptions) -> Bool {
    return l.platform == r.platform &&
        l.adAppID == r.adAppID &&
        l.defaultBannerUnitID == r.defaultBannerUnitID &&
        l.defaultInterstitialUnitID == r.defaultInterstitialUnitID &&
        l.interstitialSignalKeyToSpecifiedUnitID == r.interstitialSignalKeyToSpecifiedUnitID &&
        l.rewardAdUnitID == r.rewardAdUnitID &&
        l.openAdUnitID == r.openAdUnitID
}
