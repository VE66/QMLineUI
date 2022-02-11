//
//  QMLoginManager.h
//  QMLineSDK
//
//  Created by haochongfeng on 2019/2/25.
//  Copyright © 2019年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMLoginManager : NSObject

@property (nonatomic, assign) BOOL isSchedule;

@property (nonatomic, assign) BOOL isManual;

@property (nonatomic, copy) NSString *peerId;

@property (nonatomic, copy) NSString *scheduleId;

@property (nonatomic, copy) NSString *processId;

@property (nonatomic, copy) NSString *entranceId;

@property (nonatomic, copy) NSString *processTo;

@property (nonatomic, strong) NSDictionary *parameters;

/**
 单例

 @return 实例化
 */
+ (instancetype)shared;

/**
 会话是否存在

 @param sid sid
 @param completion 成功
 @param failure 失败
 */
- (void)isExistChat: (NSString *)sid completion: (void(^)(void))completion failure: (void(^)(void))failure;

@end

NS_ASSUME_NONNULL_END
