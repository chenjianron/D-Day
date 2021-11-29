//
//  Nothing.m
//  iMusic
//
//  Created by Tina on 2017/10/11.
//  Copyright © 2017年 Team. All rights reserved.
//

#import "Nothing.h"

@implementation Nothing

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [NSMethodSignature signatureWithObjCTypes:"v@"];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //
}

@end
