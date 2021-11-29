//
//  BUCNLocation.h
//  BUCNAuxiliary
//
//  Created by bytedance on 2020/9/3.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BUVALocation : NSObject
@property (atomic, strong, readonly) NSNumber *latitude;
@property (atomic, strong, readonly) NSNumber *longitude;
+ (instancetype)locationService;
- (void)requestLatestStatus;
@end

NS_ASSUME_NONNULL_END
