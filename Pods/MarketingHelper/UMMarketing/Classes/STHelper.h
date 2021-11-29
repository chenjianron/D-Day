//
//  STHelper.h
//  MarketingHelper
//
//  Created by Endless Summer on 2020/8/21.
//

#import <Foundation/Foundation.h>
@class UMessageRegisterEntity;
NS_ASSUME_NONNULL_BEGIN

@interface STHelper : NSObject

+ (void)registerForRemoteNotificationsWithLaunchOptions:(NSDictionary * __nullable)launchOptions completionHandler:(void (^ __nullable)(BOOL granted, NSError *_Nullable error))completionHandler;

+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

@end

NS_ASSUME_NONNULL_END
