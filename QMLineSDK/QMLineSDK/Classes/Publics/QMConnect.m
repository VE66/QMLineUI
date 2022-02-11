//
//  QMConnect.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMConnect.h"
#import "QMServiceMessage.h"
#import "QMServiceFunction.h"
#import "QMDataBase.h"
#import "QMGlobaMacro.h"
#import "QMEvaluation.h"
#import "QMLoginManager.h"
#import "QMWebSocketManager.h"
#import "QiniuSDK.h"

@implementation QMConnect

#pragma mark - 注册及初始化

+ (void)registerSDKWithAppKey:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId {
    [[QMServiceFunction sharedInstance] tryGetSDKConnectionEntranceWithAccessId:accessId completion:^(BOOL isTrue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMGlobaMacro shared].isWebSocket = YES;
            [[QMWebSocketManager shared] createSocketWithAccessId:accessId userName:userName userId:userId delegate:nil];
        });
    } failure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMGlobaMacro shared].isWebSocket = NO;
        });
    }];
    [[QMDataBase shared] deleteListCard];

}

+ (void)registerSDKWithAppKey:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId delegate:(id<QMKRegisterDelegate>)delegate {

    [[QMWebSocketManager shared] createSocketWithAccessId:accessId userName:userName userId:userId delegate:delegate];
}

+ (void)logout {
    [QMLoginManager shared].peerId = @"";
    [QMLoginManager shared].isManual  = false;
    [QMLoginManager shared].scheduleId = @"";
    [QMLoginManager shared].processId = @"";
    [QMLoginManager shared].entranceId = @"";
    [QMLoginManager shared].processTo = @"";
    [QMLoginManager shared].parameters = @{};

    [QMGlobaMacro shared].replyMsg = 0;
    [QMGlobaMacro shared].chatID = @"";
    if ([QMGlobaMacro shared].isWebSocket) {
        [[QMWebSocketManager shared] disConnectSocket];
    }else {
                
    }
}

+ (void)switchServiceRoute:(QMServiceLine)line {
    if (line == QMServiceLineTencent) {
        [[QMGlobaMacro shared] setIsDynamicConnection:NO];
        [[QMGlobaMacro shared] setOemHost:@"tx-sdk-tcp01.7moor-fs1.com"];
        [[QMGlobaMacro shared] setOemPort:8006];
        [[QMGlobaMacro shared] setOemHttp:@"https://ykf-webchat.7moor-fs1.com"];
        sdkwebSocketUrl = @"ws://tx-sdk-socket01.7moor-fs1.com/webSocket";
    } else {
        [[QMGlobaMacro shared] setIsDynamicConnection:YES];
        [[QMGlobaMacro shared] setOemHost:@"cc-sdk-tcp05.7moor-fs1.com"];
        [[QMGlobaMacro shared] setOemPort:8008];
        [[QMGlobaMacro shared] setOemHttp:@"https://cc-sdk-http.7moor-fs1.com"];
        sdkwebSocketUrl = @"ws://cc-sdk-socket01.7moor-fs1.com/webSocket";
    }
}

+ (void)setFileServer:(NSString *)fileUrl withZone:(NSString *)zoneUrl {
    [QMGlobaMacro shared].qiNiuFileServer = fileUrl;
    [QMGlobaMacro shared].qiNiuZoneServer = zoneUrl;
    [QMGlobaMacro shared].isQINiuServer = YES;
}

+ (void)setServerAddress:(NSString *)tcpHost tcpPort:(int)tcpPort httpPost:(NSString *)httpPost {
    [[QMGlobaMacro shared] setIsDynamicConnection:NO];
    [[QMGlobaMacro shared] setOemHost:tcpHost];
    [[QMGlobaMacro shared] setOemPort:tcpPort];
    [[QMGlobaMacro shared] setOemHttp:httpPost];
}

+ (void)sdkBeginNewChatSession:(NSString *)peerId successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(NSString *))failure {
    if ([QMGlobaMacro shared].chatMode == QMChatModeSchedule) {
        failure(@"当前状态是日程，不能请求技能组");
        return;
    }
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:peerId params:@{@"":@""} vipTrue:YES completion:success failure:^{
        failure(@"开始会话失败");
    }];
}

+ (void)sdkBeginNewChatSession:(NSString *)peerId delegate:(id<QMKServiceDelegate>)delegate successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(void))failure {
    
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:peerId params:@{@"":@""} vipTrue:NO completion:success failure:failure];
}

