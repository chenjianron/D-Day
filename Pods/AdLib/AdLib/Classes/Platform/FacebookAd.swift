//
//  FacebookAd.swift
//  Pods
//
//  Created by Kevin on 25/09/2017.
//
//

import UIKit
import FBAudienceNetwork
import GoogleMobileAds

class FacebookAd: BaseAd {
    
    private var unitIDToInterstitial = [String: FBInterstitialAd]()
    private var rewardAd: FBRewardedVideoAd?
    
    override func isInterstitialReady(unitID: String) -> Bool {
        return unitIDToInterstitial[unitID]?.isAdValid == true
    }
    
    override var isRewardAdReady: Bool {
        return self.rewardAd?.isAdValid == true
    }
    
    override func createBanner(rootViewController: UIViewController?, size: GADAdSize? = nil, specifiedUnitID: String? = nil) -> UIView? {
        guard let bannerUnitID = specifiedUnitID ?? self.defaultBannerUnitID else {
            return nil
        }
        
        let banner = FBAdView.init(placementID: bannerUnitID, adSize: kFBAdSizeHeight50Banner, rootViewController: rootViewController)
        banner.delegate = self
        banner.loadAd()
        return banner
    }
    
    override func reloadBanner(_ banner: Any) {
        (banner as? FBAdView)?.loadAd()
    }
    
    override func requestInterstitial(unitID: String) {
        let interstitial = FBInterstitialAd(placementID: unitID)
        interstitial.delegate = self
        interstitial.load()
        unitIDToInterstitial[unitID] = interstitial
    }
    
    override func requestRewardAd() {
        guard let unitID = self.rewardAdUnitID else {
            return
        }
        
        self.rewardAd = FBRewardedVideoAd.init(placementID: unitID)
        self.rewardAd?.delegate = self
        self.rewardAd?.load()
    }
    
    override func presentInterstitial(unitID: String, from controller: UIViewController) {
        unitIDToInterstitial[unitID]?.show(fromRootViewController: controller)
    }

    override func presentRewardAd(from controller: UIViewController) {
        self.rewardAd?.show(fromRootViewController: controller)
    }
}

extension FacebookAd: FBAdViewDelegate {
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        self.delegate?.bannerAdDidFail(banner: adView)
    }
    
    func adViewDidLoad(_ adView: FBAdView) {
        adView.delegate = nil // 成功请求一次广告之后，不需要再监控error并自动请求，暂时直接设置delegate=nil
    }
}

extension FacebookAd: FBInterstitialAdDelegate {

    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print(#function, error)
        self.delegate?.interstitialDidFail(unitID: interstitialAd.placementID)
    }
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        self.delegate?.interstitialDidReceiveAd(unitID: interstitialAd.placementID)
    }
    
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.interstitialDidPresent(unitID: interstitialAd.placementID)
        }
    }
    
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        //
    }
    
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        self.delegate?.interstitialDidDismiss(unitID: interstitialAd.placementID)
    }
}

extension FacebookAd: FBRewardedVideoAdDelegate {
    
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        self.delegate?.rewardAdDidFail()
    }
    
    func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.rewardAdDidPresent()
        }
    }
    
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        //
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        self.delegate?.rewardAdDidRewardUser()
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        self.delegate?.rewardAdDidDismiss()
    }
}

