//
//  QMServiceFunction.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMServiceFunction.h"
#import "QMGlobaMacro.h"
#import "QMNetworkManager.h"
#import "QMServiceBase.h"
#import "QMEvaluation.h"
#import "QMLoginManager.h"
#import "QMDataBase.h"
#import "QMTimerManager.h"
#import "QMWebSocketManager.h"
#import "QMServiceMessage.h"

@implementation QMServiceFunction

+ (instancetype)sharedInstance {
    static QMServiceFunction *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

# pragma mark -- 获取渠道全局设置中的globalSet
- (void)tryGetWebchatGlobleConfig:(void (^)(NSDictionary *))completion failure: (void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getWebchatGlobleConfig:^(NSDictionary *object) {
        id globalSet = object[@"globalSet"];
        if (globalSet) {

            NSData *data = [NSJSONSerialization dataWithJSONObject:globalSet options:0 error:0];
            [data writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMGlobalSets.plist"] atomically:YES];
        }
        if (completion) {
            completion(object);
        }
    } failure:failure];
    
}

# pragma mark -- 获取渠道全局设置中的scheduleConfig
- (void)tryGetWebchatScheduleConfig:(void (^)(NSDictionary *))completion failure: (void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getWebchatGlobleConfig:^(NSDictionary *object) {
//        NSLog(@" GlobleConfig---%@",object);
        id globalSet = object[@"globalSet"];
        if (globalSet) {

            NSData *data = [NSJSONSerialization dataWithJSONObject:globalSet options:0 error:0];
            [data writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMGlobalSets.plist"] atomically:YES];
        }
        
        [QMGlobaMacro shared].chatMode = QMChatModeNone;
        id scheduleConfig = object[@"scheduleConfig"];
        if (scheduleConfig) {
            if ([scheduleConfig[@"scheduleEnable"] intValue] == 1) {
                [QMGlobaMacro shared].chatMode = QMChatModeSchedule;
            }else{
                [QMGlobaMacro shared].chatMode = QMChatModePeers;
            }
            completion(scheduleConfig);
        }else {
            failure();
        }
    } failure:^{
        failure();
    }];

}

# pragma mark -- 根据key获取配置Value
- (id)tryGetGlobalValue:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMGlobalSets.plist"]]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMGlobalSets.plist"]];
    NSDictionary *configs = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:0];

//    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMGlobalSets.plist"]];
    
    if (!configs) {
        return nil;
    }
    
    return [configs objectForKey:key];
}

# pragma maek -- 根据key获取配置Value(开始新会话)
- (id)tryGetBeginSessionConfigValue:(NSString *)key {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMConfig.plist"]]) {
        return nil;
    }
    
    NSDictionary *configs = [NSDictionary dictionaryWithContentsOfFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMConfig.plist"]];
    
    if (!configs) {
        return nil;
    }
    
    return [configs objectForKey:key];
}

# pragma maek -- 获取xbot常见问题
- (id)tryGetBottomList:(NSString *)type {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"]]) {
        return @[];
    }

    NSArray *bottomList = [NSArray arrayWithContentsOfFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"]];
    
    if (bottomList.count < 1) {
        return @[];
    }
    return bottomList;
}

# pragma mark -- 获取技能组信息
- (void)tryGetPeers: (void (^)(NSArray *))completion failure: (void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getPeers:^(NSDictionary *objcet) {
        id peers = objcet[@"Peers"];
        if (peers) {
            completion(peers);
        }else {
            failure();
        }
    } failure:^{
        failure();
    }];
}

