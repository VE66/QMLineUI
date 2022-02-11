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

#import "QMAgent.h"
#import "QMChatFileTextAttachment.h"
#import "QMConnect.h"
#import "QMEvaluation.h"
#import "QMLineDelegate.h"
#import "QMLineError.h"
#import "QMLineSDK.h"
#import "QMMessage.h"
#import "QMSessionOption.h"

FOUNDATION_EXPORT double QMLineSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char QMLineSDKVersionString[];

