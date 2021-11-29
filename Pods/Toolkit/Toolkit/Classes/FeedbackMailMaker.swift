//
//  ContactUsViewController.swift
//  CalculatorVault
//
//  Created by Tracy on 20/07/2017.
//  Copyright © 2017 Tracy. All rights reserved.
//

import Foundation
import MessageUI

public class FeedbackMailMaker: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = FeedbackMailMaker()
    
    private var mailComposeControlerToDismissAction = [UIViewController: (() -> Void)]()
    
    public func presentMailComposeViewController(from controller: UIViewController, recipient: String? = nil, bodyComponents: ((_ components: [String]) -> [String])? = nil, dismissAction: (() -> Void)? = nil) {
        let c = MFMailComposeViewController()
        c.mailComposeDelegate = self
        
        c.setSubject(subject())
        
        if let emailRecipient = recipient {
            c.setToRecipients([emailRecipient])
        }
        
        var components = self.mailBodyComponents()
        if bodyComponents != nil {
            components = bodyComponents!(components)
        }
        c.setMessageBody(components.joined(separator: "\n"), isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            controller.present(c, animated: true)
            
            if dismissAction != nil {
                self.mailComposeControlerToDismissAction[c] = dismissAction!
            }
        }
        else {
            if #available(iOS 13.0, *) {
                presentNoAcountAlert(from: controller)
            }
        }
    }
    
    private func presentNoAcountAlert(from controller: UIViewController) {
        let alertController = UIAlertController(title: __("无邮件账户"), message: __("请设置邮件账户来发送电子邮件"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: __("好"), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        controller.present(alertController, animated: true)
    }
    
    private func mailBodyComponents() -> [String] {
        let device = UIDevice.current
        let systemInfo = "System: \(device.systemName) (\(device.systemVersion))"
        
        //
        let model = "Device: \(Util.deviceModel())"
        
        //
        let appName = Util.appName()
        let version = Util.appVersion()
        let appInfo = "\(appName) version: \(version)"
        
        //
        let languageAndCountry = "Local: \(Util.languageCode()) (\(Util.countryCode()))"
        
        //
        let breaks = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        return [breaks, systemInfo, model, appInfo, languageAndCountry].filter{ $0 != "" }
    }
    
    private func subject() -> String {
        if let r = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return r
        }

        if let r = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return r
        }
    
        return ""
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let dismissAction = self.mailComposeControlerToDismissAction[controller]
        self.mailComposeControlerToDismissAction.removeValue(forKey: controller)
        controller.dismiss(animated: true, completion: dismissAction)
    }
}
