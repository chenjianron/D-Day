//
//  BUVAPrivacy.h
//  BUVAAuxiliary
//
//  Created by bytedance on 2020/9/2.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTTelephonyNetworkInfo;

NS_ASSUME_NONNULL_BEGIN

@interface BUVAPrivacy : NSObject
///开启定位
+ (void)requestLatestStatus;
///设置隐私控制
+ (void)bu_setPrivacyInfo:(NSDictionary *)privacyInfo;
///0 (不进行 ad 请求/上报) 1 (执行 ad 请求/上报）3300 add
+ (NSInteger)bu_AdEnable;
///0不下发广告 1下发非个性化 2下发个性化）3300 add
+ (NSInteger)bu_personalized_ad;
///0(不初始化) 1(初始化) - 目前不支持GDPR，之后sdk合入新版本后，依据版本号打开  3300 add
+ (NSInteger)bu_sladar_enable;
///0(不初始化) 1(初始化) - 目前不支持GDPR）3300 add
+ (NSInteger)bu_app_log_enable;
///0(不初始化) 1(初始化) ）3300 add
+ (NSInteger)bu_sec_enable;
///隐私字段白名单3300 add
+ (NSArray *)bu_fields_allowed_array;
///隐私字段白名单）3300 add
+ (BOOL)bu_fields_allowed:(NSString *)key;
///获取隐私字段
+ (id)bu_getInformation:(NSString *)key;
/// 设置用户自定义IDFA
+ (void)bu_setCustomIDFA:(NSString *)IDFA;
///获取原始idfa
+ (NSString *)bu_getOriginalIDFA;


///设置设备网络信息类
+ (void)bu_setTelephonyNetworkInfoWithBlock:(CTTelephonyNetworkInfo *(^)(void))block;

+ (void)bu_setTestLongitude:(NSNumber *)testLongitude;///用来测试的，十分不想要，能删就删
+ (void)bu_setTestLatitude:(NSNumber *)testLatitude;///用来测试的，十分不想要，能删就删
@end

NS_ASSUME_NONNULL_END
