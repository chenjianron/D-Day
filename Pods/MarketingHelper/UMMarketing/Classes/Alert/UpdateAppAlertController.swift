//
//  UpdateAppAlertController.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/9/18.
//

import Foundation
#if canImport(Toolkit) //
import Toolkit
#elseif canImport(DCGKit) // DCG
import DCGKit
#endif
import SDWebImage

open class UpdateAppAlertController: UIViewController {
    
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

extension UpdateAppAlertController {
    
    @discardableResult
    public static func presentIfNeed() -> Bool {
        prefetchImage()
        
        if !shouldUpdate() {
            return false
        }
        let json = Preset.named(key)["parameter"]
        
        let model = MarketingAlertHelper(alertType: .updateApp, json: json)
        
        let present = model.detectShouldPresentAlert()
        if present {
            DispatchQueue.main.async {
                let vc = UpdateAppAlertController()
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
    static func shouldUpdate() -> Bool {
        let version = Preset.named(key)["version"].stringValue
        return version.isVersion(greaterThan: Util.appVersion())
    }
}

private extension UpdateAppAlertController {
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func upgradeButtonTapped() {
        dismiss(animated: true) {
            self.openAppStore()
        }
    }
    
    private func openAppStore() {
        if let url = Util.appStoreURL {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

private extension UpdateAppAlertController {
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.addSubviews(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(290)
        }
    }

    func setupData() {
        let key = UpdateAppAlertController.key
        let json = Preset.named(key)["data"]
        let model = MarketingAlertModel(json: json)
        
        contentView.updateModel(model)
        
    }
    
    static let key = "S.Ad.更新弹窗"
}
