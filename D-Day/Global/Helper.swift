//
//  Helper.swift
//  CatTranslator
//
//  Created by GC on 2021/9/2.
//

import UIKit
import Photos
import Toolkit

public class Helper {
    
    public class func getRootViewController() -> UIViewController? {
        if let window = UIApplication.shared.delegate?.window {
            if let rootViewController = window?.rootViewController {
                return rootViewController
            }
        }
        return nil
    }
    public class func inChina() -> Bool {
        let standard = UserDefaults.standard
        let allLanguages: [String] = standard.object(forKey: "AppleLanguages") as! [String]
        let currentLanguage = allLanguages.first ?? ""
        return currentLanguage.contains("zh")
    }
    public class func getCurrentLanguage() -> String {
        let standard = UserDefaults.standard
        let allLanguages: [String] = standard.object(forKey: "AppleLanguages") as! [String]
        return allLanguages.first ?? "zh-CN"
    }
    public class func openURL(_ withString:String, failure:(@escaping() -> Void) = { }){
        if let url = URL(string: withString) {
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            failure()
        }
    }
}

extension Helper {
    public class func accessPhoto(withHandler: @escaping () -> Void){
        var isAuthorized:Bool? {
            didSet {
                DispatchQueue.main.async {
                    if (isAuthorized != nil) && isAuthorized! {
                        withHandler()
                    } else {
                        showPhotosAuthorizationAlert()
                    }
                }
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization{ (status) in
                if status == .authorized {
                    isAuthorized = true
                }
            }
        case .authorized:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    public class func showPhotosAuthorizationAlert(){
        if let viewController = Optional(Util.topViewController()){
            let alertController = UIAlertController(title: __("无法访问照片"), message: __("您需要设置允许应用访问“照片”权限才可以使用"), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: __("取消"), style: .default, handler: nil)
            let confirmAction = UIAlertAction(title: __("去设置"), style: .cancel){ (action) in
                openURL(UIApplication.openSettingsURLString)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}