+ (void)sdkBeginNewChatSession:(NSString *)peerId params:(NSDictionary *)params successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(NSString *))failure {
    if ([QMGlobaMacro shared].chatMode == QMChatModeSchedule) {
        failure(@"当前状态是日程，不能请求技能组");
        return;
    }
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:peerId params:params vipTrue:NO completion:success failure:^{
        failure(@"开始会话失败");
    }];
}

+ (void)sdkBeginNewChatSession:(NSString *)peerId option:(QMSessionOption *)option successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(NSString *))failure {
    if ([QMGlobaMacro shared].chatMode == QMChatModeSchedule) {
        failure(@"当前状态是日程，不能请求技能组");
        return;
    }
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:peerId option:option completion:success failure:^{
        failure(@"开始会话失败");
    }];
}

+ (void)sdkBeginNewChatSessionSchedule:(NSString *)scheduleId processId:(NSString *)processId currentNodeId:(NSString *)currentNodeId entranceId:(NSString *)entranceId params:(NSDictionary *)params successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(NSString *))failure {
    if ([QMGlobaMacro shared].chatMode == QMChatModePeers) {
        failure(@"当前状态是技能组，不能请求日程");
        return;
    }
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:scheduleId processId:processId currentNodeId:currentNodeId entranceId:entranceId params:params vipTrue:NO completion:success failure:^{
        failure(@"开始会话失败");
    }];
}

+ (void)sdkBeginNewChatSessionSchedule:(NSString *)scheduleId processId:(NSString *)processId currentNodeId:(NSString *)currentNodeId entranceId:(NSString *)entranceId successBlock:(void (^)(BOOL, NSString *))success failBlock:(void (^)(NSString *))failure {
    if ([QMGlobaMacro shared].chatMode == QMChatModePeers) {
        failure(@"当前状态是技能组，不能请求日程");
        return;
    }
    [[QMServiceFunction sharedInstance] tryStartNewChatSession:scheduleId processId:processId currentNodeId:currentNodeId entranceId:entranceId params:@{@"":@""} vipTrue:YES completion:success failure:^{
        failure(@"开始会话失败");
    }];
}


+ (void)sdkGetWebchatGlobleConfig:(void (^)(NSDictionary *))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetWebchatGlobleConfig:success failure:failure];
}

+ (void)sdkGetWebchatScheduleConfig:(void (^)(NSDictionary *))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetWebchatScheduleConfig:success failure:failure];
}

//+ (void)sdkGetImCsrInvestigate:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
//
//    [[QMServiceFunction sharedInstance] tryGetImCsrInvestigate:^{
//        success();
//    } failure:^(NSString *reason) {
//        failure(reason);
//    }];
//}

#pragma mark - 消息发送
+ (void)sendMsgText:(NSString *)text successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendTextMessage:text completion:success failure:failure];
}

+ (void)sendMsgPic:(UIImage *)image successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendImageMessage:nil image:image completion:success failure:failure];
}

+ (void)sendMsgImage:(NSString *)filePath successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendImageMessage:filePath image:nil completion:success failure:failure];
}

+ (void)sendMsgAudio:(NSString *)audio duration:(NSString *)duartion successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendAudioMessage:audio data:nil duration:duartion completion:success failure:failure];
}

+ (void)sendMsgAudioToText:(CustomMessage *)message successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    
    if (message.fileName.length > 0) {
        [[QMDataBase shared] changeVoiceTextShowoOrNot:@"1" messageId:message._id];
        success();
        return;
    }
    if (message._id.length > 0 && message.remoteFilePath.length > 0 && message.createdTime.length > 0) {
        [[QMDataBase shared] changeVoiceTextShowoOrNot:@"2" messageId:message._id];
        [[QMServiceMessage sharedInstance] sendAudioToText:message._id filePath:message.remoteFilePath when:message.createdTime completion:success failure:failure];
    }
}

+ (void)sendMsgFile:(NSString *)fileName filePath:(NSString *)filePath fileSize:(NSString *)fileSize progressHander:(void (^)(float))progress successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendFilePath:filePath fileName:fileName fileSize:fileSize progressHander:progress completion:success failure:failure];
}

+ (void)sendMsgCardInfo:(NSDictionary *)message successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendCardInfoMessage:message completion:success failure:failure];
}

