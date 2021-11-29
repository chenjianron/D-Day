//
//  STHelper.m
//  MarketingHelper
//
//  Created by Endless Summer on 2020/8/21.
//

#import "STHelper.h"
#import <UMPush/UMessage.h>
#import <UMCommon/MobClick.h>

@implementation STHelper

+ (void)registerForRemoteNotificationsWithLaunchOptions:(NSDictionary * __nullable)launchOptions completionHandler:(void (^ __nullable)(BOOL granted, NSError *_Nullable error))completionHandler {
    UMessageRegisterEntity* entity = [[UMessageRegisterEntity alloc] init];
    entity.types = UMessageAuthorizationOptionSound|UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert;
    
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:completionHandler];
}

+ (void)beginLogPageView:(NSString *)pageName {
    [MobClick beginLogPageView:pageName];
}

+ (void)endLogPageView:(NSString *)pageName {
    [MobClick endLogPageView:pageName];
}

@end
