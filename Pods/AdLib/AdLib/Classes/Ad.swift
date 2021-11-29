//
//  Ad.swift
//  Common
//
//  Created by lsc on 27/02/2017.
//
//

import UIKit
import SwiftyJSON
import Reachability
import GoogleMobileAds
import BUAdSDK

#if canImport(Toolkit)
import Toolkit
import HouseAdLib
#elseif canImport(DCGKit)
import DCGKit
import DCGHouseAd
#endif

public class Ad: NSObject {
    
    public static let `default` = Ad()
    
    public var isEnabled: Bool = true
    
    public var isRewardAdReady: Bool {
        return self.isEnabled && self.ad?.isRewardAdReady == true
    }
    
    public var adaptiveBannerHeight: CGFloat {
        return self.adaptiveBannerSize.size.height
    }
    
    // Launch & EnterForeground interstitialEnded
    public var launchAdEndedHandler: (() -> Void)?
    public var enterForegroundAdEndedHandler: (() -> Void)?
    private var becomeActiveTime = Date()
    
    // Platform
    public private(set) var initialPlatformOptions: PlatformOptions?
    public private(set) var currentPlatformOptions: PlatformOptions?
    
    private var ad: BaseAd? {
        didSet {
            oldValue?.delegate = nil
            self.ad?.delegate = self
        }
    }
    
    // House Ad
    private lazy var popupImageAd: HADImagePopupAd = {
        return HADImagePopupAd(dataKey: "S.Ad.popupImageAd")
    }()

    //
    private var interstitialContext: Context?
    private var isLaunchAdProcessed = false

    private var rewardAdContext: Context?
    
    // launch、enterforeground
    private var hasEnterBackground = false
    private let launchTime = Date()
    private var isFirstLaunch = true
    private var launchKey: String?
    private var enterForegroundKey: String?
    private var loadingViewContainer: LoadingViewContainer {
        return LoadingViewContainer.shared
    }
    
    //
    private var bannerContainers = [Weak<BannerContainer>]()
    internal var adaptiveBannerSize: GADAdSize {
        let screenSize = UIScreen.main.bounds.size
        let width = min(screenSize.width, screenSize.height)
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
    }
    
    //
    private var reachability = Reachability.forInternetConnection()
    
    private var openAd: GADAppOpenAd?
    private var openAdDidDismissedAction: (() -> Void)?
    
