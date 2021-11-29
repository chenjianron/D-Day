//
//  HADImageAd.swift
//  Ad
//
//  Created by Kevin on 2019/4/4.
//

import UIKit

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

import SwiftyJSON

public class HADImageBannerAd: NSObject {
    
    public private(set) var dataKey: String // 在线参数名称
    
    struct AdItem {
        var id: String
        var maxTaps: Int
        var maxViews: Int
        var image: String?
        var link: String?
        var duration: TimeInterval
        var isTestAd: Bool
    }
    
    var bannerView: HADImageAdBannerView?
    var adItems = [AdItem]()
    var adItemIndex = 0
    enum SetupAction {
        case initial, JSONUpdated, loadNext
    }
    
    var enteredBackground = false
    
    // dataKey 为 preset 参数名称
    // 参数如 { items: [{id, maxTaps, maxViews, image, link, duration}] }
    public init(dataKey: String) {
        self.dataKey = dataKey
        super.init()
        
        NotificationCenter.default.addObserver(forName: JSONUpdatedNotification, object: nil, queue: .main) { [weak self] (_) in
            DispatchQueue.main.async {
                self?.setup(action: .JSONUpdated)
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.enteredBackground = true
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] (_) in
            self?.enteredBackground = false
        }
    }
    
    public func show(in superview: UIView) {
        let banner = self.bannerView ?? HADImageAdBannerView()
        superview.addSubview(banner)
        banner.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        banner.adTappedAction = { banner in
            if let adItem = banner.currentAdItem {
                HAD_UD.increaseAdTaps(id: adItem.id)
            }
        }
        
        self.bannerView = banner
        
        DispatchQueue.main.async {
            self.setup(action: .initial)
        }
    }
}

// MARK: - Private

extension HADImageBannerAd {
    func setup(action: SetupAction) {
        // 处理 bannerView未显示到屏幕 情况
        if self.isBannerViewVisible() == false {
            switch action {
            case .initial, .loadNext:
                self.loadNextAfterDelay(5)
            case .JSONUpdated:
                break
            }
            return
        }
        
        //
        self.updateAdItems()
               
        // 切换广告
        if self.adItems.count == 0 {
            self.bannerView?.currentAdItem = nil
        }
        else {
            self.adItemIndex = (self.adItemIndex + 1) % adItems.count
            let newAdItem = self.adItems[adItemIndex]
            
            self.bannerView?.currentAdItem = newAdItem
            let views = HAD_UD.increaseAdViews(id: newAdItem.id)
            self.bannerView?.testLabel.text = String(views)
        }
        
        // 定时下次切换广告
        if let adItem = self.bannerView?.currentAdItem {
            self.loadNextAfterDelay(adItem.duration)
        }
    }
    
    func loadNextAfterDelay(_ delay: TimeInterval) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadNext), object: nil)
        self.perform(#selector(loadNext), with: nil, afterDelay: delay)
    }
    
    @objc func loadNext() {
        self.setup(action: .loadNext)
    }
    
    func updateAdItems() {
        let rawAds = Preset.named(self.dataKey)["items"].arrayValue
        var adItems = [AdItem]()
        for rawAd in rawAds {
            if let id = rawAd["id"].string {
                let item = AdItem(id: id,
                                  maxTaps: rawAd["maxTaps"].int ?? 2,
                                  maxViews: rawAd["maxViews"].int ?? 5,
                                  image: rawAd["image"].string,
                                  link: rawAd["link"].string,
                                  duration: rawAd["duration"].double ?? 30,
                                  isTestAd: rawAd["isTest"].bool ?? false)
                
                if isAdItemAvailable(item) {
                    adItems.append(item)
                }
            }
        }
        
        self.adItems = adItems
    }
    
    func isAdItemAvailable(_ adItem: AdItem) -> Bool {
        if adItem.id.lowercased() == "banner" {
            return true
        }
        
        return HAD_UD.adTaps(id: adItem.id) < adItem.maxTaps && HAD_UD.adViews(id: adItem.id) < adItem.maxViews
    }
    
    func isBannerViewVisible() -> Bool {
        if self.bannerView == nil || self.bannerView?.window == nil || self.enteredBackground {
            return false
        }
        
        var v: UIView? = self.bannerView
        while v != nil {
            if v?.isHidden == true {
                return false
            }
            v = v?.superview
        }
        
        return true
    }
}
