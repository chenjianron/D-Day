#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Nothing.h"
#import "OCHelper.h"

FOUNDATION_EXPORT double ToolkitVersionNumber;
FOUNDATION_EXPORT const unsigned char ToolkitVersionString[];