# pragma mark -- 开始新会话-技能组
- (void)tryStartNewChatSession:(NSString *)peerId params:(NSDictionary *)params vipTrue:(BOOL)vipTrue completion:(void (^)(BOOL, NSString *))completion failure:(void (^)(void))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (params.count > 0) {
        NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] init];
        for (NSString *key in params) {
            if ([key isEqualToString:@"customField"]) {
                NSString *jsonString = [QMGlobaMacro JSONString: params[key]];
                jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [tempParams setValue:jsonString forKey:@"customField"];
            }else {
                [tempParams setValue:params[key] forKey:key];
            }
        }
        if (tempParams.count > 0) {
            [parameters setValue:[QMGlobaMacro JSONString:tempParams] forKey:@"otherParams"];
        }
    }
    [QMLoginManager shared].isSchedule = false;
    [[QMServiceBase sharedInstance] newChatSession:peerId params:parameters vipTrue:(BOOL)vipTrue completion:^(NSDictionary *object) {
        BOOL webchat = NO;
        id config = object[@"Config"];
        if (config) {
            if (config[@"webchat_csr"]) {
                if ([config[@"webchat_csr"] isKindOfClass:[NSString class]]) {
                    if ([[config[@"webchat_csr"] stringValue] isEqualToString:@"1"]) {
                        webchat = YES;
                    }else {
                        webchat = NO;
                    }
                }else{
                    webchat = [config[@"webchat_csr"] boolValue];
                }
            }
            [QMLoginManager shared].peerId = peerId;
            [QMLoginManager shared].parameters = params;
            [config writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMConfig.plist"] atomically:true];
        }
        NSArray *bottomList = object[@"bottomList"];
        if (bottomList != nil) {
            [bottomList writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }else{
            [@[] writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }
        NSDictionary *session = object[@"chatSession"];
        NSString *chatId = @"";
        NSString *account = @"";
        if (session.count) {
            chatId = session[@"_id"];
            account = session[@"account"];
        }
        [QMGlobaMacro shared].account = account.length ? account : @"";
        
        NSArray *quickMenu = object[@"quickMenu"];
        NSNumber *quickMenuWhen = object[@"quickMenuWhen"];
        
        if (quickMenu.count > 0) {
            NSDictionary *quickDic = @{
                @"quickMenu"     : quickMenu,
                @"quickMenuWhen" : quickMenuWhen
            };
            [[QMDataBase shared] deleteListCard];
            [[QMServiceMessage sharedInstance] createMessageWithMessageType:@"listCard" filePath:nil content:nil metaData:quickDic];
        }
        
        completion(webchat, chatId);
    } failure:^{
        failure();
    }];
}

# pragma mark -- 开始新会话-技能组
- (void)tryStartNewChatSession:(NSString *)peerId
                        option:(QMSessionOption *)option
                    completion:(void (^)(BOOL, NSString *))completion
                       failure:(void (^)(void))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (option) {
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionary];
        
        if (option.vipAgentNum) {
            [tempParams setValue:option.vipAgentNum forKey:@"agent"];
        }
        
        if (option.extend) {
            NSString *jsonString = [QMGlobaMacro JSONString: option.extend];
            jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [tempParams setValue:jsonString forKey:@"customField"];
        }
        
        if (tempParams.count > 0) {
            [parameters setValue:[QMGlobaMacro JSONString:tempParams] forKey:@"otherParams"];
        }
    }
    
    [[QMServiceBase sharedInstance] newChatSession:peerId params:parameters vipTrue:NO completion:^(NSDictionary *object) {
        BOOL webchat = NO;
        id config = object[@"Config"];
        if (config) {
            if (config[@"webchat_csr"]) {
                if ([config[@"webchat_csr"] isKindOfClass:[NSString class]]) {
                    if ([[config[@"webchat_csr"] stringValue] isEqualToString:@"1"]) {
                        webchat = YES;
                    }else {
                        webchat = NO;
                    }
                }else{
                    webchat = [config[@"webchat_csr"] boolValue];
                }
            }
//            [QMLoginManager shared].peerId = peerId;
//            [QMLoginManager shared].parameters = params;
            [config writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMConfig.plist"] atomically:true];
        }
        NSArray *bottomList = object[@"bottomList"];
        if (bottomList != nil) {
            [bottomList writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }else {
            [@[] writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }
        NSDictionary *session = object[@"session"];
        NSString *chatId = @"";
        NSString *account = @"";
        if (session.count) {
            chatId = session[@"_id"];
            account = session[@"account"];
        }
        [QMGlobaMacro shared].account = account.length ? account : @"";
        
        NSArray *quickMenu = object[@"quickMenu"];
        NSNumber *quickMenuWhen = object[@"quickMenuWhen"];
        
        if (quickMenu.count > 0) {
            NSDictionary *quickDic = @{
                @"quickMenu"     : quickMenu,
                @"quickMenuWhen" : quickMenuWhen
            };
            [[QMDataBase shared] deleteListCard];
            [[QMServiceMessage sharedInstance] createMessageWithMessageType:@"listCard" filePath:nil content:nil metaData:quickDic];
        }

        completion(webchat, chatId);
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 开始新会话-日程管理
- (void)tryStartNewChatSession:(NSString *)scheduleId processId:(NSString *)processId currentNodeId:(NSString *)currentNodeId entranceId:(NSString *)entranceId params:(NSDictionary *)params vipTrue:(BOOL)vipTrue completion:(void (^)(BOOL, NSString *))completion failure:(void (^)(void))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (params.count > 0) {
        NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] init];
        for (NSString *key in params) {
            if ([key isEqualToString:@"customField"]) {
                NSString *jsonString = [QMGlobaMacro JSONString: params[key]];
                jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                jsonString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [tempParams setValue:jsonString forKey:@"customField"];
            }else {
                [tempParams setValue:params[key] forKey:key];
            }
        }
        if (tempParams.count > 0) {
            [parameters setValue:[QMGlobaMacro JSONString:tempParams] forKey:@"otherParams"];
        }
    }
    [QMLoginManager shared].isSchedule = true;
    [[QMServiceBase sharedInstance] newChatSession:scheduleId processId:processId currentNodeId:currentNodeId entranceId:entranceId params:parameters vipTrue:vipTrue completion:^(NSDictionary *object) {
        BOOL webchat = NO;
        id config = object[@"Config"];
        if (config) {
            if (config[@"webchat_csr"]) {
                if ([config[@"webchat_csr"] isKindOfClass:[NSString class]]) {
                    if ([[config[@"webchat_csr"] stringValue] isEqualToString:@"1"]) {
                        webchat = YES;
                    }else {
                        webchat = NO;
                    }
                }else{
                    webchat = [config[@"webchat_csr"] boolValue];
                }
            }
            [QMLoginManager shared].scheduleId = scheduleId;
            [QMLoginManager shared].processId = processId;
            [QMLoginManager shared].entranceId = entranceId;
            [QMLoginManager shared].processTo = currentNodeId;
            [QMLoginManager shared].parameters = params;
            [config writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMConfig.plist"] atomically:true];
        }
        NSArray *bottomList = object[@"bottomList"];
        if (bottomList != nil) {
            [bottomList writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }else{
            [@[] writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMBottomList.plist"] atomically:true];
        }
        NSDictionary *session = object[@"session"];
        NSString *chatId = @"";
        NSString *account = @"";
        if (session.count) {
            chatId = session[@"_id"];
            account = session[@"account"];
        }
        [QMGlobaMacro shared].account = account.length ? account : @"";
        
        NSArray *quickMenu = object[@"quickMenu"];
        NSNumber *quickMenuWhen = object[@"quickMenuWhen"];
        
        if (quickMenu.count > 0) {
            NSDictionary *quickDic = @{
                @"quickMenu"     : quickMenu,
                @"quickMenuWhen" : quickMenuWhen
            };
            [[QMDataBase shared] deleteListCard];
            [[QMServiceMessage sharedInstance] createMessageWithMessageType:@"listCard" filePath:nil content:nil metaData:quickDic];
        }

        completion(webchat, chatId);
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 是否存在该会话
- (void)tryGetAleardyChatSession:(NSString *)sid completion:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *account =  [self tryGetGlobalValue:@"account"];
    if (!account.length) {
        failure();
        return;
    }
    [[QMServiceBase sharedInstance] getAleardyChatSession:sid account:account completion:^(NSDictionary *object) {
        id dataDic = object[@"data"];
        if ([dataDic isKindOfClass:[NSDictionary class]]) {

            if (dataDic[@"_id"]) {
                completion(dataDic);
            }else{
                failure();
            }
        }else{
            failure();
        }
    } failure:^{
        failure();
    }];
}

# pragma mark -- vip对应坐席在线验证
- (void)tryVipAgentOnline:(NSString *)peer completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    if ([QMGlobaMacro shared].isRequest) {
        failure();
        return;
    }
    
    [QMGlobaMacro shared].isRequest = true;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [QMGlobaMacro shared].isRequest = false;
    });
    
    [[QMServiceBase sharedInstance] vipAgentConvertOtherAgent:peer completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- 获取满意度评价信息
- (void)tryGetInvestingations: (void (^)(NSArray *))completion failure: (void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getInvestingations:^(NSDictionary *objcet) {
        id list = objcet[@"List"];
        if (list) {
            completion(list);
        }else {
            failure();
        }
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 获取满意度评价信息-2.8.4新增
- (void)tryNewGetInvestingations: (void (^)(QMEvaluation *))completion failure: (void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getInvestingations:^(NSDictionary *objcet) {
        id list = objcet[@"List"];
        if (list) {
            
            QMEvaluation *model = [[QMEvaluation alloc] init];
            
            model.timeout = [NSString stringWithFormat:@"%@",objcet[@"timeout"] ? : @""];
            model.CSRAging = [objcet[@"CSRAging"] boolValue];
            id title = objcet[@"satisfyTitle"];
            if (title) {
                model.title = title;
            }
            id thank = objcet[@"satisfyThank"];
            if (thank) {
                model.thank = thank;
            }
            
            model.CSRCustomerPush = [objcet[@"NotAllowCustomerPushCsr"] boolValue];
            model.CSRCustomerLeavePush = [objcet[@"NotAllowCustomerCloseCsr"] boolValue];
            
            NSMutableArray *array = [NSMutableArray array];
            for (id item in list) {
                QMEvaluats *incestModel = [[QMEvaluats alloc] init];
                incestModel.name = item[@"name"];
                incestModel.value = item[@"value"];
                incestModel.reason = item[@"reason"];
                incestModel.labelRequired = item[@"labelRequired"];
                incestModel.proposalRequired = item[@"proposalRequired"];

                [array addObject:incestModel];
            }
            model.evaluats = array;
            completion(model);
        }else {
            failure();
        }
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 获取未读消息数
- (void)tryGetUnReadMessage:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId completion:(void (^)(NSInteger))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] getUnreadMessageNumbers:accessId userName:userName userId:userId completion:^(NSDictionary *object) {
        NSInteger numbers = [object[@"count"] integerValue];
        if (numbers) {
            completion(numbers);
        }else {
            completion(0);
        }
    } failure:^{
        failure();
    }];

}

# pragma mark -- 提交满意度评价信息
- (void)trySubmitInvestigation:(NSString *)name value:(NSString *)value completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] submitInvestigation:name value:value completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 提交满意度评价信息 包含二级标题和备注的评价
- (void)tryNewSubmitInvestigation:(NSString *)name value:(NSString *)value radioValue:(NSArray *)radioValue remark:(NSString *)remark way:(NSString *)way operation:(NSString *)operation sessionId:(NSString *)sessionId completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] tryNewSubmitInvestigation:name value:value radioValue:(NSArray *)radioValue remark:remark way:way operation:operation sessionId:sessionId completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
    
}
# pragma mark -- 提交离线留言信息(未测)
- (void)trySubmitLeaveContent:(NSString *)peer phone:(NSString *)phone email:(NSString *)email content:(NSString *)content completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] submitLeaveMessage:peer phone:phone email:email content:content completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 提交离线留言 自定义联系方式(未测)
- (void) trySubmitLeaveContent:(NSString *)peer information:(NSDictionary *)information leavemsgFields:(NSArray *)leavemsgFields content:(NSString *) content completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    NSString *messages = [content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSCharacterSet *customAllowedSet = [[NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"] invertedSet];
    NSString *message = [messages stringByAddingPercentEncodingWithAllowedCharacters:customAllowedSet];

    [[QMServiceBase sharedInstance] submitLeaveMessage:peer information:information fields:leavemsgFields content:message completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
    
}

# pragma mark -- 机器人帮助评价
- (void)trySubmitRobotFeedback:(NSString *)status questionId:(NSString *)questionId messageId:(NSString *)messageId robotType:(NSString *)robotType robotId:(NSString *)robotId robotMsgId:(NSString *)robotMsgId completion:(void (^)(void))completion failure:(void (^)(void))failure {
    // 修改机器人帮助状态
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
    
    [[QMServiceBase sharedInstance] submitRobotFeedback:status questionId:questionId messageId:messageId robotType:robotType robotId:robotId robotMsgId:robotMsgId completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- 智能机器人满意度评价
- (void)trySubmitIntelligentRobotSatisfaction:(NSString *)robotId satisfaction:(NSString *)satisfaction completion:(void (^)(void))completion failure:(void (^)(void))failure {
    [[QMServiceBase sharedInstance] SubmitIntelligentRobotSatisfaction:robotId satisfaction:satisfaction completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- xbot机器人帮助评价
- (void)trySubmitXbotRobotFeedback:(NSString *)status message:(CustomMessage *)message completion:(void (^)(void))completion failure:(void (^)(void))failure {
    // 修改机器人帮助状态
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
    
    NSString * newStr = [message.message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
    NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
    
    [[QMServiceBase sharedInstance] submitXbotRobotFeedback:status messageId:message._id robotId:message.robotId oriquestion:message.ori_question question:message.std_question answer:newString confidence:message.confidence robotType:message.robotType robotSessionId:message.robotSessionId questionId:message.questionId completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- xbot机器人满意度评价
- (void)trySubmitXbotRobotSatisfaction:(NSString *)satisfaction completion:(void (^)(void))completion failure:(void (^)(void))failure {
    [[QMServiceBase sharedInstance] SubmitXbotRobotSatisfaction:satisfaction completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- xbot机器人联想功能
- (void)trySubmitXbotRobotAssociationInput:(NSString *)text cateIds:(NSArray *)cateIds robotId:(NSString *)robotId robotType:(NSString *)robotType completion:(void (^)(NSArray *))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] SubmitXbotRobotAssociationInput:text cateIds:cateIds robotId:robotId robotType:robotType completion:^(NSDictionary *object){
        NSArray *questions = object[@"questions"];
        if (questions) {
            completion(questions);
        }
    } failure:^{
        failure();
    }];
}

# pragma mark -- 机器人转人工服务
- (void)tryConverManualWithPeerId:(NSString *)peerId completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    [[QMServiceBase sharedInstance] convertManualWithPeerId:peerId completion:^(NSDictionary *object) {
        completion();
    } failure:^{
        failure();
    }];
}

# pragma mark -- 是否已经评价过满意度评价
- (void)tryGetImCsrInvestigate:(void (^)(void))completion failure:(void (^)(NSString *))failure {
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];
    if (!sid) {
        failure(@"会话不存在，请退出重新接入");
        return;
    }
    
    NSString *account =  [self tryGetGlobalValue:@"account"];
    if (!account.length) {
        failure(@"会话不存在，请退出重新接入");
        return;
    }
    
    if ([QMGlobaMacro shared].replyMsg > 0) {
//        NSLog(@"replyMsg.count--------------%@",[QMGlobaMacro shared].replyMsg);
        [[QMServiceBase sharedInstance] sdkGetImCsrInvestigate:[QMGlobaMacro shared].chatID completion:^(NSDictionary *objects) {
            id isInvestigate = objects[@"isInvestigate"];
            if ([isInvestigate boolValue]) {
                completion();
            }else {
                failure(@"已经评价过了，不能重复评价");
            }
        } failure:^{
            failure(@"会话不存在，请退出重新接入");
        }];
        return;
    }

    [[QMServiceBase sharedInstance] getAleardyChatSession:sid account:account completion:^(NSDictionary *object) {
        id dataDic = object[@"data"];

        if ([dataDic isKindOfClass:[NSDictionary class]]) {
            [dataDic writeToFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"QMAleardChat.plist"] atomically:true];
            if (dataDic[@"_id"]) {
                [QMGlobaMacro shared].chatID = dataDic[@"_id"];
                id replyMsgCount = dataDic[@"replyMsgCount"];
//                NSLog(@"replyMsgCount-----%@",replyMsgCount);
                if ([replyMsgCount isKindOfClass:[NSNumber class]]) {
                    if (replyMsgCount > 0) {
                        [QMGlobaMacro shared].replyMsg = replyMsgCount;
                        [[QMServiceBase sharedInstance] sdkGetImCsrInvestigate:dataDic[@"_id"] completion:^(NSDictionary *objects) {
                            id isInvestigate = objects[@"isInvestigate"];
                            if ([isInvestigate boolValue]) {
                                completion();
                            }else {
                                failure(@"已经评价过了，不能重复评价");
                            }
                        } failure:^{
                            failure(@"会话不存在，请退出重新接入");
                        }];
                    }else {
                        failure(@"");
                    }
                }else{
                    failure(@"");
                }
            }else{
                failure(@"会话不存在，请退出重新接入");
            }
        }else{
            failure(@"会话不存在，请退出重新接入");
        }
    } failure:^{
        failure(@"会话不存在，请退出重新接入");
    }];
}

# pragma mark -- 会话定时断开 --- 这个API 老客户在用 没办法更改了
- (void)tryChatTimerBreaking:(void (^)(NSDictionary *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkGetWebchatGlobleConfig",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"success"] boolValue] == YES) {
            id globalSet = responseObject[@"globalSet"];
            if (globalSet) {
                completion(globalSet);
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

- (void)tryGetSdkServerTime:(void (^)(NSString *))completion failure:(void (^)(void))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkGetServerTime",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            NSString *globalSet = [NSString stringWithFormat:@"%@",responseObject[@"message"] ? : @""];
            completion(globalSet);
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

- (void)trysdkCheckImCsrTimeoutParams:(NSDictionary *)params success:(void (^)(void))success failureBlock:(void (^)(void))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkCheckImCsrTimeout",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    NSMutableDictionary *newParams = [parameters mutableCopy];
    if (params.count > 0) {
        [newParams addEntriesFromDictionary:params];
    }
    
//    NSLog(@"newParams===%@",newParams);    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:newParams success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"responseObject===%@",responseObject);
            if ([responseObject[@"Succeed"] boolValue] == YES) {
                if (success) {
                    success();
                }
            }else {
                if (failure) {
                    failure();
                }
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure();
            }
        });

    }];
}

- (void)trygetCommonQuestion:(void (^)(NSArray *))completion failure:(void (^)(NSString *))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure(@"connectId为空");
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkPullQAMsg",
                                 @"ConnectionId" : connectId,
                                 @"qaType"       : @"queryCatalogListInf",
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };

    
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"常见问题一-----%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (completion) {
                NSArray *dataArr = responseObject[@"catalogList"];
                completion(dataArr);
            }
        }else {
            if (failure) {
                failure(@"请求失败!");
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        if (failure) {
            failure(error.localizedDescription);
        }
    }];
}

- (void)tryGetSubCommonQuestionWithcid:(NSString *)cid completion:(void (^)(NSArray *))completion failure:(void (^)(NSString *))failure {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure(@"connectId为空");
        return;
    }
    
    if (cid.length == 0) {
        failure(@"cid 为空");
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkPullQAMsg",
                                 @"ConnectionId" : connectId,
                                 @"qaType"       : @"queryCatalogListInf",
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId,
                                 @"cid"           : cid,
                                 @"page"          : @"1",
                                 @"limit"         : @"30"
                                 };

    
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (completion) {
                NSArray *dataArr = responseObject[@"catalogList"];
                completion(dataArr);
            }
        }else {
            if (failure) {
                failure(@"请求失败!");
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        if (failure) {
            failure(error.localizedDescription);
        }
    }];
}

- (void)tryGetCommonDataWithParams:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(NSError *))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        NSError *err = [[NSError alloc] initWithDomain:@"connectId 为空" code:120 userInfo:nil];
        failure(err);
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    NSMutableDictionary *newParams = [parameters mutableCopy];
    if (params.count > 0) {
        [newParams addEntriesFromDictionary:params];
    }
    
//    NSLog(@"常见问题二级para---%@", newParams);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:newParams success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
//        NSLog(@"jsond = %@",responseObject);
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(responseObject);
            });
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
    
}