+ (void)downloadFileWithMessage:(CustomMessage *)message localFilePath:(NSString *)filePath progressHander:(void (^)(float))progress successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] downLoadFileFromQiniuWithUrl:message localFilePath:filePath progress:^(NSProgress *downProgress) {
        float complete = (float)downProgress.completedUnitCount;
        float total = (float)downProgress.totalUnitCount;
        float percent = complete/total;
        progress(percent);
    } completion:success failure:^{
        failure(@"");
    }];
}

+ (void)resendMessage:(CustomMessage *)message successBlock:(void (^)(void))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] reSendMessageWithMessageType:message completion:success failure:failure];
}

+ (CustomMessage *)createMessageOfInvestigations {
    CustomMessage *message = [[QMServiceMessage sharedInstance] createMessageWithMessageType:[NSString stringWithFormat:@"%ld", (long)QMMessageTypeInvestigate] filePath:nil content:nil metaData:nil];
    return  message;
}

#pragma mark - 数据库操作
+ (NSArray<CustomMessage *> *)getDataFromDatabase:(int)number {
    return [[QMDataBase shared] queryMessageWithSessionID:number];
}

+ (NSArray<CustomMessage *> *)getAccessidAllDataFormDatabase:(int)number {
    return [[QMDataBase shared] queryMessageWithAccessId:number];
}

+ (NSArray<CustomMessage *> *)getUserIdDataFormDatabase:(int)number {
    return [[QMDataBase shared] queryMessageWithUserId:number];
}

+ (NSArray<CustomMessage *> *)getOneDataFromDatabase:(NSString *)messageId {
    return [[QMDataBase shared] queryOneMessageWithID:messageId];
}

+ (void)removeDataFromDataBase:(NSString *)messageId {
    [[QMDataBase shared] deleteMessageWithID:messageId];
}

+ (void)changeAudioMessageStatus:(NSString *)messageId {
    [[QMDataBase shared] changeMessageAudioStatus:messageId];
}

+ (void)changeDrawMessageStatus:(NSString *)messageId {
    [[QMDataBase shared] changeMessageStatus:messageId];
}

+ (NSString *)queryMp3FileMessageSize:(NSString *)messageId {
    return [[QMDataBase shared] queryMp3FileMessageSize:messageId];
}

+ (void)changeMp3FileMessageSize:(NSString *)messageId fileSize:(NSString *)fileSize {
    [[QMDataBase shared] changeMp3FileMessageSize:messageId fileSize:fileSize];
}

+ (void)insertCardInfoData:(NSDictionary *)message type:(NSString *)type {
    [[QMServiceMessage sharedInstance] sendCardMessage:message type:type completion:^{
        
    } failure:^{
        
    }];
}

+ (void)insertCardInfoData:(NSDictionary *)message {
    [self insertCardInfoData:message type:@"card"];
}

+ (void)deleteCardTypeMessage {
    [[QMDataBase shared] deleteMessageWithCardType];
}

+ (void)deleteCardTypeMessage:(NSString *)type {
    [[QMDataBase shared] deleteMessageWithCardType:type];
}

+ (void)changeCardTypeMessageTime:(NSString *)time {
    [[QMDataBase shared] changeMessageCardTime:time];
}

+ (void)changeAllCardMessageHidden {
    [[QMDataBase shared] changeAllCardMessageTypeHidden];
}

+ (void)changeCardMessageType:(QMMessageCardReadType)type messageId:(NSString *)messageId {
    [[QMDataBase shared] changeCardMessageType:type messageId:messageId];
}

+ (void)changeVoiceTextShowoOrNot:(NSString *)status message:(NSString *)messageId {
    [[QMDataBase shared] changeVoiceTextShowoOrNot:status messageId:messageId];
}

+ (NSString *)queryVoiceTextStatusWithmessageId:(NSString *)messageId {
    return [[QMDataBase shared] queryVoiceTextStatusWithmessageId:messageId];
}

+ (void)insertOtherInfoData:(NSDictionary *)mateData type:(NSString *)type {
    [[QMServiceMessage sharedInstance] sendOtherInfoData:mateData type:type];
}

+ (void)insertLeaveMsg:(NSString *)message {
    NSDictionary *dic = @{@"text" : message};
    [self insertOtherInfoData:dic type:@"text"];
}

