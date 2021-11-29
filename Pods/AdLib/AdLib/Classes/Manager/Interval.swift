//
//  RequestInterval.swift
//  Ad
//
//  Created by Kevin on 2018/6/14.
//

import Foundation
import SwiftyJSON

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

class Interval {
    static var adTypeToErrorTimes = [AdType: Int]()
    
    static func requestInterval(adType: AdType) -> TimeInterval {
        // errorTimes
        var errorTimes = adTypeToErrorTimes[adType] ?? 0
        errorTimes += 1
        adTypeToErrorTimes[adType] = errorTimes
        
        // interval
        var intervals = Preset.named("S.Ad.requestIntervalsOccursError")[adType.rawValue].array?.map({$0.doubleValue})
        if intervals?.count ?? 0 == 0 {
            if adType == .banner {
                intervals = [10, 10, 20, 30]
            }
            else {
                intervals = [10, 10, 20, 30]
            }
        }
        
        let result = (errorTimes <= intervals!.count ? intervals?[errorTimes-1] : intervals?.last)
        return result!
    }
    
    static func requestDispatchInterval(adType: AdType) -> DispatchTimeInterval {
        let seconds = self.requestInterval(adType: adType)
        return DispatchTimeInterval.milliseconds(Int(seconds * 1000))
    }
}
