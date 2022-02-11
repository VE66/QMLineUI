//
//  QMWebSocketManager.m
//  webSocketTest
//
//  Created by lishuijiao on 2020/7/27.
//  Copyright © 2020 Lisj. All rights reserved.
//

#import "QMWebSocketManager.h"
#import "QMGlobaMacro.h"
#import "QMLineSDK.h"
#import "QMLineError.h"
#import "QMFileManagerr.h"
#import "QMLoginManager.h"
#import "QMDataBase.h"
#import "QMAgent.h"
#import "QMServiceBase.h"
#import "QMServiceMessage.h"
#import "QMServiceFunction.h"

int const webScoketConnectLimit = 3;

@interface QMWebSocketManager ()<SRWebSocketDelegate> {
    NSString *_accessID;
    NSString *_userName;
    NSString *_password;
    NSString *_apnsToken;
}

@property (nonatomic, strong) SRWebSocket *webSocket;

@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器

@property (nonatomic, strong) NSTimer *reConnectTimer; //重连定时器

@property (nonatomic, strong)NSTimer *messageTimer; //获取消息的定时器

@property (nonatomic, assign) int reConnectCount; //重连次数

@property (nonatomic, assign) BOOL autoConnection; //是否自动重连

@property (nonatomic, assign)BOOL isLogined;

@property (nonatomic, assign) BOOL isDidOpen; //是否已经webSocketDidOpen

@end

@implementation QMWebSocketManager

+ (instancetype)shared {
    static QMWebSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.connectStatus = -1;
    }
    return self;
}

- (void)createSocketWithAccessId:(NSString *)accessId userName:(NSString *)name userId:(NSString *)password delegate:(id<QMKRegisterDelegate>)delegate {
    if (delegate) {
        [self setDelegate:delegate];
    }
    [[QMFileManagerr sharedInstance] createFileWith: @"/monitorTcp.text"];
    
    if (!accessId || [accessId isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
            [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeEmptyAccessId]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeEmptyAccessId]];
        return;
    }
    
    if (!name || [name isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
            [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeEmptyUsername]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeEmptyUsername]];
        return;
    }
    
    if (!password || [password isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
            [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeEmptyUserId]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeEmptyUserId]];
        return;
    }
    
    if ([self validateUserId:password]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
            [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeUserIdViolation]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeUserIdViolation]];
        return;
    }
    
    if ([QMGlobaMacro shared].token != nil) {
        _apnsToken = [[NSString alloc] init];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 13.0) {
            _apnsToken = [self getHexData:[QMGlobaMacro shared].token];
        } else {
            _apnsToken = [[[QMGlobaMacro shared].token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            _apnsToken = [_apnsToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    
    _accessID = accessId;
    _userName = name;
    _password = password;
    
    self.isLogined = YES;
    
    // 连接状态判断
    if (self.connectStatus != -1) {
        if (self.connectStatus == 1) {
            if (delegate && [self.delegate respondsToSelector:@selector(registerSuccess)]) {
                [self.delegate registerSuccess];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_SUCCEED object:nil];
        }
        return;
    }
    
    self.connectStatus = 0;
    self.autoConnection = NO;

    [self dynamicConnection];
//    [self connectServer];

}

- (void)connectServer {
//    //测试定时器代码
//    //开始注册了
//    if ([QMGlobaMacro shared].isStop) {
//        //定时时间到了
//        return;
//    }
//    [QMGlobaMacro shared].isStartTcp = YES;
    
//    self.autoConnection = NO;
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;

    NSString *webStr = sdkwebSocketUrl;
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:webStr]];
    self.webSocket.delegate = self;
    [self.webSocket open];
    self.connectStatus = 0; //链接中
}

//- (void)connectServered {
//    self.autoConnection = YES;
//    self.webSocket.delegate = nil;
//    [self.webSocket close];
//    self.webSocket = nil;
//
//    NSString *webStr = webSocket;
//    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:webStr]];
//    self.webSocket.delegate = self;
//    [self.webSocket open];
//    self.connectStatus = 0; //链接中
//}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
//    NSLog(@"didOpenSocket");
    
    if (_isDidOpen) {
        return;
    }
    _isDidOpen = YES;

    NSString *mobileType = QMGlobaMacro.deviceModelName;
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *socketStr = [NSString stringWithFormat:@"1{\"Action\":\"sdkLogin\",\"AccessId\":\"%@\",\"Platform\":\"%@\",\"DeviceId\":\"%@\",\"NewVersion\":\"true\",\"UserId\":\"%@\",\"UserName\":\"%@\",\"sdkIosVersionCode\":\"%0.1f\",\"ApnsDeviceId\":\"%@\",\"sdkVersionCode\":\"%@\"}", _accessID, mobileType, deviceID, _password, _userName, custom_version, _apnsToken, sdkIOSVersion];
    [self.webSocket sendString:socketStr error:NULL];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    NSLog(@"didReceiveMessage===%@",message);
    self.connectStatus = 1;
    NSString *str = message;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNotification:str];
    });
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
//    NSLog(@"didFailWithError===%@",error);
    if (self.reConnectTimer.valid) {
        return;
    }
    self.connectStatus = 0;
    [self reConnectServer];
}

