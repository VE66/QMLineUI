//
//  QMServiceBase.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/11/1.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMServiceBase.h"
#import "QMGlobaMacro.h"
#import "QMNetworkManager.h"

@implementation QMServiceBase

+ (instancetype)sharedInstance {
    static QMServiceBase *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.array = [NSMutableArray array];
        instance.dic = [NSMutableDictionary dictionary];
    });
    return instance;
}

#pragma mark - 开始会话(技能组)
- (void)newChatSession:(NSString *)peerId params:(NSDictionary *)params vipTrue:(BOOL)vipTrue completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    BOOL isNewVisitor;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"visitor"]) {
        isNewVisitor = NO;
    }else {
        isNewVisitor = YES;
    }

    
    NSDictionary *parameter = @{
                                @"Action"              :@"sdkBeginNewChatSession",
                                @"ConnectionId"        :connectId,
                                @"IsNewVisitor"        :[NSNumber numberWithBool:isNewVisitor],
                                @"ToPeer"              :peerId,
                                @"sdkIosVersionCode"   :[NSNumber numberWithFloat:custom_version],
                                @"AccessId"            :[QMGlobaMacro shared].custom_accessId
                                };
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    if (vipTrue) {
        [parameters setValue:[NSNumber numberWithBool:vipTrue] forKeyPath:@"vipAcceptOtherPeer"];
    }
    
    if (params) {
        for (NSString *key in params.allKeys) {
            if ([params objectForKey:key]) {
                [parameters setValue:[params objectForKey:key] forKey:key];
            }
        }
    }
    
//    NSLog(@"开始会话Params ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"开始会话Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 开始会话(日程管理)
- (void)newChatSession:(NSString *)scheduleId processId:(NSString *)processId currentNodeId:(NSString *)currentNodeId entranceId:(NSString *)entranceId params:(NSDictionary *)params vipTrue:(BOOL)vipTrue completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    BOOL isNewVisitor;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"visitor"]) {
        isNewVisitor = NO;
    }else {
        isNewVisitor = YES;
    }
    
    NSDictionary *parameter =  @{
                                 @"Action"             : @"sdkBeginNewChatSession",
                                 @"ConnectionId"       : connectId,
                                 @"IsNewVisitor"       : [NSNumber numberWithBool:isNewVisitor],
                                 @"scheduleId"         : scheduleId,
                                 @"processId"          : processId,
                                 @"currentNodeId"      : currentNodeId,
                                 @"entranceId"         : entranceId,
                                 @"sdkIosVersionCode"  : [NSNumber numberWithFloat:custom_version],
                                 @"AccessId"           : [QMGlobaMacro shared].custom_accessId
                                 };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    if (vipTrue) {
        [parameters setValue:[NSNumber numberWithBool:vipTrue] forKeyPath:@"vipAcceptOtherPeer"];
    }

    if (params) {
        for (NSString *key in params.allKeys) {
            if ([params objectForKey:key]) {
                [parameters setValue:[params objectForKey:key] forKey:key];
            }
        }
    }
    
//    NSLog(@"开始会话Params ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        NSLog(@"newBeginSessionscheduleId ==== %@", responseObject);
//        NSLog(@"开始会话Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 是否存在该会话
- (void)getAleardyChatSession:(NSString *)sid account:(NSString *)account completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    if (!account) {
        failure();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"Action"] = @"sdkGetChatSession";
    parameters[@"ConnectionId"] = connectId;
    parameters[@"sid"] = sid;
    parameters[@"account"] = account;
//    NSLog(@"是否存在该会话Params ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"是否存在该会话Data ==== %@", responseObject);
//        NSLog(@"AleardyChatData ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 获取会话全局配置
- (void)getWebchatGlobleConfig:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameters = @{
                                 @"Action"              :@"sdkGetWebchatGlobleConfig",
                                 @"ConnectionId"        :connectId,
                                 @"AccessId"            :[QMGlobaMacro shared].custom_accessId
                                 };

