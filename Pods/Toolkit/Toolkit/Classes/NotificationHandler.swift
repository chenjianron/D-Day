//
//  NotificationHandler.swift
//  AdLib
//
//  Created by Kevin on 2019/8/12.
//

import Foundation
import SwiftyJSON

public class NotificationHandler {
    
    public static func deviceToken(_ data: Data) -> String? {
        #if DEBUG
        if #available(iOS 13.0, *) {
            return OCHelper.deviceTokenUMengPush(data)
        }
        else {
            let nsdataStr = NSData(data: data)
            let datastr = nsdataStr.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
            return datastr
        }
        #else
        return nil
        #endif
    }
    
    @available(iOSApplicationExtension, unavailable)
    public static func process(userInfo: [AnyHashable : Any]) {
        let json = JSON(userInfo)
        
        let title = json["title"].string ?? ""
        if let message = json["message"].string ?? json["content"].string, let cancelTitle = json["cancel"].string, let okTitle = json["ok"].string, let link = json["link"].string?.toURL() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
                if #available(iOSApplicationExtension 10.0, *) {
                    UIApplication.shared.openURL(link)
                } else {
                    //
                }
            }))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Util.topViewController().present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// 应用内打开网页链接
    @available(iOSApplicationExtension, unavailable)
    public static func processInApp(userInfo: [AnyHashable : Any], methodHandler: ((String) -> Void)?) {
        let json = JSON(userInfo)
        
        let showAlert = json["showAlert"].string ?? "0"
        
        var method = json["method"]
        if method.type == .string, let string = method.string {
            method = JSON(parseJSON: string)
        }
        
        guard let type = method["type"].string else { return }
        let content = method["content"].string

        func dueAction() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if type == "link", let link = content?.toURL() {
                    let nav = UINavigationController(rootViewController: InAppWebViewController(url: link))
                    nav.modalPresentationStyle = .fullScreen
                    Util.topViewController().present(nav, animated: true, completion: nil)
                } else {
                    methodHandler?(type)
                }
            }
        }
        
        if showAlert == "1" {
            let title = json["title"].string ?? ""
            if let message = json["message"].string ?? json["content"].string, let cancelTitle = json["cancel"].string, let okTitle = json["ok"].string {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (_) in
                    dueAction()
                }))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Util.topViewController().present(alert, animated: true, completion: nil)
                }
            }
        } else {
            dueAction()
        }
    }
}
