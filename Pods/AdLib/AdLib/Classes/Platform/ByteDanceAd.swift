//
//  ByteDanceAd.swift
//  AdLib
//
//  Created by Kevin on 2021/2/2.
//

import Foundation
import GoogleMobileAds
import BUAdSDK

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

class ByteDanceAd: BaseAd {
    
    private var unitIDToInterstitial = [String: BUNativeExpressInterstitialAd]()
    private var visitingInterstitial: BUNativeExpressInterstitialAd?
    private var rewardAd: BUNativeExpressRewardedVideoAd?
    
    override func isInterstitialReady(unitID: String) -> Bool {
        return unitIDToInterstitial[unitID]?.isAdValid == true
    }
    
    override var isRewardAdReady: Bool {
        return false
    }
    
    override func createBanner(rootViewController: UIViewController?, size: GADAdSize? = nil, specifiedUnitID: String? = nil) -> UIView? {
        guard let bannerUnitID = specifiedUnitID ?? self.defaultBannerUnitID else {
            return nil
        }
        
        let adSize = (size ?? Ad.default.adaptiveBannerSize).size
        let banner = BUNativeExpressBannerView(slotID: bannerUnitID, rootViewController: rootViewController ?? Util.topViewController(), adSize: adSize)
        banner.delegate = self
        banner.loadAdData()
        return banner
    }
    
    override func reloadBanner(_ banner: Any) {
        (banner as? BUNativeExpressBannerView)?.loadAdData()
    }
    
    override func requestInterstitial(unitID: String) {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width * 0.9
        let maxHeight = screenSize.height * (Util.isIPad ? 0.8 : 0.7)
        let size = CGSize(width: width, height: min(width / 2 * 3.3, maxHeight))
        
        let interstitial = BUNativeExpressInterstitialAd(slotID: unitID, adSize: size)
        interstitial.delegate = self
        interstitial.loadData()
        unitIDToInterstitial[unitID] = interstitial
    }
    
    override func requestRewardAd() {
        guard let unitID = self.rewardAdUnitID else {
            return
        }
        
        let model = BURewardedVideoModel()
        self.rewardAd = BUNativeExpressRewardedVideoAd(slotID: unitID, rewardedVideoModel: model)
        self.rewardAd?.delegate = self
        self.rewardAd?.loadData()
    }
    
    override func presentInterstitial(unitID: String, from controller: UIViewController) {
        unitIDToInterstitial[unitID]?.show(fromRootViewController: controller)
    }

    override func presentRewardAd(from controller: UIViewController) {
        self.rewardAd?.show(fromRootViewController: controller)
    }
}

extension ByteDanceAd: BUNativeExpressBannerViewDelegate {
    func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
        self.delegate?.bannerAdDidFail(banner: bannerAdView)
    }
    
    func nativeExpressBannerAdViewDidLoad(_ bannerAdView: BUNativeExpressBannerView) {
        bannerAdView.delegate = nil
    }
}

extension ByteDanceAd: BUNativeExpresInterstitialAdDelegate {
    
    func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        LLog(error)
        self.delegate?.interstitialDidFail(unitID: findUnitIDForInterstitial(interstitialAd))
    }
    
    func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
        self.delegate?.interstitialDidReceiveAd(unitID: findUnitIDForInterstitial(interstitialAd))
    }
    
    func nativeExpresInterstitialAdWillVisible(_ interstitialAd: BUNativeExpressInterstitialAd) {
        let topVC = Util.topViewController()
        let topVCClassName = String(describing: type(of: topVC))
        if topVCClassName == "BUNativeExpressInterstitialAdViewController" {
            topVC.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.4)
        }
        
        self.delegate?.interstitialDidPresent(unitID: findUnitIDForInterstitial(interstitialAd))
    }
    
    func nativeExpresInterstitialAdDidClick(_ interstitialAd: BUNativeExpressInterstitialAd) {
        self.visitingInterstitial = interstitialAd
    }
    
    func nativeExpresInterstitialAdDidClose(_ interstitialAd: BUNativeExpressInterstitialAd) {
        if visitingInterstitial != interstitialAd {
            self.delegate?.interstitialDidDismiss(unitID: findUnitIDForInterstitial(interstitialAd))
        }
    }
    
    func nativeExpresInterstitialAdDidCloseOtherController(_ interstitialAd: BUNativeExpressInterstitialAd, interactionType: BUInteractionType) {
        visitingInterstitial = nil
        self.delegate?.interstitialDidDismiss(unitID: findUnitIDForInterstitial(interstitialAd))
    }
}

extension ByteDanceAd: BUNativeExpressRewardedVideoAdDelegate {
    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        self.delegate?.rewardAdDidFail()
    }
    
    func nativeExpressRewardedVideoAdDidVisible(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.delegate?.rewardAdDidPresent()
    }
    
    func nativeExpressRewardedVideoAdDidClick(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        //
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        self.delegate?.rewardAdDidRewardUser()
    }
    
    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.delegate?.rewardAdDidDismiss()
    }
}

// MARK: - Private

extension ByteDanceAd {
    private func findUnitIDForInterstitial(_ interstitial: BUNativeExpressInterstitialAd) -> String? {
        for (key, value) in unitIDToInterstitial {
            if value == interstitial {
                return key
            }
        }
        
        return nil
    }
}