//    NSLog(@"获取全局配置Params ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"globalSetData ==== %@", responseObject);
        if ([responseObject[@"success"] boolValue] == YES) {
            completion(responseObject);
        }else {
            if (failure) {
                failure();
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

#pragma mark - 获取所有技能组
- (void)getPeers:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkGetPeers",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
//    NSLog(@"获取技能组Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"获取技能组Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 获取满意度评价
- (void)getInvestingations:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkGetInvestigate",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
//    NSLog(@"获取满意度评价Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"GetInvestigateData ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 获取未读消息
- (void)getUnreadMessageNumbers:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *mobileType = [QMGlobaMacro deviceModelName];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSDictionary *parameters = @{
                                 @"Action"            : @"sdkGetUndealMsgCount",
                                 @"AccessId"          : accessId ?: @"",
                                 @"Platform"          : mobileType ?: @"",
                                 @"DeviceId"          : deviceId ?: @"",
                                 @"NewVersion"        : @"true",
                                 @"UserId"            : userId ?: @"",
                                 @"UserName"          : userName ?: @"",
                                 @"sdkIosVersionCode" : [NSNumber numberWithFloat:custom_version],
//                                 @"ApnsDeviceId"      : @""
                                 };
    
//    NSLog(@"取未读消息Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"取未读消息Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 机器人客服转人工客服
- (void)convertManualWithPeerId:(NSString *)peerId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameter = @{
                                 @"Action"       : @"sdkConvertManual",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };

    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    if (peerId.length > 0) {
        [parameters setValue:peerId forKey:@"peerId"];
    }
//    NSLog(@"机器人转人工Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"机器人转人工Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - vip繁忙或不在线转接其他坐席
- (void)vipAgentConvertOtherAgent:(NSString *)peerId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameters = @{
                                 @"Action"            : @"sdkAcceptOtherAgent",
                                 @"ConnectionId"      : connectId,
                                 @"sdkIosVersionCode" : [NSNumber numberWithFloat:custom_version],
                                 @"ToPeer"            : peerId
                                 };

//    NSLog(@"vip坐席转接给其他坐席Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"vip坐席转接给其他坐席Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 提交满意度评价
- (void)submitInvestigation:(NSString *)name value:(NSString *)value completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkSubmitInvestigate",
                                 @"ConnectionId" : connectId,
                                 @"Name"         : name,
                                 @"Value"        : value,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
//    NSLog(@"提交满意度评价Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"提交满意度评价Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 提交满意度评价 包含二级标题和备注的评价
- (void)tryNewSubmitInvestigation:(NSString *)name value:(NSString *)value radioValue:(NSArray *)radioValue remark:(NSString *)remark way:(NSString *)way operation:(NSString *)operation sessionId:(NSString *)sessionId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    if (radioValue == nil) {
        radioValue = @[];
    }
    if (remark == nil) {
        remark = @"";
    }
    NSString *labels = @"";
    if (radioValue.count == 0) {
        labels = @"";
    }else if (radioValue.count == 1) {
        labels = radioValue[0];
    }else if (radioValue.count > 1) {
        for (NSString *index in radioValue) {
            labels = [labels stringByAppendingFormat:@"%@%@",index,@","];
        }
        labels = [labels substringToIndex:labels.length - 1];
    }
    
    NSMutableDictionary *parameters = @{
                                 @"Action"       : @"sdkSubmitInvestigate",
                                 @"ConnectionId" : connectId,
                                 @"Name"         : name,
                                 @"Value"        : value,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId,
//                                 @"Label"        : radioValue,
                                 @"Label"        : labels,
                                 @"Proposal"     : remark,
                                 @"way"          : way,
                                 }.mutableCopy;
    
    if (operation.length > 0) {
        [parameters setValue:operation forKey:@"operationDetail"];
    }
    if (sessionId.length > 0) {
        [parameters setValue:sessionId forKey:@"sessionId"];
    }
//        NSLog(@"提交满意度评价Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"提交满意度评价Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
    
}

#pragma mark - 提交留言(固定字段)
- (void)submitLeaveMessage:(NSString *)peerId phone:(NSString *)phone email:(NSString *)email content:(NSString *)content completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"      : @"sdkSubmitLeaveMessage",
                                 @"ConnectionId": connectId,
                                 @"ToPeer"      : peerId,
                                 @"Phone"       : phone,
                                 @"Email"       : email,
                                 @"Message"     : content,
                                 @"AccessId"    : [QMGlobaMacro shared].custom_accessId
                                 };
    
