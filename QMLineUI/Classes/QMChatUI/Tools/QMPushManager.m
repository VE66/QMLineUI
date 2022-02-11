//
//  QMPushManager.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import "QMPushManager.h"

@implementation QMPushManager

+ (instancetype)share {
    static QMPushManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QMPushManager new];
    });
    return manager;
}

@end