    public func setup(platform: Platform = .Admob, bannerUnitID: String?, interstitialUnitID: String?, interstitialSignalKeyToSpecifiedUnitID: [String: String]? = nil, openAdUnitID: String?, rewardAdUnitID: String? = nil, isEnabled: Bool = true) {
        self.isEnabled = isEnabled

        //
        self.initialPlatformOptions = PlatformOptions(platform: platform,
                                                      adAppID: nil,
                                                      defaultBannerUnitID: bannerUnitID,
                                                      defaultInterstitialUnitID: interstitialUnitID,
                                                      interstitialSignalKeyToSpecifiedUnitID: interstitialSignalKeyToSpecifiedUnitID,
                                                      openAdUnitID: openAdUnitID,
                                                      rewardAdUnitID: rewardAdUnitID)
        self.setupAd()

        //
        self.reachability?.startNotifier()
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidLaunch), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(jsonUpdated), name: JSONUpdatedNotification, object: nil)
        
        //
        SettingsFeaturedApps.shared.setup()
        Pro.shared.setup()
    }
    
    public func setupLaunchInterstitial(launchKey: String?, enterForegroundKey: String?, loadingView: UIView? = nil) {
        self.launchKey = launchKey
        self.enterForegroundKey = enterForegroundKey
        
        //
        if loadingView != nil {
            self.loadingViewContainer.customView = loadingView
        }
    }
    
    public func createBannerView(rootViewController: UIViewController?, houseAdID: String?, specifiedUnitID: String? = nil) -> UIView? {
        if self.isEnabled == false {
            return nil
        }
        
        let theSpecifiedUnitID = (specifiedUnitID != nil ? specifiedUnitID!.preset(specifiedUnitID!) : nil) // 通过Preset有机会在线修改 specifiedUnitID
        
        if let banner = self.ad?.createBanner(rootViewController: rootViewController, size: self.adaptiveBannerSize, specifiedUnitID: theSpecifiedUnitID) {
            let container = BannerContainer.init(banner: banner, rootViewController: rootViewController, houseAdID: houseAdID)
            self.bannerContainers.append(Weak(value: container))
            return container
        }
        
        return nil
    }
    
    @discardableResult
    public func interstitialSignal(key: String) -> Context {
        let ctx = Context(signalKey: key)
        
        let counter = Counter.find(key: key)
        counter.increase()
        
        let counterHitsMax = (self.isEnabled && counter.hitsMax == true)
        let canPresentAd = counterHitsMax && self.anyReadyInterstitialUnitID(signalKey: key) != nil && canTopViewControllerPresentAd()
        
        ctx.counterHitsMax = counterHitsMax
        ctx.adSkipped = !canPresentAd
        
        if canPresentAd {
            self.interstitialContext = ctx
            counter.reset()
            
            DispatchQueue.main.async {
                self.presentInterstitial(signalKey: key)

                //
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.loadingViewContainer.hide()
                })
            }
        }
        else {
            DispatchQueue.main.async {
                ctx.didEndAction?(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.loadingViewContainer.hide()
                })
            }
        }
        
        return ctx
    }
    
    public func presentInterstitial(signalKey: String) {
        if let unitID = anyReadyInterstitialUnitID(signalKey: signalKey) {
            self.ad?.presentInterstitial(unitID: unitID, from: Util.topViewController())
        }
    }
    
    @discardableResult
    public func rewardAdSignal(key: String) -> Context {
        let ctx = Context(signalKey: key)
        
        let counter = Counter.find(key: key)
        counter.increase()
        
        let counterHitsMax = (self.isEnabled && counter.hitsMax == true)
        let canPresentAd = counterHitsMax && self.isRewardAdReady && canTopViewControllerPresentAd()
        
        ctx.counterHitsMax = counterHitsMax
        ctx.adSkipped = !canPresentAd
        
        if canPresentAd {
            self.rewardAdContext = ctx
            // 在 func rewardAdDidRewardUser 调用 counter.reset()
            
            DispatchQueue.main.async {
                self.presentRewardAd()
            }
        }
        else {
            DispatchQueue.main.async {
                ctx.didEndAction?(true)
            }
        }
        
        return ctx
    }
    
    public enum RewardAdResult {
        case notHitsMax, alertCanceled, stillNotReady, adCanceled, rewarded
    }
    
    public func rewardAdSignal(key: String, alertDataKey: String, waitTime: Int = 3, handler: @escaping (_ result: RewardAdResult) -> Void) {
        let counter = Counter.find(key: key)
        counter.increase()
        if counter.hitsMax {
            self.showRewardAdAlert(key: key, alertDataKey: alertDataKey, waitTime: waitTime, handler: handler)
        }
        else {
            handler(.notHitsMax)
        }
    }
    
    public func presentRewardAd() {
        self.ad?.presentRewardAd(from: Util.topViewController())
    }
}

// MARK: - Notification

extension Ad {
    
    @objc func appDidLaunch() {
        self.becomeActiveTime = Date()
        
        self.loadingViewContainer.show()
        if self.isEnabled == false || self.launchKey == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadingViewContainer.hide()
                self.launchAdEndedHandler?()
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.loadingViewContainer.maxLoadingTime) {
                if self.isLaunchAdProcessed == false {
                    self.launchAdEndedHandler?()
                }
            }
        }
    }
    
    @objc func appDidEnterBackground() {
        self.loadingViewContainer.show()
    }
    
    @objc func appWillEnterForeground() {
        self.becomeActiveTime = Date()
        
        if self.isEnabled == false || self.enterForegroundKey == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + loadingViewContainer.enterForegroundHideDelay) {
                self.enterForegroundAdEndedHandler?()
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let ctx = self.interstitialSignal(key: self.enterForegroundKey!)
                let time = self.becomeActiveTime
                
                ctx.didEndAction = { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        if self.becomeActiveTime == time {
                            self.enterForegroundAdEndedHandler?()
                        }
                    })
                }
            })
        }
    }

    @objc func reachabilityChanged(notification: Notification) {
        if notification.object as? Reachability == self.reachability, self.reachability?.isReachable() == true {
            
            for unitID in currentPlatformOptions?.interstitialAllUnitIDs ?? [] {
                if self.ad?.isInterstitialReady(unitID: unitID) != true {
                    self.requestInterstitial(unitID: unitID)
                }
            }
        }
    }
    
    @objc func jsonUpdated() {
        self.setupAd()
        self.showPopupImageAdIfNeeded()
    }
}

// MARK: - BaseAdDelegate

extension Ad: BaseAdDelegate {
    