//接收ping
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
//    NSLog(@"receivePing===%@",pongPayload);
//    NSString *receiverStr = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
//    NSLog(@"receiverStr===%@",receiverStr);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
//    NSLog(@"didCloseWithCode===%ld===\nReason===%@===\nwasClean===%@",(long)code,reason,wasClean == YES ? @"yes" : @"no");
}

#pragma mark - heartBeat
//初始化心跳
- (void)startHeartBeat {
    if (self.heartBeatTimer) {
        return;
    }
    [self cancelHeartBeat];
    
    self.heartBeatTimer  = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop]addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
}

//取消心跳
- (void)cancelHeartBeat {
    if (self.heartBeatTimer) {
        [self.heartBeatTimer invalidate];
        self.heartBeatTimer = nil;
    }
}

//发送心跳
- (void)senderheartBeat {
    if (self.webSocket.readyState == SR_OPEN) {
        [self sendPing:@"3"];
    }
}

- (void)sendPing:(NSString *)data {
//    NSLog(@"sendPing====%@",data);
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.webSocket sendPing:requestData error:NULL];
}

//重新链接
- (void)reConnectServer {
    if (self.webSocket.readyState == SR_OPEN && self.reConnectTimer) {
        return;
    }
    
    self.connectStatus = 0;
    if (self.statusBlock) {
        self.statusBlock(0);
    }
    
    self.reConnectTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reConnection) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.reConnectTimer forMode:NSRunLoopCommonModes];
    [self.reConnectTimer fire];
}

- (void)reConnection {
    if (self.reConnectCount < webScoketConnectLimit) {
        self.reConnectCount += 1;
        
    }else {
        self.reConnectCount = -1;
        //重新请求环境地址
    }
    _isDidOpen = NO;
    [self connectServer];
}

- (void)endReconnect {
    if (self.reConnectTimer) {
        [self.reConnectTimer invalidate];
        self.reConnectTimer = nil;
    }
}

//- (void)RMWebSocketClose {
//    _isDidOpen = NO;
//    self.connectStatus = -0;
//    [self endReconnect];
//    [self cancelHeartBeat];
//    [self.webSocket close];
//}

//手动断开socket
- (void)disConnectSocket {
    _isDidOpen = NO;
    self.autoConnection = NO;
//    if (self.connectStatus == 1) {
//        [self sendPing:@"quit"];
//    }
    
    self.connectStatus = -1;
    
    if (self.statusBlock) {
        self.statusBlock(-1);
    }
    
    [self endReconnect];
    [self cancelHeartBeat];
    [self.webSocket close];
}

