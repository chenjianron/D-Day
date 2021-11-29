# MarketingHelper

使用教程

## 营销逻辑: 系统通知弹窗

```swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 必须在调用 UMConfigure.initWithAppkey("UMengKey", channel: "App Store") 之后才可以调用
    MarketingHelper.setupNotification(launchOptions: launchOptions)
}

```


## 数据埋点: 路径统计

```swift

调用 MarketingHelper.regiterTrackPage

需要统计的 UIViewController 实现 TrackPageProtocol 协议

可以通过设置 MarketingHelper.logEnable = true 查看统计 log


```

## 更新弹窗

```swift

MarketingHelper.presentUpdateAlert()


```