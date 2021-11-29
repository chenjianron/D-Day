//
//  MarketingAlertController.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/10/14.
//

import Foundation
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKirt) // DCG
import DCGKit
#endif
import SDWebImage

open class MarketingAlertController: UIViewController {
    
    private lazy var contentView: MarketingAlertView = {
        let view = MarketingAlertView()
        view.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.actionButton.addTarget(self, action: #selector(upgradeButtonTapped), for: .touchUpInside)
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIViewController 生命周期
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
    }
    
}

extension MarketingAlertController {
    
    @discardableResult
    public static func presentIfNeed() -> Bool {
        prefetchImage()
        
        if !shouldPresent() {
            return false
        }
        let json = Preset.named(key)["parameter"]
        
        let model = MarketingAlertHelper(alertType: .activity, json: json)
        
        let present = model.detectShouldPresentAlert()
        if present {
            DispatchQueue.main.async {
                let vc = MarketingAlertController()
                Util.topViewController().present(vc, animated: true)
            }
        }
        return present
    }
    
    static func prefetchImage() {
        if let url = Preset.named(key)["data"]["imageUrl"].url {
            SDWebImagePrefetcher.shared.prefetchURLs([url])
        }
    }
    
    /// 当前版本比线上版本旧
    static func shouldPresent() -> Bool {
        let countryCodes = Preset.named(key)["country"].arrayValue.compactMap { $0.string }
        let languageCodes = Preset.named(key)["language"].arrayValue.compactMap { $0.string }
        if countryCodes.isEmpty, languageCodes.isEmpty {
            return true
        }
        let datas = [(countryCodes, Util.countryCode()),
                     (languageCodes, Util.languageCode())]
        for (array, code) in datas {
            if !code.isEmpty, !array.isEmpty, !array.contains(code) {
                return false
            }
        }
        return true
    }
}

private extension MarketingAlertController {
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func upgradeButtonTapped() {
        dismiss(animated: true) {
            self.openAppStore()
        }
    }
    
    private func openAppStore() {
        if let appID = Preset.named(MarketingAlertController.key)["appid"].string {
            AppStore.shared.open(appID: appID, inApp: false)
        }
        else if let url = Preset.named(MarketingAlertController.key)["url"].url {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

private extension MarketingAlertController {
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.addSubviews(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(290)
        }
    }

    func setupData() {
        let key = MarketingAlertController.key
        let json = Preset.named(key)["data"]
        let model = MarketingAlertModel(json: json)
        
        contentView.updateModel(model)
        
    }
    
    static let key = "S.Ad.运营弹窗"
}

/*
 {
     "appid": "0000",
     "url": "https://www.qq.com",
     "country": [
         "CN"
     ],
     "parameter": {
         "launchTimes": 4,
         "maxShownTimes": 3,
         "daysInterval": 3
     },
     "data": {
         "imageUrl": "https://wx4.sinaimg.cn/large/006a0Rdhgy1fux60ynypij30u0190ais.jpg",
         "imageRatio": 1.5,
         "buttonCornerRadius": 10,
         "title": "更新弹窗",
         "message": "更新内容\n 1、做什么\n 2、怎么做",
         "button_title": {
             "others": "Settings",
             "zh-Hans": "设置",
             "zh-Hant": "設置",
             "ja": "設定",
             "ko": "설정",
             "fr": "paramètres",
             "de": "Einstellungen",
             "es": "Ajustes",
             "it": "Impostazioni",
             "pt": "estabelecimento",
             "ru": "настройки"
         },
         "title_color": "#32C5FF",
         "button_color": "#FFFFFF",
         "buttonBackground_color": "#32C5FF",
         "close_button_color": "#32C5FF"
     }
 }
 */