//    NSLog(@"提交留言Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"提交留言Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 提交留言(自定义字段)
- (void)submitLeaveMessage:(NSString *)peerId information:(NSDictionary *)information fields:(NSArray *)fields content:(NSString *)content completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    

    NSDictionary *parameter = @{
                                @"Action"         : @"sdkSubmitLeaveMessage",
                                @"ConnectionId"   : connectId,
                                @"ToPeer"         : peerId,
                                @"Message"        : content,
                                @"leavemsgFields" : fields,
                                @"AccessId"       : [QMGlobaMacro shared].custom_accessId
                                };
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:parameter];
    
    if (information.count > 0) {
        for (NSString *key in information) {
            NSString *value = [information[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSCharacterSet *customAllowedSet = [[NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"] invertedSet];
            NSString *temp = [value stringByAddingPercentEncodingWithAllowedCharacters:customAllowedSet];
            
            
//            NSString *value = [information[@"key"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//            NSCharacterSet *customAllowedSet = [[NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"] invertedSet];
//            NSString *temp = [value stringByAddingPercentEncodingWithAllowedCharacters:customAllowedSet];
            [parameters setValue:temp forKey:key];
        }
    }
    
//    NSLog(@"提交留言Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"提交留言Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 机器人帮助反馈
- (void)submitRobotFeedback:(NSString *)status questionId:(NSString *)questionId messageId:(NSString *)messageId robotType:(NSString *)robotType robotId:(NSString *)robotId robotMsgId:(NSString *)robotMsgId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
//    NSLog(@"这里 == %@", robotId);
    NSDictionary *parameters = @{
                                 @"Action"        : @"sdkSendRobotCsr",
                                 @"ConnectionId"  : connectId,
                                 @"questionId"    : questionId,
                                 @"feedback"      : status,
                                 @"AccessId"      : [QMGlobaMacro shared].custom_accessId,
                                 @"robotType"     : robotType,
                                 @"robotId"       : robotId ? robotId : @"",
                                 @"robotMsgId"    : robotMsgId
                                 };
    
//    NSLog(@"机器人帮助反馈Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"机器人帮助反馈Data ==== %@", responseObject);
        if ([responseObject[@"success"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 智能机器人满意度评价
- (void)SubmitIntelligentRobotSatisfaction:(NSString *)robotId satisfaction:(NSString *)satisfaction completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"         : @"sdkM7AiRobotCSRInfo",
                                 @"ConnectionId"   : connectId,
                                 @"botId"          : robotId,
                                 @"AccessId"       : [QMGlobaMacro shared].custom_accessId,
                                 @"whetherToSolve" : satisfaction,
                                 };
//    NSLog(@"智能机器人满意度评价Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//            NSLog(@"智能机器人满意度评价Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - xbot机器人帮助反馈
- (void)submitXbotRobotFeedback:(NSString *)status messageId:(NSString *)messageId robotId:(NSString *)robotId oriquestion:(NSString *)oriquestion question:(NSString *)question answer:(NSString *)answer confidence:(NSString *)confidence robotType:(NSString *)robotType robotSessionId:(NSString *)robotSessionId                      questionId:(NSString *)questionId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"        : @"sdkSendRobotCsr",
                                 @"ConnectionId"  : connectId,
                                 @"AccessId"      : [QMGlobaMacro shared].custom_accessId,
                                 @"feedback"      : status,
                                 @"sid"           : [QMGlobaMacro shared].custom_sessionId,
                                 @"robotId"       : robotId ? robotId : @"",
                                 @"ori_question"  : oriquestion,
                                 @"question"      : question,
                                 @"answer"        : answer,
                                 @"confidence"    : confidence,
                                 @"robotType"     : robotType,
                                 @"xbotSessionId" : robotSessionId,
                                 @"questionId"    : questionId,
                                 };
    
//    NSLog(@"xbot机器人帮助反馈Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"xbbot机器人帮助反馈Data ==== %@", responseObject);
        if ([responseObject[@"success"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - xbot机器人满意度评价
- (void)SubmitXbotRobotSatisfaction:(NSString *)satisfaction completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"         : @"sdkRobotCSRInfo",
                                 @"ConnectionId"   : connectId,
                                 @"AccessId"       : [QMGlobaMacro shared].custom_accessId,
                                 @"whetherToSolve" : satisfaction,
                                 };
//    NSLog(@"xbot机器人满意度评价Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"xbot机器人满意度评价Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
    
}

#pragma mark - xbot联想功能
- (void)SubmitXbotRobotAssociationInput:(NSString *)text cateIds:(NSArray *)cateIds robotId:(NSString *)robotId robotType:(NSString *)robotType completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

//    NSDictionary *parameters = @{
//                                 @"Action"         : @"sdkRobotInputSuggest",
//                                 @"ConnectionId"   : connectId ? : @"",
//                                 @"robotId"        : robotId,
//                                 @"robotType"      : robotType,
//                                 @"keyword"        : text,
//                                 @"cateIds"        : cateIds
//                                 };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"sdkRobotInputSuggest" forKey:@"Action"];
    [parameters setValue:connectId forKey:@"ConnectionId"];
    [parameters setValue:robotId forKey:@"robotId"];
    [parameters setValue:robotType forKey:@"robotType"];
    [parameters setValue:text forKey:@"keyword"];
    [parameters setValue:cateIds forKey:@"cateIds"];

    
    
//    NSLog(@"xbot联想功能Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"xbot联想功能Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 是否已经进行满意度评价
- (void)sdkGetImCsrInvestigate:(NSString *)chatId completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure{
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    NSDictionary *parameter = @{
                                @"Action"              :@"sdkGetImCsrInvestigate",
                                @"ConnectionId"        :connectId,
                                @"sdkIosVersionCode"   :[NSNumber numberWithFloat:custom_version],
                                @"AccessId"            :[QMGlobaMacro shared].custom_accessId,
                                @"SessionId"           :chatId
                                };
    
//    NSLog(@"是否已经进行满意度评价Param ==== %@", parameter);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameter success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"是否已经进行满意度评价Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

#pragma mark - 获取新消息
- (void)getNewMessage:(NSArray *)ids completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameters = @{
                                 @"Action"          :@"sdkGetMsg",
                                 @"ConnectionId"    :connectId,
                                 @"ReceivedMsgIds"  :ids,
                                 @"AccessId"        :[QMGlobaMacro shared].custom_accessId,
                                 };

//    NSLog(@"取新消息Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"newMessageData ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 发送新消息
- (void)sendMessage:(NSString *)type params:(NSDictionary *)params completion:(void (^)(NSDictionary *))completion failure:(void (^)(NSString *))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure(@"连接失败，请退出重新进入");
        return;
    }
    
    // TODO: 临时监控
    NSString *monitor = [NSString stringWithFormat:@"Dev=%@", [QMGlobaMacro deviceModelName]];
    NSDictionary *result = [QMGlobaMacro shared].monitorDict;
    if ([result objectForKey:@"success"]) {
        monitor = [monitor stringByAppendingString:[NSString stringWithFormat:@"Scs=%@", [result objectForKey:@"success"]]];
    }
    if ([result objectForKey:@"errMessage"]) {
        monitor = [monitor stringByAppendingString:[NSString stringWithFormat:@"Err=%@", [result objectForKey:@"errMessage"]]];
    }
    if ([result objectForKey:@"messageId"]) {
        monitor = [monitor stringByAppendingString:[NSString stringWithFormat:@"Id=%@", [result objectForKey:@"messageId"]]];
    }
    
    NSDictionary *parameter = @{
                                @"Action"        :@"sdkNewMsg",
                                @"ConnectionId"  :connectId,
                                @"ContentType"   :type,
                                @"AccessId"      :[QMGlobaMacro shared].custom_accessId,
                                @"MonitorSend"   :monitor,
                                @"MonitorRecv"   :[QMGlobaMacro shared].monitorContext
                                };

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    if (params) {
        [parameters addEntriesFromDictionary:params];

    }
    
//    NSLog(@"sendParam ==== %@", parameters);

//    NSLog(@"发送消息Param ==== %@", parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"发送消息Data ==== %@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
            QMGlobaMacro.shared.isSpeekMessage = true;
        }else {
            NSString *message = @"";
            if (responseObject[@"Message"]) {
                message = responseObject[@"Message"];
            }
            failure(message);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure(@"网络连接失败，请检查网络");
    }];

}

#pragma mark - 语音转文本
- (void)getVoiceToText:(NSString *)messageId accountId:(NSString *)accountId filePath:(NSString *)filePath when:(NSString *)when completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        return;
    }
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];


    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkVoiceToText",
                                 @"ConnectionId" : connectId,
                                 @"sid"          : sid,
                                 @"messageId"    : messageId,
                                 @"accountId"    : accountId,
                                 @"filePath"     : filePath,
                                 @"when"         : @([when integerValue]),
                                 @"platform"     : @"sdk"
                                 };
