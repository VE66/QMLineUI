//
//  QMRegex.h
//  Demo-C
//
//  Created by ZCZ on 2021/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMRegex : NSObject
// 手机+座机位置
+ (NSArray <NSTextCheckingResult *>*)getMobileNumberLoc:(NSString *)text;
// 座机
+ (NSArray <NSTextCheckingResult *>*)getTelephoneLoc:(NSString *)text;
// 是不是手机号，不好座机
+ (BOOL)isMobileNumber:(NSString *)mobile;
@end

NS_ASSUME_NONNULL_END