- (void)tryLoginoutAction:(void(^)(BOOL, NSString *))completion {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        completion(NO, @"connectId 为空");
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkLogout",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                 };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
//        NSLog(@"jsond = %@",responseObject);
 
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject[@"Succeed"] boolValue] == 1) {
                    completion(YES,nil);
                } else {
                    completion(NO,@"退出失败");
                }
            });
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, error.localizedDescription);
            });
        }
    }];
    
}

#pragma mark - 消费未读消息
- (void)tryDealImMsgWithMessageId:(NSArray *)messageId {
    
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkDealImMsg",
                                 @"ConnectionId" : connectId,
                                 @"AccessId"     : [QMGlobaMacro shared].custom_accessId,
                                 @"messageIdList": messageId
                                 };

//    NSLog(@"消费未读消息parameters===%@",parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"消费未读消息===%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
//            completion(responseObject);
            [[QMDataBase shared] updateAgentIsReadStatus];
        }else {
//            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
//        failure();
    }];

}

#pragma mark - 获取使用tcp还是webSocket
- (void)tryGetSDKConnectionEntranceWithAccessId:(NSString *)accessid completion:(void (^)(BOOL))completion failure:(void (^)(void))failure {
    
    NSDictionary *parameters = @{
        @"Action"      : @"sdkUseNewConnection",
        @"AccessId"    : accessid,
    };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"获取使用tcp还是webSocket===%@", responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            completion(YES);
        }else {
            completion(NO);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        failure();
    }];
}