#pragma mark - 功能接口
+ (void)sdkAcceptOtherAgentWithPeer:(NSString *)peer successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryVipAgentOnline:peer completion:^{
        success();
    } failure:^{
        failure();
    }];
}

+ (void)sdkConvertManual:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryConverManualWithPeerId:@"" completion:success failure:failure];
}

+ (void)sdkConvertManualWithPeerId:(NSString *)peerId successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryConverManualWithPeerId:peerId completion:success failure:failure];
}

//+ (void)sdkGetInvestigate:(void (^)(NSArray<NSString *> *))success failBlock:(void (^)(void))failure {
+ (void)sdkGetInvestigate:(void (^)(NSArray<NSDictionary *> *))success failureBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetInvestingations:success failure:failure];
}

+ (void)newSDKGetInvestigate:(void (^)(QMEvaluation *))success failureBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryNewGetInvestingations:success failure:failure];
}

+ (void)sdkGetServerTime:(void (^)(NSString *))success failureBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetSdkServerTime:success failure:failure];
}

+ (void)sdkGetPeers:(void (^)(NSArray<NSDictionary *> *))success failureBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetPeers:success failure:failure];
}

+ (void)sdkGetUnReadMessage:(NSString *)accessId userName:(NSString *)userName userId:(NSString *)userId successBlock:(void (^)(NSInteger))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetUnReadMessage:accessId userName:userName userId:userId completion:success failure:failure];
}

+ (void)sdkSubmitInvestigate:(NSString *)name value:(NSString *)value successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitInvestigation:name value:value completion:success failure:failure];
}

+ (void)sdkNewSubmitInvestigate:(NSString *)name value:(NSString *)value radioValue:(NSArray *)radioValue remark:(NSString *)remark way:(NSString *)way operation:(NSString *)operation sessionId:(NSString *)sessionId successBlock:(void (^)(void))success failBlock:(void (^)(void))failure{
    [[QMServiceFunction sharedInstance] tryNewSubmitInvestigation:name value:value radioValue:radioValue remark:remark way:way operation:operation sessionId:sessionId completion:success failure:failure];
}

+ (void)sdkSubmitLeaveMessage:(NSString *)peer phone:(NSString *)phone Email:(NSString *)email message:(NSString *)message successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitLeaveContent:peer phone:phone email:email content:message completion:success failure:failure];
}

+ (void)sdkSubmitLeaveMessageWithInformation:(NSString *)peer information:(NSDictionary *)information leavemsgFields:(NSArray<NSDictionary*> *)leavemsgFields message:(NSString *)message successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitLeaveContent:peer information:information leavemsgFields:leavemsgFields content:message completion:success failure:failure];
}

+ (void)sdkSubmitRobotFeedback:(BOOL)isUseful questionId:(NSString *)questionId messageId:(NSString *)messageId robotType:(NSString *)robotType robotId:(NSString *)robotId robotMsgId:(NSString *)robotMsgId successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    
    NSString *status = isUseful == YES ? @"useful" : @"useless";
    [[QMDataBase shared] changeRobotQuestionStatus:messageId status:status];
    
    [[QMServiceFunction sharedInstance] trySubmitRobotFeedback:isUseful == YES ? @"useful" : @"useless" questionId:questionId messageId:messageId robotType:robotType robotId:robotId robotMsgId:robotMsgId completion:success failure:failure];
}

+ (void)sdkSubmitIntelligentRobotSatisfaction:(NSString *)robotId satisfaction:(NSString *)satisfaction successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitIntelligentRobotSatisfaction:robotId satisfaction:satisfaction completion:success failure:failure];
}

+ (void)sdkSubmitXbotRobotFeedback:(BOOL)isUseful message:(CustomMessage *)message successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    NSString *status = isUseful == YES ? @"useful" : @"useless";
    [[QMDataBase shared] changeRobotQuestionStatus:message._id status:status];
    
    [[QMServiceFunction sharedInstance] trySubmitXbotRobotFeedback:isUseful == YES ? @"1" : @"0" message:message completion:success failure:failure];
}

+ (void)sdkSubmitXbotRobotSatisfaction:(NSString *)satisfaction successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitXbotRobotSatisfaction:satisfaction completion:success failure:failure];
}

+ (void)sdkSubmitXbotRobotAssociationInput:(NSString *)text cateIds:(NSArray *)cateIds robotId:(NSString *)robotId robotType:(NSString *)robotType successBlock:(void (^)(NSArray *))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trySubmitXbotRobotAssociationInput:text cateIds:cateIds robotId:robotId robotType:robotType completion:success failure:failure];
}

