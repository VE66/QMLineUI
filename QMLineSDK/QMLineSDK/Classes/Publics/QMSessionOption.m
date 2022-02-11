//
//  QMSessionOption.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/29.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMSessionOption.h"

@implementation QMSessionOption

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

+ (instancetype)initWithVipAgentNum:(NSString *)number {
    QMSessionOption *option = [[QMSessionOption alloc] init];
    [option setVipAgentNum:number];
    return option;
}

+ (instancetype)initWithExtend:(NSDictionary *)dicionary {
    QMSessionOption *option = [[QMSessionOption alloc] init];
    [option setExtend:dicionary];
    return option;
}

+ (instancetype)initWithExtend:(NSDictionary *)dictionary vipAgentNum:(NSString *)number {
    QMSessionOption *option = [[QMSessionOption alloc] init];
    [option setVipAgentNum:number];
    [option setExtend:dictionary];
    return option;
}

@end
