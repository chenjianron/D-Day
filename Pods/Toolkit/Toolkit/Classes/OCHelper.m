//
//  OCHelper.m
//  AdLib
//
//  Created by Kevin on 2020/3/6.
//

#import "OCHelper.h"

@implementation OCHelper

+ (NSString*)deviceTokenUMengPush:(NSData*)data {
    if (![data isKindOfClass:[NSData class]]) return NULL;
    const unsigned *tokenBytes = (const unsigned *)[data bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hexToken;
}

@end
