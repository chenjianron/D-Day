//
//  HADImagePopupAd.swift
//  AdLib
//
//  Created by Kevin on 2019/12/12.
//

import Foundation

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

public class HADImagePopupAd: NSObject {
    
    public private(set) var dataKey: String // 在线参数名称
    
    public private(set) var limitedUntilDate: Date {
        set {
            UserDefaults.standard.set(newValue, forKey: self.limitedUntilDateKey)
        }
        get {
            UserDefaults.standard.value(forKey: self.limitedUntilDateKey) as? Date ?? Date.distantPast
        }
    }
    
    var limitedUntilDateKey: String {
        return "UD.HADImagePopupAd.limitedUntilDate.\(self.dataKey)"
    }
    
    var adItems = [AdItem]()
    lazy var adItemIndex: Int = {
        return Int(arc4random()) % self.adItems.count
    }()
    var imagePopupAdView: HADImagePopupAdView?
    var minInterval: TimeInterval = 0
    
    struct AdItem {
        var id: String
        var maxTaps: Int
        var maxViews: Int
        var image: String?
        var link: String?
        var isTestAd: Bool
        
        var btnText: String?
        var btnTextColor: UIColor?
        var btnColor: UIColor?
    }

    // dataKey 为 preset 参数名称
    // 参数如 { minInterval, items: [{id, maxTaps, maxViews, image, link, btnText, btnTextColor, btnColor}] }
    public init(dataKey: String) {
        self.dataKey = dataKey
        super.init()
        
        NotificationCenter.default.addObserver(forName: JSONUpdatedNotification, object: nil, queue: .main) { [weak self] (_) in
            DispatchQueue.main.async {
                self?.updateAdItems()
            }
        }
        
        self.updateAdItems()
    }
    
    public func show(in superview: UIView) {
        if self.canShowAd == false {
            return
        }
        
        adItemIndex = (adItemIndex + 1) % availableAdItems.count
        let adItem = availableAdItems[adItemIndex]
        
        imagePopupAdView?.removeFromSuperview()
        
        imagePopupAdView = HADImagePopupAdView(adItem: adItem)
        superview.addSubview(imagePopupAdView!)
        imagePopupAdView?.snp.remakeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        let adItemId = adItem.id
        HAD_UD.increaseAdViews(id: adItemId)
        imagePopupAdView?.adTappedAction = { popupAdView in
            HAD_UD.increaseAdTaps(id: adItemId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                popupAdView.removeFromSuperview()
            }
        }
        
        self.limitedUntilDate = Date().addingTimeInterval(self.minInterval)
    }
    
    public var canShowAd: Bool {
        return self.limitedUntilDate.compare(Date()) == .orderedAscending && self.availableAdItems.count > 0
    }
}

extension HADImagePopupAd {
    func updateAdItems() {
        let data = Preset.named(self.dataKey)
        self.minInterval = data["minInterval"].doubleValue
        
        let rawAds = data["items"].arrayValue
        var adItems = [AdItem]()
        for rawAd in rawAds {
            if let id = rawAd["id"].string {
                let item = AdItem(id: id,
                                  maxTaps: rawAd["maxTaps"].int ?? 2,
                                  maxViews: rawAd["maxViews"].int ?? 5,
                                  image: rawAd["image"].string,
                                  link: rawAd["link"].string,
                                  isTestAd: rawAd["isTest"].bool ?? false,
                                  btnText: rawAd["btnText"].string,
                                  btnTextColor: UIColor(hex: Int(rawAd["btnTextColor"].stringValue, radix: 16) ?? 0x333333),
                                  btnColor: UIColor(hex: Int(rawAd["btnColor"].stringValue, radix: 16) ?? 0xffffff)
                                  )
                adItems.append(item)
            }
        }

        self.adItems = adItems
    }
    
    var availableAdItems: [AdItem] {
        return self.adItems.filter({ self.isAdItemAvailable($0) })
    }
    
    func isAdItemAvailable(_ adItem: AdItem) -> Bool {
        return HAD_UD.adTaps(id: adItem.id) < adItem.maxTaps && HAD_UD.adViews(id: adItem.id) < adItem.maxViews
    }
}