#pragma mark - 推送的各种状态码
- (void)setNotification:(NSString *)str {
//    NSLog(@"读取数据包 ====== 得到的数据包 %@", str);

    if ([str hasPrefix:@"200"]) {
        NSArray *array = [str componentsSeparatedByString:@"#"];
        if (array.count > 1) {
            [[NSUserDefaults standardUserDefaults] setValue:array[1] forKey:CUSTOM_CONNECT_ID];
        }
        if (array.count > 2) {
            NSString *sid = array[2];
            if (sid.length > 1) {
//                NSString *sessionId = [sid substringWithRange:NSMakeRange(0, sid.length - 1)];
                NSString *sessionId = sid;
                [[NSUserDefaults standardUserDefaults] setValue:sessionId forKey:CUSTOM_SESSION_ID];
                [QMGlobaMacro shared].custom_sessionId = sessionId;
            }
            }
        
        [QMGlobaMacro shared].custom_accessId = _accessID;
        [QMGlobaMacro shared].registUserId = _password;
        
//        self.statusError = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self endReconnect];
            
            if (self.autoConnection) {
                
                if (array.count > 2) {
                    NSCharacterSet *withespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                    NSString *str = [array[2] stringByTrimmingCharactersInSet:withespace];
                    
                    [[QMLoginManager shared] isExistChat:str completion:^{
                        [[QMServiceMessage sharedInstance] afreshStatusErrorMessage];
                    } failure:^{
                        [[QMServiceMessage sharedInstance] changeMessageStatus];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                                [self.dataSource currentAgentStatus:QMKStatusFinish];
                            }
                            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_FINISH object:nil];
                        });
                    }];
                }
            } /*else {
                self.statusError = NO;
            }*/
            
            self.connectStatus = 1;
            if (self.statusBlock) {
                self.statusBlock(1);
            }
            self.reConnectCount = -1;
            
            [self startHeartBeat];
            
            [[QMServiceFunction sharedInstance] tryGetWebchatGlobleConfig:nil failure:nil];
            
            if (!self.autoConnection) {
                //测试定时器代码
                [QMGlobaMacro shared].isRegist = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(registerSuccess)]) {
                    [self.delegate registerSuccess];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_SUCCEED object:nil];
            }
            
            self.autoConnection = YES;

        });
    }else if ([str isEqualToString:@"5"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //测试定时器代码
            [QMGlobaMacro shared].isRegist = YES;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
                [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeServiceException]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeServiceException]];
        });
    }else if ([str isEqualToString:@"400"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //测试定时器代码
            [QMGlobaMacro shared].isRegist = YES;

            if (self.delegate && [self.delegate respondsToSelector:@selector(registerFailure:)]) {
                [self.delegate registerFailure:[QMLineError initWithError:QMRegisterErrorCodeAuthFailed]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOM_LOGIN_ERROR_USER object:[QMLineError initWithError:QMRegisterErrorCodeAuthFailed]];
        });
    }else if ([str isEqualToString:@"100"]) {
        [[QMServiceMessage sharedInstance] tryGetNewMessage:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endReciveMessage];
            });
        } failure:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startReciveMessage];
            });
        }];
    }else if ([str isEqualToString:@"robot"]) {
        [QMLoginManager shared].isManual = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusRobot];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ROBOT_SERVICE object:nil];
        });
    }else if ([str isEqualToString:@"online"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusOnline];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_ONLINE object:nil];
        });
    }else if ([str isEqualToString:@"offline"] || [str isEqualToString:@"convertManualFailed"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusOffline];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_OFFLINE object:nil];
        });
    }else if ([str isEqualToString:@"finish"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMGlobaMacro shared].replyMsg = 0;
            [QMGlobaMacro shared].chatID = @"";
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusFinish];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_FINISH object:nil];
        });
    }else if ([str isEqualToString:@"claim"]) {
        [QMLoginManager shared].isManual = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusClaim];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_CLAIM object:nil];
        });
    }else if ([str isEqualToString:@"investigate"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_INVESTIGATE object:nil];
        });
    }else if ([str hasPrefix:@"investigateNew"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = [str componentsSeparatedByString:@"@"];
            if (array.count == 3) {
                NSString *pushStr = array[1];
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *chatId = [array[2] stringByTrimmingCharactersInSet:whitespace];
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_INVESTIGATE object:@[pushStr, chatId]];
            }else if (array.count == 2) {
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *pushStr = [array[1] stringByTrimmingCharactersInSet:whitespace];
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_INVESTIGATE object:@[pushStr]];
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_INVESTIGATE object:nil];
            }
        });
    }else if ([str hasPrefix:@"queueNum"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = [str componentsSeparatedByString:@"@"];
            if (array.count > 1) {
                
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *queueNumber = [array[1] stringByTrimmingCharactersInSet:whitespace];
                
                int number = [queueNumber intValue];
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentSessionWaitNumber:)]) {
                    [self.dataSource currentSessionWaitNumber:number];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_QUEUENUM object:@(number)];
            }
        });
    }else if ([str hasPrefix:@"leavemsg"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = [str componentsSeparatedByString:@"@"];
            if (array.count > 2) {
                NSString *nodeId = array[1];
                NSString *peer = array[2];
                NSCharacterSet *withespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *peerId = [peer stringByTrimmingCharactersInSet:withespace];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_LEAVEMSG object:@[nodeId, peerId]];
            }
        });
    }else if ([str hasPrefix:@"vipAssignFail"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentStatus:)]) {
                [self.dataSource currentAgentStatus:QMKStatusVip];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIP object:nil];
        });
    }else if ([str hasPrefix:@"userInfo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QMAgent *agent = [self JSONStringToAgent:str];
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(currentAgentInfo:)]) {
                [self.dataSource currentAgentInfo:agent];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_AGENT object:agent];
        });
    }else if ([str hasPrefix:@"typeNotice"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_IMPORTING object:nil];
        });
    }else if ([str hasPrefix:@"withdrawMessage"]) {
        // 消息撤回agent
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = [str componentsSeparatedByString:@"@"];
            if (array.count > 1) {
                NSString *toPeers = array[1];
                NSString *toPeer = [toPeers substringWithRange:NSMakeRange(0, toPeers.length - 1)];
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_DRAWMESSAGE object:toPeer];
            }
        });
    }else if ([str isEqualToString:@"3"]) {
        
    }else if ([str hasPrefix:@"unassign"]){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIP object:nil];