+ (void)setServerToken:(NSData *)deviceToken {
    [QMGlobaMacro shared].token = deviceToken;
}

+ (void)customerServiceIsSpeek:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryGetImCsrInvestigate:success failure:^(NSString *reason) {
        failure();
    }];
}

#pragma mark - 会话设置的get方法
+ (BOOL)allowedLeaveMessage {
    id isLeaveMsg = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"isLeaveMsg"];
    if ([isLeaveMsg isKindOfClass:[NSString class]]) {
        if ([isLeaveMsg isEqualToString:@"1"]) {
            return true;
        } else {
            return false;
        }
    }else if ([isLeaveMsg isKindOfClass:[NSNumber class]]) {
        if ([isLeaveMsg isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        } else {
            return false;
        }
    }else {
        if ([isLeaveMsg boolValue] == YES) {
            return true;
        }else {
            return false;
        }
    }
}

+ (NSString *)leaveMessageAlert {
    id msg = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"msg"];

    if ([msg isKindOfClass:[NSString class]]) {
        return msg;
    } else {
        return @"";
    }
}

+ (NSString *)leaveMessageTitle {
    id inviteLeavemsgTip = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"inviteLeavemsgTip"];
    
    if ([inviteLeavemsgTip isKindOfClass:[NSString class]]) {
        return inviteLeavemsgTip;
    } else {
        return @"";
    }
}

+ (NSString *)leaveMessagePlaceholder {
    id leavemsgTip = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"leavemsgTip"];
    
    if ([leavemsgTip isKindOfClass:[NSString class]]) {
        return leavemsgTip;
    } else {
        return @"";
    }
}

+ (NSArray *)leaveMessageContactInformation {
    id leavemsgFields = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"leavemsgFields"];

    if ([leavemsgFields isKindOfClass:[NSArray class]]) {
        NSMutableArray *tempFields = [[NSMutableArray alloc] init];
        for (id field in leavemsgFields) {
            if ([field[@"enable"] boolValue] == YES) {
                [tempFields addObject:field];
            }
        }
        return tempFields;
    } else {
        return @[@{
                  @"_id"      : @"Phone",
                  @"name"     : @"电话",
                  @"enable"   : @YES,
                  @"required" : @NO
                  },
                @{
                  @"_id"      : @"Email",
                  @"name"     : @"邮箱",
                  @"enable"   : @YES,
                  @"required" : @NO
                  }];
    }
}

+ (BOOL)allowedBreakSession {
    id break_len = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_len"];
    id break_tips_len = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_tips_len"];
    int breakLen = 0;
    if ([break_len isKindOfClass:[NSString class]]) {
        breakLen = [[NSNumber numberWithFloat:[break_len floatValue]] intValue];
    }else if ([break_len isKindOfClass:[NSNumber class]]) {
        breakLen = [break_len intValue];
    }
    
    int breakTip = 0;
    if ([break_tips_len isKindOfClass:[NSString class]]) {
        breakTip = [[NSNumber numberWithFloat:[break_tips_len floatValue]] intValue];
    }else if ([break_tips_len isKindOfClass:[NSNumber class]]) {
        breakTip = [break_len intValue];
    }

    if (breakLen - breakTip > 0) {
        return true;
    }else {
        return false;
    }
}

+ (NSString *)breakSessionAlert {
    id break_tips = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_tips"];
    
    if ([break_tips isKindOfClass:[NSString class]]) {
        return break_tips;
    } else {
        return @"";
    }
}

+ (int)breakSessionDuration {
    id break_len = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_len"];
    
    if ([break_len isKindOfClass:[NSString class]]) {
        return [break_len intValue];
    }else if ([break_len isKindOfClass:[NSNumber class]]) {
        return [break_len intValue];
    }else {
        return -1;
    }
}

+ (int)breakSessionAlertDuration {
    id break_len = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_len"];
    id break_tips_len = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"break_tips_len"];
    int breakLen = 0;
    if ([break_len isKindOfClass:[NSString class]]) {
        breakLen = [[NSNumber numberWithFloat:[break_len floatValue]] intValue];
    }else if ([break_len isKindOfClass:[NSNumber class]]) {
        breakLen = [break_len intValue];
    }
    
    int breakTip = 0;
    if ([break_tips_len isKindOfClass:[NSString class]]) {
        breakTip = [[NSNumber numberWithFloat:[break_tips_len floatValue]] intValue];
    }else if ([break_tips_len isKindOfClass:[NSNumber class]]) {
        breakTip = [break_len intValue];
    }
    
    if (breakLen - breakTip > 0) {
        return breakLen - breakTip;
    }else {
        return -1;
    }
}

