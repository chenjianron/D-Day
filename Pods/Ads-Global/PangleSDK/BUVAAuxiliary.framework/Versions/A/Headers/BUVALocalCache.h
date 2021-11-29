//
//  BUVALocalCache.h
//  BUVAAuxiliary
//
//  Created by bytedance on 2020/8/28.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUVALocalCache : NSObject
///BUAdDeepLinkActionManager
+ (NSString *)bu_TrackInfoDicKey;
///dpl跳转时间戳持久化key
+ (NSString *)bu_LastDeeplinkJumpTimeKey;
///BUAdSDKManager
+ (NSString *)bu_IS_GDPR_USER_key;
///BUAdSDKManager
+ (NSString *)bu_GDPR_key;
///BUAdSDKManager
+ (NSString *)bu_CONSENT_URL_key;
///BUAdSDKManager
+ (NSString *)bu_DY_ENGINE_URL_key;
///BUNetworkRequest
+ (NSString *)bu_NET_CONFIG_TNC_CMD;
///BUNetworkRequest
+ (NSString *)bu_NET_CONFIG_TNC_VERSION;
///BUUSettingService
+ (NSString *)bu_SettingKey;
@end

NS_ASSUME_NONNULL_END
