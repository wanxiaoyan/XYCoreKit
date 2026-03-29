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

#import "XYCoreKit.h"
#import "XYImageLoader.h"
#import "XYImageLoaderConfig.h"
#import "XYImageTransformer.h"
#import "XYNetWorkConfig.h"
#import "XYNetworkManager.h"
#import "XYNetworkRequest.h"
#import "XYNetworkRespose.h"

FOUNDATION_EXPORT double XYCoreKitVersionNumber;
FOUNDATION_EXPORT const unsigned char XYCoreKitVersionString[];