+ (BOOL)allowRobot {
    id robot = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"robot"];

    if ([robot isKindOfClass:[NSString class]]) {
        if ([robot isEqualToString:@"1"]) {
            return true;
        }else {
            return false;
        }
    }else if ([robot isKindOfClass:[NSNumber class]]) {
        if ([robot isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        }else {
            return false;
        }
    }else {
        if ([robot boolValue] == YES) {
            return true;
        }else {
            return false;
        }
    }
}

+ (NSString *)sdkRobotType {
    id robotType = [[QMServiceFunction sharedInstance] tryGetBeginSessionConfigValue:@"robotType"];
    if ([robotType isKindOfClass:[NSString class]]) {
        return robotType;
    } else {
        return @"";
    }
}

+ (BOOL)manualButtonStatus {
    id status = [[QMServiceFunction sharedInstance] tryGetBeginSessionConfigValue:@"showTransferBtn"];
    
    if ([status isKindOfClass:[NSString class]]) {
        if ([status isEqualToString:@"1"]) {
            return true;
        }else {
            return false;
        }
    }else if ([status isKindOfClass:[NSNumber class]]) {
        if ([status isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return true;
        }else {
            return false;
        }
    }else {
        if ([status boolValue] == YES) {
            return true;
        }else if ([status boolValue] == NO){
            return false;
        }else {
            return true;
        }
    }
}

+ (NSArray *)sdkQueueMessage {
    id queueTitle = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"queueNumText"];
    NSInteger top = 99;
    NSInteger last = 99;
    if ([queueTitle isKindOfClass:[NSString class]]) {
        NSRange range1 = [queueTitle rangeOfString:@"{"];
        if (range1.location != NSNotFound) {
            top = range1.location;
        }else{
            return @[queueTitle];
        }
        
        NSRange range2 = [queueTitle rangeOfString:@"}"];
        if (range2.location != NSNotFound) {
            last = range2.location;
        }else{
            return @[queueTitle];
        }
        
        NSString *alp = [queueTitle substringWithRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
        return @[queueTitle, alp];
    }
    
    return @[];
}

+ (BOOL)customerAccessAfterMessage {
    id status = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"accessAfterMessage"];

    if ([status isKindOfClass:[NSString class]]) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else {
            return NO;
        }
    }else if ([status isKindOfClass:[NSNumber class]]) {
        if ([status isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return YES;
        }else {
            return NO;
        }
    }else {
        if ([status boolValue] == YES) {
            return YES;
        }else if ([status boolValue] == NO){
            return NO;
        }else {
            return NO;
        }
    }
}

+ (NSArray *)xbotBottomList:(NSString *)type {
    NSArray *bottomList = [[QMServiceFunction sharedInstance] tryGetBottomList:type];
    if (bottomList.count < 1) {
        return @[];
    }else {
        return bottomList;
    }
}

//+ (BOOL)customerServiceIsSpeek {
//    NSString *sid = [QMGlobaMacro shared].custom_sessionId;
//    static BOOL isSpeek = NO;
//
//    [[QMServiceFunction sharedInstance] tryGetAleardyChatSession:sid completion:^(NSDictionary *object) {
//        NSLog(@"成功------------");
//        id replyMsgCount = object[@"replyMsgCount"];
//        NSLog(@"replyMsgCount-----%@",replyMsgCount);
//        if ([replyMsgCount isKindOfClass:[NSNumber class]]) {
//            if (replyMsgCount > 0) {
//                isSpeek = YES;
//            }else {
//                isSpeek = NO;
//            }
//        }else{
//            NSLog(@"客服是否说话没走nsnumber判断");
//        }
//    } failure:^{
//        NSLog(@"失败------------");
//    }];
//
//    return isSpeek;
//}

+ (void)applicationWillTerminateHandle {
    [[QMDataBase shared] changeMessageStatus];
}

