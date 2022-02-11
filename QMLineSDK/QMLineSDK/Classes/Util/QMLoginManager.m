//
//  QMLoginManager.m
//  QMLineSDK
//
//  Created by haochongfeng on 2019/2/25.
//  Copyright © 2019年 haochongfeng. All rights reserved.
//

#import "QMLoginManager.h"
#import "QMServiceFunction.h"

@implementation QMLoginManager

+ (instancetype)shared {
    static QMLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)isExistChat:(NSString *)sid completion:(void(^)(void))completion failure:(void(^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetAleardyChatSession:sid completion:^(NSDictionary *object) {
        [[QMServiceFunction sharedInstance] tryStartNewChatSession:@"" params:@{} vipTrue:NO completion:^(BOOL remark, NSString *chatId) {
            completion();
        } failure:^{
            failure();
        }];
    } failure:^{
        
        if (self.isManual == true) {
            failure();
            return;
        }
        
        if (self.isSchedule) {
            // 日程
            [self verifySchedule:^{
                [[QMServiceFunction sharedInstance] tryStartNewChatSession:self.scheduleId processId:self.processId currentNodeId:self.processTo entranceId:self.entranceId params:self.parameters vipTrue:NO completion:^(BOOL remark, NSString *chatId) {
                    completion();
                } failure:^{
                    failure();
                }];
            } failure:^{
                failure();
            }];
        }else {
            // 技能组
            [self verifyPeers:^{
                [[QMServiceFunction sharedInstance] tryStartNewChatSession:self.peerId params:self.parameters vipTrue: NO completion:^(BOOL remark, NSString *chatId) {
                    completion();
                } failure:^{
                    failure();
                }];
            } failure:^{
                failure();
            }];
        }
    }];
}

- (void)verifyPeers: (void(^)(void))success failure: (void(^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetPeers:^(NSArray *array) {
        BOOL isExist = NO;
        if (array) {
            for (NSDictionary *peer in array) {
                NSString *pId = [peer objectForKey:@"id"];
                if (pId && [pId isEqualToString:self.peerId] && ![self.peerId isEqualToString:@""]) {
                    isExist = YES;
                }
            }
        }
        if (isExist) {
            success();
        }else {
            failure();
        }
    } failure:^{
        failure();
    }];
}

- (void)verifySchedule: (void(^)(void))success failure: (void(^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetWebchatScheduleConfig:^(NSDictionary *dictionary) {
//        NSLog(@"获取到了日程---%@",dictionary);
        NSString *newScheduleId = [dictionary objectForKey:@"scheduleId"];
        NSString *newProcessId = [dictionary objectForKey:@"processId"];
        NSDictionary *entranceNode = [dictionary objectForKey:@"entranceNode"];
        NSArray *entrances = [entranceNode objectForKey:@"entrances"];
        
        BOOL isExist = NO;
        if (newScheduleId && newProcessId && entranceNode && entrances) {
            if (![newScheduleId isEqualToString:@""] && ![newProcessId isEqualToString:@""]) {
                for (NSDictionary *entrance in entrances) {
                    NSString *newProcessTo = [entrance objectForKey:@"processTo"];
                    NSString *newId = [entrance objectForKey:@"_id"];
                    if (newProcessTo && ![newProcessTo isEqualToString:@""]) {
                        if (newId && ![newId isEqualToString:@""]) {
                            if ([self.scheduleId isEqualToString:newScheduleId] && [self.processId isEqualToString:newProcessId] && [self.entranceId isEqualToString:newId] && [self.processTo isEqualToString:newProcessTo]) {
                                isExist = YES;
                            }
                        }
                    }
                }
            }
        }
        if (isExist) {
//            NSLog(@"存在这个日程  =========================================================");
            success();
        }else {
//            NSLog(@"不存在这个日程  =========================================================");
            failure();
        }
    } failure:^{
//        NSLog(@"请求日程信息失败了 =========================================================");
        failure();
    }];
}

@end