- (void)tryHandleVideoOperation:(NSString *)type originator:(NSString *)originator completion:(void (^)(void))completion failure:(void (^)(void))failure {

    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }
       
    NSDictionary *parameters = @{
                                @"Action"       : @"sdkHandlerCustVideoOperation",
                                @"ConnectionId" : connectId,
                                @"operation"    : type,
                                @"originator"   : originator,
                                @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                };
//    NSLog(@"AAAAAA视频接口触发的params====%@",parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"视频responseObject---%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (completion) {
                completion();
            }
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

#pragma mark - 定时断开会话关闭时调用
- (void)tryClientAutoClose:(NSString *)chatId completion:(void (^)(void))completion failure:(void (^)(void))failure {
    NSString *sid = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];
    if (!sid) {
        failure();
        return;
    }
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameters = @{
                                 @"Action"       : @"clientAutoCloseSDK",
                                 @"ConnectionId" : connectId,
                                 @"sid"          : sid,
                                 @"accessId"     : [QMGlobaMacro shared].custom_accessId,
                                 @"platform"     : @"sdk",
                                 @"account"      : [QMGlobaMacro shared].account,
                                 @"sessionId"    : chatId
                                 };
    
//    NSLog(@"定时断开会话关闭时调用parameters===%@",parameters);
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
//        NSLog(@"定时断开会话关闭时调用responseObject---%@",responseObject);
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (completion) {
                completion();
            }
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

