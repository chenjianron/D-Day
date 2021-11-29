//
//  AdmobAd.swift
//  Pods
//
//  Created by Kevin on 25/09/2017.
//
//

import UIKit
import GoogleMobileAds
import SwiftyJSON

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

class AdmobAd: BaseAd {
    
    private var unitIDToInterstitial = [String: GADInterstitialAd]()
    private var rewardAd: GADRewardedAd?
    private var openAd: GADAppOpenAd?
    
    override func isInterstitialReady(unitID: String) -> Bool {
        return unitIDToInterstitial[unitID] != nil
    }
    
    override var isRewardAdReady: Bool {
        return self.rewardAd != nil
    }
    
    override func createBanner(rootViewController: UIViewController?, size: GADAdSize? = nil, specifiedUnitID: String? = nil) -> UIView? {
        guard let bannerUnitID = specifiedUnitID ?? self.defaultBannerUnitID else {
            return nil
        }
        
        let bannerView = GADBannerView()
        bannerView.adUnitID = bannerUnitID
        bannerView.rootViewController = rootViewController
        bannerView.delegate = self
        bannerView.adSize = size ?? kGADAdSizeBanner
        bannerView.load(newRequest(.banner))

        return bannerView
    }
    
    override func reloadBanner(_ banner: Any) {
        (banner as? GADBannerView)?.load(newRequest(.banner))
    }
    
    override func requestInterstitial(unitID: String) {
        self.unitIDToInterstitial[unitID] = nil
        
        GADInterstitialAd.load(withAdUnitID: unitID, request: newRequest(.interstitial)) { [weak self] (interstitial, error) in
            self?.unitIDToInterstitial[unitID] = interstitial
            interstitial?.fullScreenContentDelegate = self
            
            if let error = error {
                LLog(error)
                self?.delegate?.interstitialDidFail(unitID: unitID)
            }
            else {
                self?.delegate?.interstitialDidReceiveAd(unitID: unitID)
            }
        }
    }
    
    override func requestRewardAd() {
        guard let unitID = self.rewardAdUnitID else {
            return
        }
        
        self.rewardAd = nil
        GADRewardedAd.load(withAdUnitID: unitID, request: newRequest(.reward)) { [weak self] (rewardAd, error) in
            self?.rewardAd = rewardAd
            self?.rewardAd?.fullScreenContentDelegate = self
            
            if let error = error {
                LLog(error)
                self?.delegate?.rewardAdDidFail()
            }
            else {
                //
            }
        }
    }
    
    override func requestOpenAd() {
        guard let unitID = self.openAdUnitID else {
            return
        }
        
        self.openAd = nil
        GADAppOpenAd.load(withAdUnitID: unitID, request: GADRequest(), orientation: .portrait) { [weak self] (openAd, error) in
            self?.openAd = openAd
            self?.openAd?.fullScreenContentDelegate = self

            if let error = error {
                LLog(error)
            }
            else {
                self?.delegate?.openAdDidReceiveAd()
            }
        }
    }
    
    override func presentInterstitial(unitID: String, from controller: UIViewController) {
        unitIDToInterstitial[unitID]?.present(fromRootViewController: controller)
    }
    
    override func presentRewardAd(from controller: UIViewController) {
        self.rewardAd?.present(fromRootViewController: controller, userDidEarnRewardHandler: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.rewardAdDidRewardUser()
            LLog("userDidEarnRewardHandler")
        })
    }
    
    override func presentOpenAd(from controller: UIViewController) {
        self.openAd?.present(fromRootViewController: controller)
    }
}

extension AdmobAd: GADBannerViewDelegate {
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.delegate?.bannerAdDidFail(banner: bannerView)
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.delegate = nil // 成功请求一次广告之后，不需要再监控error并自动请求，暂时直接设置delegate=nil
    }
}

extension AdmobAd: GADFullScreenContentDelegate {
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if let unitID = (ad as? GADInterstitialAd)?.adUnitID {
            self.delegate?.interstitialDidPresent(unitID: unitID)
        }
        else if let openAd = ad as?GADAppOpenAd {
            self.delegate?.openAdDidPresent()
        }
        else if let rewardAd = ad as? GADRewardedAd {
            self.delegate?.rewardAdDidPresent()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if let unitID = (ad as? GADInterstitialAd)?.adUnitID {
            self.delegate?.interstitialDidDismiss(unitID: unitID)
        }
        else if let openAd = ad as? GADAppOpenAd {
            self.delegate?.openAdDidDismiss()
        }
        else if let rewardAd = ad as? GADRewardedAd {
            self.delegate?.rewardAdDidDismiss()
        }
    }
}

extension AdmobAd {
    private func newRequest(_ adType: AdType) -> GADRequest {
        let request = GADRequest()
        return request
    }
}
