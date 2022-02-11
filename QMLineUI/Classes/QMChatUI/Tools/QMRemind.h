//
//  QMRemind.h
//  QMLineDemo
//
//  Created by lishuijiao on 2020/5/20.
//  Copyright © 2020 Lisj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMRemind : NSObject

/// 提示   默认时间5秒
/// @param message 文字
+ (void)showMessage:(NSString *)message;

/// 提示
/// @param message 文字
/// @param time 展示时间
+ (void)showMessage:(NSString *)message
           showTime:(NSInteger)time;

/// 提示
/// @param message 文字
/// @param time 展示时间
/// @param position 展示的位置--距顶部的高度
+ (void)showMessage:(NSString *)message
           showTime:(NSInteger)time
        andPosition:(CGFloat)position;

@end

NS_ASSUME_NONNULL_END
