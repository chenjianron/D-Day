//
//  Constant.swift
//  SplitScreen
//
//  Created by  HavinZhu on 2020/7/27.
//  Copyright © 2020 HavinZhu. All rights reserved.
//
import UIKit
import Toolkit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let isiPhoneX = ScreenWidth >= 375 && ScreenHeight >= 812

struct K {
    
    struct IDs {
        static let AppID = "1597073250"
        
        static let SSID = "j1mkk6dmocvrqum7"
        static let SSKey = "ei5gzyf1irkoyen9"
        static let SSRG = "oss-cn-hongkong"
        
        static let UMengKey = "61650290d884567d81c9496d"
        static let Secret = "DDay/\(Util.appVersion())/meto.otf"
        static let adMobAppId = "ca-app-pub-1526777558889812~7399811085"
        
//        #if DEBUG
        static let BannerUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let InterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
        static let InterstitialTransferUnitID = "ca-app-pub-3940256099942544/4411468910"
//        #else
//           static let BannerUnitID = "ca-app-pub-1526777558889812/1847089745"
//           static let InterstitialUnitID = "ca-app-pub-1526777558889812/8437560585"
//           static let InterstitialSaveUnitID = "ca-app-pub-1526777558889812/2412381748"
//        #endif
    }
    
    struct Share {
        static let normalContent = String(format: "https://itunes.apple.com/cn/app/id%@?mt=8&l=%@", K.IDs.AppID, Util.languageCode())
        static let Email = "LoveAndDay@outlook.com"
    }
    
    struct NotificationName {
        static let RefreshBookmark = NSNotification.Name("RefreshBookmark")
        static let UserAgentDidChange = NSNotification.Name("UserAgentDidChange")
    }
    
    struct Website {
        static let PrivacyPolicy = "https://websprints.github.io/D-DayCouple/PrivacyPolicy"
        static let UserAgreement = "https://websprints.github.io/D-DayCouple/UserAgreement"
    }
    
    struct Color {
        static let ThemeColor = UIColor(hex: 0xFF7DB4)
        static let FirstLevelColor = UIColor(hex: 0x222222)
        static let SecondLevelColor = UIColor(hex: 0x666666)
        static let AuxiliaryColor = UIColor(hex: 0x999999)
        static let SplitLineColor = UIColor(hex: 0xF1F1F1)
    }
    
    struct AppGroups {
        static let Identifier = "group.com.D-Day"
    }
    
    struct AppGroupsKey {
        static let ManHead = "ManName"
        static let WomenHead = "WomenName"
        static let PresetAnniversaryKey = "PresetAnniversaryKey"
    }
    
    struct UserDefaultsKey {
        static let IsFirstLaunch = "IsFirstLaunch"
        static let FirstKnowingTime = "FirstKnowingTime"
        static let IsFromZero = "IsFromZero"
        static let Password = "Password"
        static let IsSettingPassword = "IsSettingPassword"
        static let IsFaceIDorTouchID = "IsFaceIDorTouchID"
        static let IsConfirmID = "IsFaceIDorTouchID"
        static let AnniversaryPath = "AnniversaryPath"
    }
    
    struct ParamName {
        
        static let IDFA_Time = "S.Ad.广告跟踪二次弹窗时间"
        static let IDFA_Count = "S.Ad.广告跟踪二次弹窗次数"
        
        static let HomePageBanner = "S.Ad.首页" // 首页广告栏控制开关
        static let SettingPageBanner = "S.Ad.设置页" // 设置页广告栏控制开关
        static let EditPageBanner = "S.Ad.编辑页"
        
        static let LaunchInterstitial = "p1-1" // 每N次启动弹出插屏广告
        static let SwitchInterstitial = "p1-2" // 每N次进入前台弹出插屏广告
        static let AddNoteInterstitial = "p1-3"
        static let DeleteAnniversaryInterstitial = "p1-4"
        static let EditSaveAnniversaryInterstitial = "p1-5"
        static let ConfirmAddAnniversaryInterstitial = "p1-6"
        
        static let ShareRT = "p2-1" //分享后返回设置页弹窗
        static let AddAnniversarySuccessRT = "p2-2" //添加纪念日成功后弹窗
        static let EnterRT = "p2-3" //启动/返回应用弹窗
        
        static let pushAlertDays = "p3-1" // 用户未允许通知提醒，每隔N天后弹出通知提醒
        static let RTTime = "p3-2"  //评论间隔小时
        
    }
}


