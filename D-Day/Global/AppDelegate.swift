//
//  AppDelegate.swift
//  D-Day
//
//  Created by GC on 2021/10/9.
//

import UIKit
import WidgetKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var viewController:UIViewController!
                               
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if !AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFirstLaunch) {
            viewController = PreviewPageViewController()
            viewController = DDNavigationViewController(rootViewController: viewController)
//            AppStorageGroupsManager.default.setValue(true, forKey: K.UserDefaultsKey.IsFirstLaunch)
        } else {
            if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsSettingPassword){
                viewController = SettingPasswordViewController()
                (viewController as! SettingPasswordViewController).isSetting = false
                (viewController as! SettingPasswordViewController).firstLauchAppCompletion = {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = DDNavigationViewController(rootViewController: MainViewController())
                }
            } else {
                viewController = MainViewController()
                viewController = DDNavigationViewController(rootViewController: viewController)
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        Marketing.shared.setup()
        Marketing.shared.enterForegroundAdEndedHandler = {
            AppTracking.shared.requestIDFA {
        //                (UIApplication.shared.delegate as! AppDelegate).setupNotification(launchOptions: nil)
                self.setupNotification(launchOptions: nil)
                }
        }
        
        return true
    }
}

// MARk: -友盟推送
extension AppDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
        @available(iOS 14, *)
          func reloadTimelines(_ kind: String) {
            #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
            #endif
          }
    }
    
    func setupNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIApplication.shared.applicationIconBadgeNumber = 0
            let entity = UMessageRegisterEntity()
            entity.types = Int(UMessageAuthorizationOptions.alert.rawValue)
                   | Int(UMessageAuthorizationOptions.sound.rawValue)
                   | Int(UMessageAuthorizationOptions.badge.rawValue)
            UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity, completionHandler: { (granted, error) in
                LLog("推送: ", granted)
                if let error = error {
                    LLog(error.localizedDescription)
               }
            })
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       UMessage.registerDeviceToken(deviceToken)
       
       #if DEBUG
       print(#function, "deviceToken", NotificationHandler.deviceToken(deviceToken) ?? "")
       #endif
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LLog(error)
    }
   
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationHandler.process(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationHandler.process(userInfo: userInfo)
    }
}