+ (void)sdkCheckImCsrTimeoutParams:(NSDictionary *)params success:(void (^)(void))success failureBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] trysdkCheckImCsrTimeoutParams:params success:success failureBlock:failure];
}

+ (void)sdkGetCommonQuestion:(void (^)(NSArray *))completion failure:(void(^)(NSString *))failure {
    [[QMServiceFunction sharedInstance] trygetCommonQuestion:completion failure:failure];
}

+ (void)sdkGetSubCommonQuestionWithcid:(NSString *)cid completion:(void (^)(NSArray *))completion failure:(void (^)(NSString *))failure {
    [[QMServiceFunction sharedInstance] tryGetSubCommonQuestionWithcid:cid completion:completion failure:failure];
}

+ (void)sdkGetCommonDataWithParams:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(NSError *))failure {
    [[QMServiceFunction sharedInstance] tryGetCommonDataWithParams:params completion:completion failure:failure];
}

+ (void)sdkLogoutAction:(void(^)(BOOL, NSString *))completion {
    [[QMServiceFunction sharedInstance] tryLoginoutAction:completion];
}

+ (CustomMessage *)createAndInsertMessageToDBWithMessageType:(NSString *)type filePath:(NSString *)filePath content:(NSString *)content metaData:(NSDictionary *)metaData {
    CustomMessage *message = [[QMServiceMessage sharedInstance] createMessageWithMessageType:type filePath:filePath content:content metaData:metaData];
    [[QMServiceMessage sharedInstance] insertTextToIMDB:message];
    return message;
}

+ (void)sdkSendBreakTipMessage {
    NSString *text = [self breakSessionAlert];
    if (text.length > 0) {
        [[QMServiceMessage sharedInstance] sendBreakTipMessage:text];
    }
}

+ (NSString *)sdkSystemMessageIcon {
    id icon = [[QMServiceFunction sharedInstance] tryGetBeginSessionConfigValue:@"systemMsgLogo"];
    if ([icon isKindOfClass:[NSString class]]) {
        return icon;
    }else {
        return @"";
    }
}

+ (void)sdkDealImMsgWithMessageID:(NSArray *)messageID {
    [[QMServiceFunction sharedInstance] tryDealImMsgWithMessageId:messageID];
}

+ (void)WithdrawMessageText:(NSString *)text {
    if (text.length > 0) {
        [QMGlobaMacro shared].WithdrawMessage = text;
    }
}

+ (NSArray *)sdkGetAgentMessageWithIsRead {
    return [[QMDataBase shared] queryIsReadFromAgent];
}

+ (BOOL)sdkWhetherToOpenReadAndUnread {
    id status = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"isCustomerRead"];
    if ([status isKindOfClass:[NSString class]]) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else {
            return NO;
        }
    }else if ([status isKindOfClass:[NSNumber class]]) {
        if ([status isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return YES;
        }else {
            return NO;
        }
    }else {
        if ([status boolValue] == YES) {
            return YES;
        }else if ([status boolValue] == NO){
            return NO;
        }else {
            return NO;
        }
    }
}

+ (void)sdkChangeCommonProblemIndex:(NSString *)index withMessageID:(NSString *)messageId {
    [[QMDataBase shared] updateCommonProblemIndex:index withMessageID:messageId];
}

+ (void)sdkUpdateRobotFlowList:(NSString *)flowList withMessageID:(NSString *)messageId {
    [[QMDataBase shared] updateRobotFlowList:flowList withMessageID:messageId];
}

+ (void)sdkUpdateRobotFlowSend:(NSString *)flowSend withMessageID:(NSString *)messageId {
    [[QMDataBase shared] updateRobotFlowSend:flowSend withMessageID:messageId];
}

+ (void)sdkSendEvaluateMessage:(NSDictionary *)dic {
    [[QMServiceMessage sharedInstance] sendEvaluateMessage:dic];
}

+ (void)sdkUpdateEvaluateStatusWithEvaluateId:(NSString *)evaluateId {
    [[QMDataBase shared] updateEvaluateStatusWithEvaluateId:evaluateId];
}

+ (void)sdkClientChatClose:(NSString *)chatID {
    [[QMServiceFunction sharedInstance] tryClientAutoClose:chatID completion:^{
        
    } failure:^{
        
    }];
}

+ (void)sdkSendFile:(NSDictionary *)fileDic progress:(void (^)(float))progress success:(void (^)(NSString *))success failBlock:(void (^)(NSString *))failure {
    [[QMServiceMessage sharedInstance] sendFile:fileDic progressHander:progress completion:success failure:failure];
}