//        });
    }else if ([str hasPrefix:@"m7botsatisfaction"]){
        dispatch_async(dispatch_get_main_queue(), ^{

            NSArray *array = [str componentsSeparatedByString:@"@"];
            if (array.count > 2) {
                NSString *isfaction = array[1];
                NSString *robotId = array[2];
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *robId = [robotId stringByTrimmingCharactersInSet:whitespace];
                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_SATISFACTION object:@[isfaction, robId]];
            }
        });
    }else if ([str hasPrefix:@"associationInput"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * array = [str componentsSeparatedByString:@"@"];
            
            if (array.count > 2) {
                NSInteger num = 0;
                NSString *isTrue = array[1];
                
                if ([isTrue isEqualToString:@"true"]) {
                    num = 1;
                }else {
                    num = 0;
                }
                
                NSString *thirdValue = @"";
                if (array.count > 3) {
                    thirdValue = array[3];
                }

                NSString *robotType = @"";
                if (array.count > 4) {
                    robotType = array[4];
                    if (robotType.length <= 0) {
                        num = 0;
                    }
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_ASSOCIATSINPUT object:@[@(num),@[],thirdValue, robotType, @"robot"]];
            }
            
//            if (array.count > 2) {
//                NSString *robotType = @"xbot";
//                if (array.count > 4) {
//                    robotType = array[4] == nil ? @"xbot" : array[4] ;
//                }
//
//                NSString *thirdValue = @"";
//                if (array.count > 3) {
//                    thirdValue = array[3];
//                }
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_ASSOCIATSINPUT object:@[array[1],@[],thirdValue, robotType]];
//
//            }
        });
    }else if ([str hasPrefix:@"humanAssociationInputSwitch"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * array = [str componentsSeparatedByString:@"@"];
            if (array.count > 2) {
                NSInteger num = 0;
                NSString *isTrue = array[1];
                
                if ([isTrue isEqualToString:@"true"]) {
                    num = 1;
                }else {
                    num = 0;
                }
                
                NSString *thirdValue = @"";
                if (array.count > 3) {
                    thirdValue = array[3];
                }

                NSString *robotType = @"";
                if (array.count > 4) {
                    robotType = array[4];
                    if (robotType.length <= 0) {
                        num = 0;
                    }
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_ASSOCIATSINPUT object:@[@(num),@[],thirdValue, robotType, @"agent"]];
            }
        });
    }else if ([str hasPrefix:@"voiceToText"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * array = [str componentsSeparatedByString:@"@"];
            if (array.count > 3) {
                NSString *messageId = array[1];
                NSString *text = array[2];
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *att = [array[3] stringByTrimmingCharactersInSet:whitespace];
                if ([att isEqualToString:@"21050000"]) {
                    BOOL isTrue = [[QMDataBase shared] updateVoiceMessageToText:text withMessageId:messageId];
                    if (isTrue) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VOICETEXT object:@[messageId,@""]];
                    }
                }else {
                    [[QMDataBase shared] changeVoiceTextShowoOrNot:@"0" messageId:messageId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VOICETEXT object:@[messageId,text]];
                }
            }
        });
    }else if ([str hasPrefix:@"dealMsg"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (str.length > 8) {
                NSString *sessionID = [str substringFromIndex:8];
                NSCharacterSet *withespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString *sessionId = [sessionID stringByTrimmingCharactersInSet:withespace];
                BOOL isTrue = [[QMDataBase shared] updateIsReadStatusWithSessionId:sessionId];
                if (isTrue) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
                }
            }            
        });
    } else if ([str hasPrefix:@"invitedVideo"]) {
        //        NSArray * array = [str componentsSeparatedByString:@"@"];
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_INVITE object:str];
        
    }else if ([str hasPrefix:@"refuseVideo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_REFUSE object:nil];
        });
    }else if ([str hasPrefix:@"cancelVideo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_CANCEL object:nil];
        });
    }else if ([str hasPrefix:@"videoChatInterrupt"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_INTERRUPT object:nil];
        });
    } else if ([str hasPrefix:@"acceptVideo"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_AcceptVideo object:nil];
    } else if ([str hasPrefix:@"hangupVideo"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VIDEO_HangupVideo object:nil];
    }else {
        
    }
}

