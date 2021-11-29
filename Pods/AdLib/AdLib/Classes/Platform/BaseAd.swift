//
//  AdPlatform.swift
//  Ad
//
//  Created by Kevin on 10/10/2017.
//

import UIKit
import GoogleMobileAds

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

protocol BaseAdDelegate {
    func bannerAdDidFail(banner: Any)
    
    func interstitialDidFail(unitID: String?)
    func interstitialDidReceiveAd(unitID: String?)
    func interstitialDidPresent(unitID: String?)
    func interstitialDidDismiss(unitID: String?)
    
    func openAdDidReceiveAd()
    func openAdDidPresent()
    func openAdDidDismiss()
    
    func rewardAdDidFail()
    func rewardAdDidPresent()
    func rewardAdDidRewardUser()
    func rewardAdDidDismiss()
}

class BaseAd: NSObject {
    
    var delegate: BaseAdDelegate?
    
    //
    var defaultBannerUnitID: String?
    var interstitialUnitIDs = [String]()
    var rewardAdUnitID: String?
    var openAdUnitID: String?
    
    //
    func setup(bannerUnitID: String?, interstitialUnitIDs: [String], rewardAdUnitID: String?, openAdUnitID: String?) {
        self.defaultBannerUnitID = bannerUnitID
        self.interstitialUnitIDs = interstitialUnitIDs
        self.rewardAdUnitID = rewardAdUnitID
        self.openAdUnitID = openAdUnitID
    }
    
    func setupInterstitials() {
        for (index, unitID) in interstitialUnitIDs.enumerated() {
            if index == 0 {
                self.requestInterstitial(unitID: unitID)
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.requestInterstitial(unitID: unitID)
                }
            }
        }
    }
    
    // MARK: - Override points
    
    func isInterstitialReady(unitID: String) -> Bool { return false }
    
    private(set) var isRewardAdReady = false
    
    func createBanner(rootViewController: UIViewController?, size: GADAdSize? = nil, specifiedUnitID: String? = nil) -> UIView? {
        return nil
    }
    
    func reloadBanner(_ banner: Any) {}
    
    func requestInterstitial(unitID: String) {}
    
    func requestRewardAd() {}
    
    func requestOpenAd() {}
    
    func presentInterstitial(unitID: String, from controller: UIViewController) {}
    
    func presentRewardAd(from controller: UIViewController) {}
    
    func presentOpenAd(from controller: UIViewController) {}
}