    func bannerAdDidFail(banner: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Interval.requestDispatchInterval(adType: .banner)) {
            self.ad?.reloadBanner(banner)
        }
    }
    
    func interstitialDidFail(unitID: String?) {
        if unitID != nil {
            self.perform(#selector(requestInterstitial(unitID:)), with: unitID!, afterDelay: Interval.requestInterval(adType: .interstitial))
        }
    }
    
    func interstitialDidReceiveAd(unitID: String?) {
        guard canPresentLaunchAd else { return }
            
        self.isLaunchAdProcessed = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let ctx = self.interstitialSignal(key: self.launchKey!)
            let time = self.becomeActiveTime
            
            ctx.didEndAction = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if self.becomeActiveTime == time {
                        self.launchAdEndedHandler?()
                    }
                })
            }
        }
    }
    
    func interstitialDidPresent(unitID: String?) {
        self.interstitialContext?.didPresentAction?()
    }
    
    func interstitialDidDismiss(unitID: String?) {
        if unitID != nil {
            self.requestInterstitial(unitID: unitID!)
        }
        self.interstitialContext?.didDismissAction?()
        self.interstitialContext?.didEndAction?(false)
    }
    
    //
    func openAdDidReceiveAd() {
        guard canPresentLaunchAd else { return }
        
        self.isLaunchAdProcessed = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.ad?.presentOpenAd(from: Util.topViewController())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.loadingViewContainer.hide()
            })
            
            // 开屏广告消失，回调
            let time = self.becomeActiveTime
            self.openAdDidDismissedAction = { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if self?.becomeActiveTime == time {
                        self?.launchAdEndedHandler?()
                    }
                })
            }
        }
    }
    
    func openAdDidPresent() {
        //
    }
    
    func openAdDidDismiss() {
        self.openAdDidDismissedAction?()
    }
    
    //
    func rewardAdDidFail() {
        self.perform(#selector(requestRewardAd), with: nil, afterDelay: Interval.requestInterval(adType: .reward))
    }
    
    func rewardAdDidPresent() {
        self.rewardAdContext?.didPresentAction?()
    }
    
    func rewardAdDidRewardUser() {
        if let key = self.rewardAdContext?.signalKey {
            Counter.find(key: key).reset()
        }
        
        self.rewardAdContext?.didRewardUserAction?()
    }
    
    func rewardAdDidDismiss() {
        self.rewardAdContext?.didDismissAction?()
        self.rewardAdContext?.didEndAction?(false)
        self.requestRewardAd()
    }
}

// MARK: - Private

extension Ad {
    
    private func setupAd() {
        guard let options = (self.onlinePlatformOptions ?? self.initialPlatformOptions), self.currentPlatformOptions != options else {
            return
        }
        
        let isFirstSetup = (self.currentPlatformOptions == nil)
                
        if options.delay == 0 || isFirstSetup {
            performSetupAd()
        }
        else {
            self.perform(#selector(performSetupAd), with: nil, afterDelay: options.delay)
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSetupAd), object: nil)
    }
    
    @objc private func performSetupAd() {
        guard let options = (self.onlinePlatformOptions ?? self.initialPlatformOptions), self.currentPlatformOptions != options else {
            return
        }
        
        let isFirstSetup = (self.currentPlatformOptions == nil)
        
        switch options.platform {
        case .Admob:
            self.ad = AdmobAd()
        case .Facebook:
            self.ad = FacebookAd()
        case .ByteDance:
            self.ad = ByteDanceAd()
            if let adAppID = options.adAppID {
                BUAdSDKManager.setTerritory(Util.countryCode().contains("CN") ? .CN : .NO_CN)
                BUAdSDKManager.setAppID(adAppID)
            }
        }
        
        self.ad?.setup(bannerUnitID: options.defaultBannerUnitID, interstitialUnitIDs: options.interstitialAllUnitIDs, rewardAdUnitID: options.rewardAdUnitID, openAdUnitID: options.openAdUnitID)
        if self.isEnabled {
            self.ad?.setupInterstitials()
        }
        
        self.currentPlatformOptions = options
        
        if isFirstSetup {
            if shouldRequestOpenAd {
                self.ad?.requestOpenAd()
            }
        }
        else { // 更换广告平台
            for container in self.bannerContainers { // 替换之前的banner广告
                if let banner = self.ad?.createBanner(rootViewController: container.value?.rootViewController, size: self.adaptiveBannerSize) {
                    container.value?.banner = banner
                }
            }
        }
    }
    
