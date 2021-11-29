# Toolkit

[![CI Status](https://img.shields.io/travis/Kevin/Toolkit.svg?style=flat)](https://travis-ci.org/Kevin/Toolkit)
[![Version](https://img.shields.io/cocoapods/v/Toolkit.svg?style=flat)](https://cocoapods.org/pods/Toolkit)
[![License](https://img.shields.io/cocoapods/l/Toolkit.svg?style=flat)](https://cocoapods.org/pods/Toolkit)
[![Platform](https://img.shields.io/cocoapods/p/Toolkit.svg?style=flat)](https://cocoapods.org/pods/Toolkit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Toolkit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Toolkit'
```

## Usage

- [运营-本地推送功能 (MarkitingLocalPush.swift)] (http://git.flowever.net/component/Toolkit/blob/master/Toolkit/Classes/MarkitingLocalPush.swift)

需要在线参数添加「S.Ad.运营本地推送」配合使用
```JSON
{"nextDayPush":"1","sevenDayPush":"1","thirtyDayPush":"1","nextDayAfterFirstLaunched":{"title":{"zh-Hans":"叮咚🔔幸福来敲门","zh-Hant":"叮咚🔔幸福來敲門","others":"Knock Knock🔔The Pursuit of Happiness","ja":"トントン🔔幸せのちから","ko":"똑똑🔔행복이 두드리면"},"content":{"zh-Hans":"今天发生了什么趣事快记录下来吧🗒️","zh-Hant":"今天發生了什麽趣事快記錄下來吧🗒️","others":"Write down any interesting things that happened today🗒️","ja":"今日は何がおかしいの？それを書き留め🗒️","ko":"오늘 무슨 재밌었 어? 서둘러 적어🗒️"},"hour":0,"minute":0},"sevenDaysNotLaunched":{"title":{"zh-Hans":"宝贝想你啦💗","zh-Hant":"寶貝想你啦💗","others":"Miss u bae💗","ja":"あいたい💗","ko":"보고싶어💗"},"content":{"zh-Hans":"恋爱清单好久没更新啦～点击更新>>","zh-Hant":"恋爱清单好久没更新啦～点击更新>>","others":"Your love list hasn't been updated for a long time","ja":"愛のリストは長い間更新されていません～","ko":"오랫동안 사랑 목록이 업데이트되지 않았습니다～"},"hour":0,"minute":0},"thirtyDaysTimeInterval":{"title":{"zh-Hans":"惊喜降临🎁","zh-Hant":"驚喜降臨🎁","others":"Surprise🎁","ja":"意外な驚き🎁","ko":"예기치 않은 놀라움🎁"},"content":{"zh-Hans":"又过了一个月啦，看看离纪念日还有多久呢>>","zh-Hant":"又過了一個月啦，看看離紀念日還有多久呢>>","others":"Another month has passed, let’s see how long it’s until the anniversary？","ja":"もう一ヶ月経ちましたが、記念日はどれくらいですか？","ko":"한 달이 지났으니 기념일까지 얼마나 남았는지 보자？"},"day":0,"hour":0,"minute":0}}
```
> 
- nextDayPush：次日推送开关
- sevenDayPush：7天不活跃推送开关
- thirtyDayPush：次月1号推送开关
- nextDayAfterFirstLaunched：次日推送详情
- sevenDaysNotLaunched：7天不活跃推送详情
- thirtyDaysTimeInterval：次月推送详情
- title：推送标题
- content：推送内容
- day：日期(仅次月推送)
- hour：小时
- minute：分钟`

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    ...
    
    // 营销逻辑 - 本地推送
    if #available(iOS 10.0, *) {
        MarkitingLocalPush.localPushNotification()
    }
    
    ...
    
}
```

## Author

Kevin, this@tracycool.com

## License

Toolkit is available under the MIT license. See the LICENSE file for more info.