//    NSLog(@"语音转文本的para===%@",parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"语音转文本的Data===%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 获取七牛token
- (void)getQiniuToken:(NSString *)fileName completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"qiniu.getUptoken",
                                 @"ConnectionId" : connectId,
                                 @"fileName"     : fileName,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };

    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(responseObject);
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];

}

#pragma mark - 动态获取tcp地址和端口
- (void)getRequestAddress:(BOOL)main accessId:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId completion:(void (^)(NSString *))completion failure:(void (^)(void))failure {
    
    NSString *mobileType = QMGlobaMacro.deviceModelName;
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *parameters = @{
                                 @"Action"      : @"getTcpServiceAddress",
                                 @"Platform"    : mobileType,
                                 @"DeviceID"    : deviceID,
                                 @"AccessId"    : accessId,
                                 @"UserId"      : userId,
                                 @"UserName"    : userName,
                                 };
    
    NSString *baseURL = main ? sdkRequestUrlStr1 : sdkRequestUrlStr2;
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"动态获取tcp地址和端口===%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (responseObject[@"address"]) {
                completion(responseObject[@"address"]);
            }else {
                failure();
            }
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}


#pragma mark - 动态获取webScoket地址和端口
- (void)getRequestwebSocketAddress:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId completion:(void (^)(NSString *))completion failure:(void (^)(void))failure {
    
    NSString *mobileType = QMGlobaMacro.deviceModelName;
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *parameters = @{
                                 @"Action"      : @"getSdkSocketServiceAddress",
                                 @"Platform"    : mobileType,
                                 @"DeviceID"    : deviceID,
                                 @"AccessId"    : accessId,
                                 @"UserId"      : userId,
                                 @"UserName"    : userName,
                                 };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (responseObject[@"address"]) {
//                NSLog(@"动态获取tcp地址和端口===%@",responseObject);
                completion(responseObject[@"address"]);
            }else {
                failure();
            }
        }else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

@end
