//
//  BUNetWorkConstant.h
//  BUVAAuxiliary
//
//  Created by bytedance on 2020/8/26.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUVANetWorkConstant : NSObject
///设置地区
+ (void)setTerritory:(NSString *)territory;
///获取地区
+ (NSString *)territory;
#pragma mark - 广告域名
/// 广告默认域名  非中国区
+ (NSString *)bu_URL_BASE_AD;
/// 请求联盟广告的 服务器地址
+ (NSString *)bu_URI_UnionAd;
/// 激励视频播放完成上报接口
+ (NSString *)bu_URI_RewardedVideoPlayFinish;
/// 开屏缓存数据验证接口
+ (NSString *)bu_URI_SplashCheckCacheVaild;
/// 广告频控报警
/// V1.9.3 SDK开屏新增埋点 SDK目前开屏展示率较低，为了方便排查及针对开屏广告位切换新的展示率计算方式，需要新增埋点统计；
/// V1.9.8 新增原生广告埋点,请求数据到获得数据的事件
+ (NSString *)bu_URI_Stats;
/// 2700 stats替代接口，支持批量上传，@available(V2.7.0.0, *)
+ (NSString *)bu_URI_Batch;
/// 网盟 setting 接口 V1.9.5 新加接口(旧接口放弃维护) https://wiki.bytedance.net/pages/viewpage.action?pageId=217636563
+ (NSString *)bu_URI_Setting;
/// Dislike 上报接口
+ (NSString *)bu_URI_Dislike;
#pragma mark - 埋点域名
+ (NSString *)bu_URL_BASE_Extlog;
/// 测试包ET平台上报地址
+ (NSString *)bu_URL_BASE_Extlog_ForETTest;
#pragma mark - TNC域名
+ (NSArray<NSString*> *)bu_URL_BASE_TNC;
/// TNC get - domin
+ (NSString *)bu_URI_TNC_GetDomins;
#pragma mark - Other
+ (NSString *)bu_URL_template;
///GDPR合规协议兜底地址
+ (NSString *)bu_GDPR_URL;
@end

NS_ASSUME_NONNULL_END