- (void)tryInputMonitor:(NSString *)chatContent completion:(void (^)(void))completion failure:(void (^)(void))failure {
   
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
    if (!connectId) {
        failure();
        return;
    }

    NSDictionary *parameters = @{
                                 @"Action"       : @"sdkTypeNotice",
                                 @"ConnectionId" : connectId,
                                 @"accessId"     : [QMGlobaMacro shared].custom_accessId,
                                 @"content"    : chatContent
                                 };
    
    [[[QMNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrlStr]] POST:@"/sdkChat" parameters:parameters success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
        if ([responseObject[@"Succeed"] boolValue] == YES) {
            if (completion) {
                completion();
            }
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

//- (void)tryStartTimer {
//    NSString *timerName = [QMTimerManager execTask:^{
//        [self cancelRegist];
//    } start:3.0 interval:0 repeats:NO async:NO];
//}

//- (void)cancelRegist {
//    //更改注册状态
//    [QMGlobaMacro shared].isStop = YES;
//    //开始判断  3中状态 1.是否注册成功isRegist 2.是否开始tcp注册 3.更改isStop状态
//    BOOL isRegist = [QMGlobaMacro shared].isRegist;
//    BOOL isStartTcp = [QMGlobaMacro shared].isStartTcp;
//    BOOL isWebSocket = [QMGlobaMacro shared].isWebSocket;
//    if (isRegist) {//注册成功
//        //定时器到之前已经注册成功 - 不进行操作
//        return;
//    }
//    
//    if (isStartTcp) {//tcp已经开始 - 但未注册成功
//        if (isWebSocket) {//webSocket
//            //断开webSocket
//            
//        }else {
//            //断开tcp
//
//        }
//        return;;
//    }
//    
//    //走到这里 说明tcp还没开始连接
//    /*
//     需要考虑的：
//     1. 在tcp开始连接前判断 如果时间已经到了 - return
//     2.返回时间到了回调 - 取消注册页面转圈
//     */
//    
//}
@end