- (QMAgent *)JSONStringToAgent:(NSString *)string {
    QMAgent * agent = [[QMAgent alloc] init];
    NSArray *array = [string componentsSeparatedByString:@"@"];
    if (array.count > 1) {
        [agent  setType:array[1]];
        NSString *type = array[1];
        if ([type isEqualToString:@"claim"] || [type isEqualToString:@"redirect"] || [type isEqualToString:@"robot"] || [type isEqualToString:@"activeClaim"]) {
            if (array.count > 2) {
                [agent setExten:array[2]];
            }
            if (array.count > 3) {
                [agent setName:array[3]];
            }
            if (array.count > 4) {
                [agent setIcon_url:array[4]];
            }
        }
    }
    return agent;
}

#pragma mark - message
- (void)startReciveMessage {
    if (self.messageTimer) {
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reciveMessage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.messageTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)endReciveMessage {
    if (self.messageTimer) {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
}

- (void)reciveMessage {
    [[QMServiceMessage sharedInstance] tryGetNewMessage:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endReciveMessage];
        });
    } failure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startReciveMessage];
        });
    }];
}


#pragma mark - 其他方法
- (BOOL)validateUserId:(NSString *)userId {
    NSString * emailRegex = @"[A-Z0-9a-z_-]";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:userId];
}

- (NSString *)getHexData:(NSData *)data {
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [NSMutableString new];
    for (NSUInteger i = 0; i < len; i++) {
        [hexString appendFormat:@"%@", [NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return hexString;
}

#pragma mark - dynamic
- (void)dynamicConnection {
    
    [[QMServiceBase sharedInstance] getRequestwebSocketAddress:_accessID userName:_userName userId:_password completion:^(NSString *address) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (address.length > 0) {
                sdkwebSocketUrl = [NSString stringWithFormat:@"ws://%@/webSocket",address];
            }
            [self connectServer];
        });
    } failure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectServer];
        });
    }];
}

@end
