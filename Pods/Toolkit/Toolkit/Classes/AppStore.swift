//
//  AppStore.swift
//  AdLib
//
//  Created by Kevin on 2019/11/12.
//

import Foundation
import StoreKit
import JGProgressHUD

@available(iOSApplicationExtension, unavailable)
public class AppStore: NSObject {
    public static var shared = AppStore()
    
    var storeVC: SKStoreProductViewController?
    
    public func open(appID: String, inApp: Bool) {
        if inApp == false {
            self.open(appID: appID)
            return
        }
        
        let hud = JGProgressHUD(style: .dark)
        hud.isUserInteractionEnabled = false
        hud.show(in: Util.topViewController().view, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hud.dismiss(animated: true)
        }
        
        storeVC = SKStoreProductViewController()
        storeVC?.delegate = self
        storeVC?.loadProduct(withParameters: [
            SKStoreProductParameterITunesItemIdentifier: appID
        ]) { [weak self] (result, _) in
            hud.dismiss(animated: true)
            
            guard let `self` = self, let storeVC = self.storeVC else {
                return
            }
            
            if result {
                if Util.topViewController().isKind(of: SKStoreProductViewController.self) {
                    return
                }
                Util.topViewController().present(storeVC, animated: true, completion: nil)
            }
            else {
                self.open(appID: appID)
            }
        }
    }
    
    func open(appID: String) {
        if let url = URL(string: "https://itunes.apple.com/us/app/id\(appID)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

@available(iOSApplicationExtension, unavailable)
extension AppStore: SKStoreProductViewControllerDelegate {
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