    var canPresentLaunchAd: Bool {
        return self.isEnabled &&
            self.launchKey != nil &&
            self.hasEnterBackground == false &&
            self.isLaunchAdProcessed == false &&
            self.exceedsMaxLoadingTime() == false
    }
    
    var shouldRequestOpenAd: Bool {
        return Preset.named("S.Ad.openAdEnabled").boolValue
    }
    
    private func anyReadyInterstitialUnitID(signalKey: String) -> String? {
        if let unitID = currentPlatformOptions?.interstitialSignalKeyToSpecifiedUnitID?[signalKey], self.ad?.isInterstitialReady(unitID: unitID) == true {
            return unitID
        }
        
        for unitID in currentPlatformOptions?.interstitialAllUnitIDs ?? [] {
            if self.ad?.isInterstitialReady(unitID: unitID) == true {
                return unitID
            }
        }
        
        return nil
    }
    
    @objc private func requestInterstitial(unitID: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(requestInterstitial(unitID:)), object: unitID)
        
        if self.isEnabled == false {
            return
        }
        
        self.ad?.requestInterstitial(unitID: unitID)
    }

    @objc public func requestRewardAd() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(requestRewardAd), object: nil)
        
        if self.isEnabled == false {
            return
        }
        
        self.ad?.requestRewardAd()
    }
    
    private func exceedsMaxLoadingTime() -> Bool {
        return Date().timeIntervalSince(self.launchTime) > self.loadingViewContainer.maxLoadingTime
    }
    
    private var onlinePlatformOptions: PlatformOptions? {
        var options = Preset.named("S.Ad.platform")
        if options == JSON.null {
            options = Preset.named("S.Ad.platformOptions")
        }
        
        guard options["platform"].exists(), let platform = Platform(rawValue: options["platform"].intValue) else {
            return nil
        }

        let adAppID = options["adAppID"].string
        let bannerUnitID = options[AdType.banner.rawValue].string
        let interstitialUnitID = options[AdType.interstitial.rawValue].string
        let rewardUnitID = options[AdType.reward.rawValue].string
        let delay = options["delay"].doubleValue
        
        return PlatformOptions(platform: platform, adAppID: adAppID, defaultBannerUnitID: bannerUnitID, defaultInterstitialUnitID: interstitialUnitID, rewardAdUnitID: rewardUnitID, delay: delay)
    }
    
    private func showRewardAdAlert(key: String, alertDataKey: String, waitTime: Int, handler: @escaping (_ result: RewardAdResult) -> Void) {
        let data = Preset.named(alertDataKey)
        let message = String(format: data["message"].stringValue, Util.appName(), Util.appName(), Util.appName())
        let alert = UIAlertController(title: data["title"].string, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: data["cancel"].stringValue, style: .cancel, handler: { _ in
            handler(.alertCanceled)
        }))
        
        let okAction = RewardAdAlertAction(title: data["ok"].stringValue, style: .default, handler: { _ in
            if self.isRewardAdReady == false {
                handler(.stillNotReady)
            }
            else {
                let ctx = Ad.default.rewardAdSignal(key: key)
                
                var rewarded = false
                ctx.didRewardUserAction = {
                    rewarded = true
                }
                
                ctx.didDismissAction = {
                    handler(rewarded ? .rewarded : .adCanceled)
                }
            }
        })
        alert.addAction(okAction)
        
        if isRewardAdReady == false && waitTime > 0 {
            okAction.wait(for: waitTime)
        }
        
        Util.topViewController().present(alert, animated: true, completion: nil)
    }
    
    private func showPopupImageAdIfNeeded() {
        if popupImageAd.canShowAd {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                popupImageAd.show(in: rootVC.view)
            }
        }
    }
    
    private func canTopViewControllerPresentAd() -> Bool {
        if let top = Util.topViewControllerOptional() {
            return (top is UIAlertController) == false
        }
        
        return false
    }
}

// MARK: - Internal class
    
extension Ad {
    
    public class Context {
        public typealias BoolAction = (_ bool: Bool) -> Void
        public typealias VoidAction = () -> Void
        
        public private(set) var signalKey: String?
        public fileprivate(set) var adSkipped = false
        public fileprivate(set) var counterHitsMax = false
        
        public var didPresentAction: VoidAction?
        public var didRewardUserAction: VoidAction?
        public var didDismissAction: VoidAction?
        public var didEndAction: BoolAction? // (adSkipped: Bool) -> Void. Called after the Ad is skipped or the Ad controller dismissed
        
        init(signalKey: String? = nil) {
            self.signalKey = signalKey
        }
    }
}
