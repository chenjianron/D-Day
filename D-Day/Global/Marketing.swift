//
//  Marketing.swift
//  Remote
//
//  Created by Coloring C on 2021/3/23.
//

import Foundation
import Toolkit
import StoreKit
import SwiftyJSON
import AdLib
import MarketingHelper

class BannerWrap {
    
    let presetKey: String
    let homeKey: String
    var view: UIView?
    
    init(presetKey: String, homeKey: String) {
        self.presetKey = presetKey
        self.homeKey = homeKey
    }
}

class Marketing {
    
    static let shared = Marketing()
    private var bannerViews: [Banner : BannerWrap] = [:]

    var enterForegroundAdEndedHandler: (() -> Void)?
    
    enum Banner {
        case homeBanner
        case settingBanner
        case EditPageBanner
    }
    
    func setup() {
        // UMeng
        UMConfigure.initWithAppkey(K.IDs.UMengKey, channel: "App Store")
        
        RT.default.setup(appID: K.IDs.AppID)
        
        // 初始化在线参数
        JSON.setupPMs(id: K.IDs.SSID,
                      key: K.IDs.SSKey ,
                      region: K.IDs.SSRG,
                      secret: K.IDs.Secret)
        // Params
        Preset.default.setup(defaults: [
                                        K.ParamName.IDFA_Count: 0,
                                        K.ParamName.IDFA_Time: 72,
                                        
                                        K.ParamName.HomePageBanner : 1,
                                        K.ParamName.SettingPageBanner : 1,
                                        K.ParamName.EditPageBanner : 1,
                                        
                                        K.ParamName.LaunchInterstitial : 5,
                                        K.ParamName.SwitchInterstitial : 5,
                                        K.ParamName.AddNoteInterstitial: 10,
                                        K.ParamName.DeleteAnniversaryInterstitial: 10,
                                        K.ParamName.EditSaveAnniversaryInterstitial:10,
                                        K.ParamName.ConfirmAddAnniversaryInterstitial:10,
            
                                        K.ParamName.ShareRT: 1,
                                        K.ParamName.AddAnniversarySuccessRT: 2,
                                        K.ParamName.EnterRT: 5,
       ])
        
        MarketingHelper.presentUpdateAlert()
        
        // 插屏Ad设置ID
        Ad.default.setup(bannerUnitID: K.IDs.BannerUnitID, interstitialUnitID: K.IDs.InterstitialUnitID, openAdUnitID: nil, rewardAdUnitID: nil, isEnabled: true)
        
        let view = SimpleLoadingView(logo: UIImage.icon)
        view.backgroundColor = .white
        view.logoImageView.snp.remakeConstraints { (make) in
            let width = min(UIScreen.main.bounds.size.width * 0.25, 120)
            make.width.height.equalTo(Util.isIPad ? width : 72)
            make.center.equalToSuperview()
        }
        view.logoImageView.layer.cornerRadius = 16
        view.loadingLabel.text = nil
        
        //设置插屏参数的key
        Ad.default.setupLaunchInterstitial(launchKey: K.ParamName.LaunchInterstitial, enterForegroundKey: K.ParamName.SwitchInterstitial, loadingView: view)
        Ad.default.launchAdEndedHandler = {
            guard let handler = self.enterForegroundAdEndedHandler else {
                return
            }
            handler()
        }

        // Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didLaunchOrEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        bannerViews[.homeBanner] = .init(presetKey: K.ParamName.HomePageBanner, homeKey: K.ParamName.HomePageBanner)
        bannerViews[.settingBanner] = .init(presetKey: K.ParamName.SettingPageBanner, homeKey: K.ParamName.SettingPageBanner)
        bannerViews[.EditPageBanner] = .init(presetKey: K.ParamName.EditPageBanner, homeKey: K.ParamName.EditPageBanner)
    }
}

// MARK: - Public
extension Marketing {
    
    func bannerView(_ type: Banner, rootViewController: UIViewController) -> UIView? {
        
        guard let wrap: BannerWrap = bannerViews[type] else { return nil }
        if wrap.view == nil && Preset.named(wrap.presetKey).boolValue {
            wrap.view = Ad.default.createBannerView(rootViewController: rootViewController, houseAdID: wrap.homeKey)
        }
        return wrap.view
    }
    
}

// MARK: - Private
extension Marketing {
    
    func showNotificationIfNeed() {
        
        let counter = Counter.find(key: K.ParamName.pushAlertDays)
        counter.increase()
        if counter.hitsMax && Preset.default.named(K.ParamName.pushAlertDays)["title"].stringValue.count > 0 {
            showNotifcationAlert(from: Util.topViewController(), data: Preset.named(K.ParamName.pushAlertDays))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let d = Preset.named(K.ParamName.pushAlertDays).intValue
            let interval = 24 * 60 * 60 * d
            counter.pausedUntilDate = Date().addingTimeInterval(TimeInterval(interval))
        }
    }
    
    // MARK: - 评论
    func didShareRT() {
        
        let rtCounter = Counter.find(key: K.ParamName.ShareRT)
        rtCounter.increase()
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
            rtCounter.pausedUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
    
    func didAddAnniversarySuccessRT() {
        
        let rtCounter = Counter.find(key: K.ParamName.AddAnniversarySuccessRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
            rtCounter.pausedUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
    
    @objc func didLaunchOrEnterForeground() {

        let rtCounter = Counter.find(key: K.ParamName.EnterRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
            rtCounter.pausedUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
}

// MARK: - helper
extension Marketing {
    
    public func showNotifcationAlert(from controller: UIViewController, data: JSON) {
        
        let title = data["title"].stringValue
        
        let appName = Util.appName()
        let messageFormat = data["message"].stringValue
        let message = String.init(format: messageFormat, appName, appName, appName, appName, appName)
        
        let ok = data["ok"].stringValue
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancel = data["cancel"].string {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString){
                if (UIApplication.shared.canOpenURL(url)){
                    UIApplication.shared.open(url, options: [:]) { (success) in}
                }
            }
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
}