+ (void)sdkSubmitFormMessage:(NSDictionary *)dic {
    [[QMServiceMessage sharedInstance] sendFormMessage:dic];
}

+ (void)sdkUpdateFormStatus:(NSString *)status withMessageID:(NSString *)messageId {
    [[QMDataBase shared] updateFormStatus:status withMessageID:messageId];
}

+ (NSString *)QMSDKVersion {
    return sdkIOSVersion;
}

#pragma mark - 视频接口
+ (BOOL)sdkVideoRights {
    id mobileVideoChat = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"mobileVideoChat"];
    id mobileVideoChatIm = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"mobileVideoChatIm"];

    if ([mobileVideoChat boolValue] && [mobileVideoChatIm boolValue]) {
        return  YES;
    }else {
        return NO;
    }
}

+ (void)sdkAcceptVideo:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryHandleVideoOperation:@"accept" originator:@"agent" completion:success failure:failure];
}

+ (void)sdkRefuseVideo:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryHandleVideoOperation:@"refuse" originator:@"agent" completion:success failure:failure];
}

+ (void)sdkCannelVideo:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryHandleVideoOperation:@"cancel" originator:@"customer" completion:success failure:failure];
}

+ (void)sdkHangupVideo:(NSString *)originator successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryHandleVideoOperation:@"hangup" originator:originator completion:success failure:failure];
}

+ (void)sdkGetVideo:(NSString *)type Completion:(void (^)(id))completion failure:(void (^)(NSError *))failure {
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_CONNECT_ID];
       if (!connectId) {
           NSError *err = [[NSError alloc] initWithDomain:@"connectId 为空" code:120 userInfo:nil];
                   failure(err);
           return;
       }
       
       NSDictionary *parameters = @{
                                    @"Action"       : @"sdkPushImVideoToAgent",
                                    @"ConnectionId" : connectId,
                                    @"newVideo"     : @"1",
                                    @"videoType"    : type,
                                    @"AccessId"     : [QMGlobaMacro shared].custom_accessId
                                    };
    [[QMServiceFunction sharedInstance] tryGetCommonDataWithParams:parameters completion:completion failure:failure];
}

+ (void)downloadFileWithUrl:(NSString *)url
                   successBlock:(void (^)(void))success
                  failBlock:(void (^)(NSString *))failure {
    NSURL *Url = [NSURL URLWithString:url];
    if (!Url) {
        Url = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:Url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        if (resp.statusCode == 200 && data.length > 0) {
            NSString *path = [QMGlobaMacro pathOfDocument];
            path = [path stringByAppendingPathComponent:url.lastPathComponent];
            [data writeToFile:path atomically:YES];
            success();
        } else {
            failure(@"失败");
        }
    }];
    [dataTask resume];
   
}

+ (NSString *)getBaseUrl {
    NSString *baseURL = sdkRequestUrlStr1;
    if (![[QMGlobaMacro shared] isDynamicConnection]) {
        baseURL = [[QMGlobaMacro shared] oemHttp];
    }
    return baseURL;
}

+ (NSString *)getAccessid {
    return [QMGlobaMacro shared].custom_accessId;
}

+ (void)sdkInputMonitor:(NSString *)content successBlock:(void (^)(void))success failBlock:(void (^)(void))failure {
    [[QMServiceFunction sharedInstance] tryInputMonitor:content completion:success failure:failure];
}

+ (BOOL)sdkGetIsInputMonitor {
    id status = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"sdkTypeNoticeFlag"];
    if ([status isKindOfClass:[NSString class]]) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else {
            return NO;
        }
    }else if ([status isKindOfClass:[NSNumber class]]) {
        if ([status isEqualToNumber:[NSNumber numberWithInt:1]]) {
            return YES;
        }else {
            return NO;
        }
    }else {
        if ([status boolValue] == YES) {
            return YES;
        }else if ([status boolValue] == NO){
            return NO;
        }else {
            return NO;
        }
    }
}

//+ (void)sdkSendEvaluateMessage:(NSString *)text withID:(NSString *)ID withStatus:(NSString *)status withTimestamp:(NSString *)timestamp {
//    [[QMServiceMessage sharedInstance] sendEvaluateMessage:text withID:ID withStatus:status withTimestamp:timestamp];
//}

@end
