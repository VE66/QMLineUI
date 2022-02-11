//
//  QMServiceMessage.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMServiceMessage.h"
#import "QMGlobaMacro.h"
#import "QMNetworkManager.h"
#import "QMMessage.h"
#import "QMDataBase.h"
#import "QMLineSDK.h"
#import "QiniuSDK.h"
#import "QMServiceBase.h"
#import "QMServiceFunction.h"
#import "QMWebSocketManager.h"

@implementation QMServiceMessage

+ (instancetype)sharedInstance {
    static QMServiceMessage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.array = [NSMutableArray array];
    });
    return instance;
}

# pragma mark -- 获取新消息
- (void)tryGetNewMessage:(void (^)(void))completion failure:(void (^)(void))failure {
    NSArray *messageIDs = [NSKeyedUnarchiver unarchiveObjectWithFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"msgId.archive"]];
    if (!messageIDs) {
        messageIDs = @[];
    }
    
    [[QMServiceBase sharedInstance] getNewMessage:messageIDs completion:^(NSDictionary *object) {
        NSArray *data = object[@"data"];
        
        NSMutableArray *newIDs = [NSMutableArray array];
        if (data && data.count > 0) {
            for (NSDictionary *jsonDict in data) {
                // json转class
                CustomMessage *message = [self jsonDataToCustomMessage:jsonDict];
                
                if (message._id) {
                    [newIDs addObject:message._id];
                    
                    // 插入数据库
                    [[QMDataBase shared] insertMessage:message];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //刷新界面
                [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
            });
        }
        
        // 消息ID是否归档
        [[QMServiceBase sharedInstance] getNewMessage:newIDs completion:^(NSDictionary *obj) {

        } failure:^{
            [NSKeyedArchiver archiveRootObject:newIDs toFile:[[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:@"msgId.archive"]];
        }];
    } failure:^{
        
    }];
    
}

#pragma mark -- 定时关闭会话的提示消息
- (void)sendBreakTipMessage:(NSString *)text {
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];
    if (!sessionId) {
        return;
    }
    
    CustomMessage *message = [[CustomMessage alloc] init];

    message._id = [[NSUUID UUID] UUIDString];
    message.createdTime = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];

    message.device = [QMGlobaMacro deviceModelName];
    message.platform = @"iOS";
    message.status = @"0";
    message.fromType = @"1";
    message.sessionId = sessionId;
    message.accessid = [QMGlobaMacro shared].custom_accessId;
    message.userId = [QMGlobaMacro shared].registUserId;
    message.messageType = @"text";
    message.message = text;
    message.userType = @"system";
    NSDictionary *result = [[QMDataBase shared] insertMessage:message];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
}

# pragma mark -- 发送文本消息
- (void)sendTextMessage:(NSString *)text completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    CustomMessage *message = [self createMessageWithMessageType:@"Text" filePath:nil content:text metaData:nil];
    
    [self sendTextWithMessage:message completion:completion failure:failure];
}

- (void)sendTextWithMessage:(CustomMessage *)message completion:(void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    //上面注释的没有屏蔽换行 会导致后端解析失败
    // 处理特殊字符
//    NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
//    NSString *encodeString = [message.message stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
//    NSString *newString = [encodeString stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
    
    NSString * newStr = [message.message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
    NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
    
//    NSLog(@"发送文本 %@", newString);
    NSDictionary *params = @{
                             @"Message": newString
                             };
    
    [[QMServiceBase sharedInstance] sendMessage:@"text" params:params completion:^(NSDictionary *object) {
        [self sendMsgSuccHandle:message andCompletionObject:object];
        completion();
    } failure:^(NSString *error){
        [self changeMessageStatusAndReload:message status:@"1"];
//        NSLog(@"文本上传server成功, 当前线程%@",[NSThread currentThread]);
        failure(error);
    }];
}

# pragma mark -- 发送图片消息
- (void)sendImageMessage:(NSString *)filePath image: (UIImage *)image completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 本地文件路径
    NSString *localFilePath = nil;
    if (image) {
        localFilePath = [[NSUUID UUID] UUIDString];
        NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:localFilePath];
        NSData *picData = UIImageJPEGRepresentation(image, 1.0);
        [picData writeToFile:realFilePath atomically:YES];
    }else {
        // 验证图片是否存在
        localFilePath = filePath;
    }
    
    // 消息实例化
    CustomMessage *message = [self createMessageWithMessageType:@"Image" filePath:localFilePath content:nil metaData:nil];
    
    [self sendImageWithMessage:message completion:completion failure:failure];
}

- (void)insertTextToIMDB:(CustomMessage *)message {
    [self changeMessageStatusAndReload:message status:@"0"];
}

- (void)sendMsgSuccHandle:(CustomMessage *)message andCompletionObject:(NSDictionary *)object {
    if ([self.array containsObject:message._id]) {
        [self.array removeObject:message._id];
    }
    [self changeMessageStatusAndReload:message status:@"0"];
    // 发送成功
    // TODO: 存储远程地址
    
    id when = object[@"when"];
    if (when) {
        message.createdTime = [NSString stringWithFormat:@"%@", when];
        [[QMDataBase shared] changeMessage:message time:when];
    }
}

- (void)sendImageWithMessage:(CustomMessage *)message completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 本地文件路径
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:message.localFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:realFilePath]) {
        failure(@"");
        return;
    }

    // 七牛存储路径
    NSString *qiNiuFilePath = [NSString stringWithFormat:@"kefu/picture/%@/%@/%@", [self nowTime], message.createdTime, message._id];
    
    // 上传文件至七牛
    [self sendFileToQiniuWithMessageType:qiNiuFilePath localFilePath:message.localFilePath metaData:nil progress:nil completion:^(NSString *name) {
        
//        NSString *remoteFilePath = [NSString stringWithFormat:@"https://fs-im-resources.7moor.com/%@", name];
        NSString *qiniuFile = [QMGlobaMacro shared].qiNiuFileServer;
        NSString *remoteFilePath = [NSString stringWithFormat:@"%@/%@", qiniuFile, name];
        message.remoteFilePath = remoteFilePath;
        NSDictionary *params = @{
                                 @"Message": remoteFilePath
                                 };
        [[QMDataBase shared] changeMessageRemotePath:message];
        
        [[QMServiceBase sharedInstance] sendMessage:@"image" params:params completion:^(NSDictionary *object) {
            [self sendMsgSuccHandle:message andCompletionObject:object];
            completion();
        } failure:^(NSString *error){
            [self changeMessageStatusAndReload:message status:@"1"];
            failure(error);
        }];
    } failure:^(NSString *reason) {

            [self changeMessageStatusAndReload:message status:@"1"];
        failure(reason);
    }];
}

# pragma mark -- 发送语音消息
- (void)sendAudioMessage:(NSString *)filePath data: (NSData *)data duration: (NSString *)duration completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 本地文件路径
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:realFilePath]) {
        failure(@"");
        return;
    }
    
    // 消息类实例化
    CustomMessage *message = [self createMessageWithMessageType:@"Audio" filePath:filePath content:nil metaData:@{@"duration":duration}];
    
    [self sendAudioWithMessage:message completion:completion failure:failure];
}

- (void)sendAudioWithMessage:(CustomMessage *)message completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 本地文件路径
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:message.localFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:realFilePath]) {
        failure(@"");
        return;
    }
    
    // 七牛存储路径
    NSString *qiNiuFilePath = [NSString stringWithFormat:@"kefu/sound/%@/%@/%@", [self nowTime], message.createdTime, message._id];
    
    // 上传文件至七牛
    [self sendFileToQiniuWithMessageType:qiNiuFilePath localFilePath:message.localFilePath metaData:nil progress:nil completion:^(NSString *name) {
        
//        NSString *remoteFilePath = [NSString stringWithFormat:@"https://fs-im-resources.7moor.com/%@", name];
        NSString *qiniuFile = [QMGlobaMacro shared].qiNiuFileServer;
        NSString *remoteFilePath = [NSString stringWithFormat:@"%@/%@", qiniuFile, name];
        message.remoteFilePath = remoteFilePath;
        NSDictionary *params = @{
                                 @"Message"       :remoteFilePath,
                                 @"VoiceSecond"   :message.recordSeconds
                                 };
        
        [[QMDataBase shared] changeMessageRemotePath:message];
        
        [[QMServiceBase sharedInstance] sendMessage:@"voice" params:params completion:^(NSDictionary *object) {

            [self sendMsgSuccHandle:message andCompletionObject:object];
            completion();            
        } failure:^(NSString *error){

            [self changeMessageStatusAndReload:message status:@"1"];
//            [self changeMessageStatusAndReload:message status:@"1"];
//            NSLog(@"语音上传serverh失败, 当前线程%@",[NSThread currentThread]);
            failure(error);
        }];
    } failure:^(NSString *reason) {
        [self changeMessageStatusAndReload:message status:@"1"];
        //        NSLog(@"语音上传七牛失败, 当前线程%@",[NSThread currentThread]);
        failure(reason);
    }];
}

# pragma mark -- 语音转文本
- (void)sendAudioToText:(NSString *)messageId filePath:(NSString *)filePath when:(NSString *)when completion:(void (^)(void))completion failure:(void (^)(void))failure {

    NSString *account = [[QMServiceFunction sharedInstance] tryGetGlobalValue:@"account"];
    [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VOICETEXT object:@[messageId,@""]];
    [[QMServiceBase sharedInstance] getVoiceToText:messageId accountId:account filePath:filePath when:when completion:^(NSDictionary *object) {
        NSString *voiceText = object[@"voiceMessage"];
        NSString *messageId = object[@"messageId"];
        if (voiceText.length > 0 && messageId.length > 0) {
            [[QMDataBase shared] updateVoiceMessageToText:voiceText withMessageId:messageId];
            [[QMDataBase shared] changeVoiceTextShowoOrNot:@"1" messageId:messageId];
            completion();
        }
    } failure:failure];
}

# pragma mark -- 发送文件消息
- (void)sendFilePath: (NSString *)filePath fileName: (NSString *)fileName fileSize: (NSString *)fileSize progressHander: (void (^)(float))progressHander completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 本地文件路径
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:realFilePath]) {
        failure(@"");
        return;
    }
    
    // 消息实例化
    CustomMessage *message = [self createMessageWithMessageType:@"File" filePath:filePath content:nil metaData:@{@"name":fileName, @"size":fileSize}];
    
    [self sendFileWithMessage:message progressHander:progressHander completion:completion failure:failure];
}

- (void)sendFileWithMessage:(CustomMessage *)message progressHander: (void (^)(float))progressHander completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    // 七牛存储路径
    NSString *qiNiuFilePath = [NSString stringWithFormat:@"kefu/file/%@/%@/%@", [self nowTime], message.createdTime, message.fileName];
    
    // 上传文件至七牛
    [self sendFileToQiniuWithMessageType:qiNiuFilePath localFilePath:message.localFilePath metaData:nil progress:^(float percent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:message._id object:@(percent)];
        if (progressHander) {
            progressHander(percent);
        }
    } completion:^(NSString *name) {
        
//        NSString *remoteFilePath = [NSString stringWithFormat:@"https://fs-im-resources.7moor.com/%@?fileName=%@?fileSize=%@", name, message.fileName, message.fileSize];
        NSString *qiniuFile = [QMGlobaMacro shared].qiNiuFileServer;
        NSString *remoteFilePath = [NSString stringWithFormat:@"%@/%@?fileName=%@?fileSize=%@", qiniuFile, name, message.fileName, message.fileSize];
        message.remoteFilePath = remoteFilePath;
        NSDictionary *params = @{
                                 @"Message": remoteFilePath
                                 };
        [[QMDataBase shared] changeMessageRemotePath:message];
        
        [[QMServiceBase sharedInstance] sendMessage:@"file" params:params completion:^(NSDictionary *object) {
            [self sendMsgSuccHandle:message andCompletionObject:object];

            completion();
        } failure:^(NSString *error){

            [self changeMessageStatusAndReload:message status:@"1"];
//            NSLog(@"文件上传server失败, 当前线程%@",[NSThread currentThread]);
            failure(error);
        }];
    } failure:^(NSString *reason) {
        [self changeMessageStatusAndReload:message status:@"1"];
//        NSLog(@"文件上传七牛失败, 当前线程%@",[NSThread currentThread]);
        failure(reason);
    }];
}

- (void)sendFile:(NSDictionary *)fileDic progressHander:(void (^)(float))progressHander completion: (void (^)(NSString *))completion failure:(void (^)(NSString *))failure {
    
    NSString *fileName = fileDic[@"fileName"];
    NSString *fileSize = fileDic[@"fileSize"];
    NSString *filePath = fileDic[@"filePath"];

    if (!fileName.length || !fileSize.length) {
        failure(@"fileName和fileSize不能为空");
        return;
    }
    NSString *createTime = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];

    // 七牛存储路径
    NSString *qiNiuFilePath = [NSString stringWithFormat:@"xbotForm/%@/%@/%@", [self nowTime], createTime, fileName];
        
    QNUploadOption *option = [self sendFormFileToQiniu:qiNiuFilePath localFilePath:filePath metaData:nil progress:^(float percent) {
        if (progressHander) {
            progressHander(percent);
        }
    } completion:^(NSString * name) {
//        NSString *fileUrl = [NSString stringWithFormat:@"https://fs-im-resources.7moor.com/%@?fileName=%@?fileSize=%@", name, fileName, fileSize];
        NSString *qiniuFile = [QMGlobaMacro shared].qiNiuFileServer;
        NSString *fileUrl = [NSString stringWithFormat:@"%@/%@?fileName=%@?fileSize=%@", qiniuFile, name, fileName, fileSize];
        completion(fileUrl);
    } failure:^(NSString *reason) {
        failure(reason);
    }];
}

# pragma mark -- Form类型文件存储至七牛服务器
- (QNUploadOption *)sendFormFileToQiniu:(NSString *)qiniuFilePath localFilePath: (NSString *)localFilePath metaData: (NSDictionary *)metaData progress: (void (^)(float))progress completion: (void (^)(NSString *))completion failure: (void (^)(NSString *))failure {
    
    NSString *newFilePath = [qiniuFilePath stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:localFilePath];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *option = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
        if (progress) {
            progress(percent);
        }
    }];
    
//    QNUploadOption *option = [[QNUploadOption alloc] initWithMime:@"" progressHandler:^(NSString *key, float percent) {
//        if (progress) {
//            progress(percent);
//        }
//    } params:@{} checkCrc:NO cancellationSignal:^BOOL{
//        return true;
//    }];

    [[QMServiceBase sharedInstance] getQiniuToken:newFilePath completion:^(NSDictionary *object) {
        NSString *token = object[@"uptoken"];
        
//        option.cancellationSignal();
//        QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
//            NSLog(@"percent = %.02f",percent);
//        } params:nil checkCrc:NO cancellationSignal:^BOOL{
//            return YES;
//        }];
                
        [upManager putFile:realFilePath key:newFilePath token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.ok) {
                completion(key);
            }else {
                failure(@"");
            }
        } option:option];
    } failure:^{
        failure(@"");
    }];
    
    return option;
}


# pragma mark -- 发送卡片消息到本地数据库
- (void)sendCardMessage:(NSDictionary *)cardinfo type:(NSString *)type completion: (void (^)(void))completion failure: (void (^)(void))failure {
    if ([type isEqual:@"card"]) {
        [self createMessageWithMessageType:@"Card" filePath:nil content:nil metaData:cardinfo];
    }else {
        [self createMessageWithMessageType:@"cardInfo_New" filePath:nil content:nil metaData:cardinfo];
    }
//    [self createMessageWithMessageType:@"Card" filePath:nil content:nil metaData:cardinfo];
}
# pragma mark -- 点击卡片上的发送 -- 发送到服务器
- (void)sendCardInfoMessage:(NSDictionary *)cardinfo completion: (void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    CustomMessage *message = [[CustomMessage alloc] init];
    NSString *sendCard = @"";
    NSMutableDictionary *params = @{
        @"Message" : @"",
        //                             @"cardInfo": cardInfo
    }.mutableCopy;
    
    if (cardinfo[@"showCardInfoMsg"]) {
        // 消息实例化
        message = [self createMessageWithMessageType:@"newCardInfo" filePath:nil content:nil metaData:cardinfo];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cardinfo options:NSJSONWritingPrettyPrinted error:nil];
        NSString *cardMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString * newStr = [cardMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
        NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
        
        [params setValue:@"新类型卡片消息" forKey:@"Message"];
        [params setValue:newString forKey:@"newCardInfo"];
        sendCard = @"newCardInfo";
    } else if (cardinfo[@"msg_task"]) {
        message = [self createMessageWithMessageType:@"newCardInfo" filePath:nil content:nil metaData:cardinfo[@"shopList"]];
        NSDictionary *msg_task = cardinfo[@"msg_task"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg_task options:NSJSONWritingPrettyPrinted error:nil];
        NSString *cardMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString * newStr = [cardMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
        NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
        
        NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:cardinfo[@"shopList"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *cardMessage1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
        NSString * newStr1 = [cardMessage1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *newString1 = [newStr1 stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];

        [params setValue:@"发送卡片信息" forKey:@"Message"];
        [params setValue:newString forKey:@"msgTask"];
        [params setValue:newString1 forKey:@"newCardInfo"];

        sendCard = @"msgTask";
        
    }else {
        // 消息实例化
        message = [self createMessageWithMessageType:@"CardInfo" filePath:nil content:nil metaData:cardinfo];
        sendCard = @"cardInfo";
        NSMutableDictionary *cardInfo = [NSMutableDictionary dictionary];
        if (message.cardImage) {
            
            NSString * newStr = [message.cardImage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
            NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
            
            NSDictionary *condition = @{@"url":newString};
            [cardInfo setValue:condition forKey:@"left"];
        }
        if (message.cardHeader) {
            NSString * newStr = [message.cardHeader stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
            NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
            NSDictionary *condition = @{@"text":newString};
            //        NSDictionary *condition = @{@"text":message.cardHeader};
            [cardInfo setValue:condition forKey:@"right1"];
        }
        if (message.cardSubhead) {
            NSString * newStr = [message.cardSubhead stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
            NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
            NSDictionary *condition = @{@"text":newString};
            [cardInfo setValue:condition forKey:@"right2"];
        }
        if (message.cardPrice) {
            NSString * newStr = [message.cardPrice stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
            NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
            NSDictionary *condition = @{@"text":newString};
            //        NSDictionary *condition = @{@"text":message.cardPrice};
            [cardInfo setValue:condition forKey:@"right3"];
        }
        if (message.cardUrl) {
            NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
            NSString *encodeString = [message.cardUrl stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];
            NSString *newString = [encodeString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            [cardInfo setValue:newString forKey:@"url"];
        }
        [params setValue:cardInfo forKey:@"cardInfo"];
        [params setValue:@"卡片消息" forKey:@"Message"];
    }
    
    [[QMServiceBase sharedInstance] sendMessage:sendCard params:params completion:^(NSDictionary *object) {
        [self sendMsgSuccHandle:message andCompletionObject:object];
        if (completion) {
            completion();
        }
    } failure:^(NSString *error){
        [self changeMessageStatusAndReload:message status:@"1"];
        if (failure) {
            failure(error);
        }
    }];
    
}

# pragma mark -- 发送满意度评价消息
//- (void)sendEvaluateMessage:(NSString *)text withID:(NSString *)ID withStatus:(NSString *)status withTimestamp:(NSString *)timestamp {
//CustomMessage *message = [self createMessageWithMessageType:@"evaluate" filePath:nil content:text metaData:@{@"id":ID, @"status":status,@"timestamp":timestamp}];
- (void)sendEvaluateMessage:(NSDictionary *)dic {
    if (!dic.count) {
        return;
    }
    CustomMessage *message = [self createMessageWithMessageType:@"evaluate" filePath:nil content:dic[@"text"] metaData:dic];
}

- (void)sendFormMessage:(NSDictionary *)dic {
    if (!dic.count) {
        return;
    }
//    CustomMessage *message = [self createMessageWithMessageType:@"xbotFormSubmit" filePath:nil content:dic[@"text"] metaData:dic];

    NSString *text = dic[@"text"];
//    NSString *text = @"提交成功!";

    NSString * newStr = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSCharacterSet *customAllowSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&+"].invertedSet;
    NSString *newString = [newStr stringByAddingPercentEncodingWithAllowedCharacters:customAllowSet];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *newDic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{
                             @"Message": newString,
                             @"xbotFormSubmit" :newDic
                             };
    
    [[QMServiceBase sharedInstance] sendMessage:@"xbotFormSubmit" params:params completion:^(NSDictionary *object) {
//        [self sendMsgSuccHandle:message andCompletionObject:object];
//        completion();
        dispatch_async(dispatch_get_main_queue(), ^{
           CustomMessage *message = [self createMessageWithMessageType:@"Text" filePath:nil content:text metaData:nil];
            [self sendMsgSuccHandle:message andCompletionObject:object];

        });
    } failure:^(NSString *error){
//        [self changeMessageStatusAndReload:message status:@"1"];
//        NSLog(@"文本上传server成功, 当前线程%@",[NSThread currentThread]);
//        failure(error);
    }];
}

# pragma mark -- 发送自定义消息
- (void)sendOtherInfoData:(NSDictionary *)mateData type:(NSString *)type {
    //此处的filePath充当 创建的status的状态
    if ([type isEqualToString:@"text"]) {
        [self createMessageWithMessageType:@"Text" filePath:@"零" content:mateData[@"text"] metaData:nil];
    }else {
        [self createMessageWithMessageType:type filePath:@"零" content:nil metaData:mateData];
    }
}

# pragma mark -- 重新发送消息
- (void)reSendMessageWithMessageType:(CustomMessage *)message completion:(void (^)(void))completion failure: (void (^)(NSString *))failure {
    
    [self changeMessageStatusAndReload:message status:@"2"];
    
    if ([message.messageType isEqualToString:@"text"]) {
        [self sendTextWithMessage:message completion:completion failure:failure];
    }else if ([message.messageType isEqualToString:@"voice"]) {
        [self sendAudioWithMessage:message completion:completion failure:failure];
    }else if ([message.messageType isEqualToString:@"image"]) {
        [self sendImageWithMessage:message completion:completion failure:failure];
    }else if ([message.messageType isEqualToString:@"file"]) {
        [self sendFileWithMessage:message progressHander:nil completion:completion failure:failure];
    }else {
        
    }
}

# pragma mark -- 断网时发生消息的处理--pc端未关闭会话
- (void)afreshStatusErrorMessage {
    if (self.array.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
        });
        return;
    }
    if (self.array.count > 0) {
        [self sendagainMessage];
    }
}

- (void)sendagainMessage {
    NSString *msgId = self.array.firstObject;
    NSArray *messageArr = [[QMDataBase shared] queryOneMessageWithID:msgId];
    if (messageArr.count > 0) {
        CustomMessage *message = messageArr[0];
        if (![message.status isEqualToString:@"0"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reSendMessageWithMessageType:message completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self afreshStatusErrorMessage];
                    });
                } failure:^(NSString *reason){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self afreshStatusErrorMessage];
                    });
                }];
            });
        } else {
            [self.array removeObject:message._id];
            [self afreshStatusErrorMessage];
        }
    }else{
        [self.array removeObject:msgId];
        if (self.array.count > 0) {
            [self afreshStatusErrorMessage];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
        });
    }
}

# pragma mark -- 断网时发生消息的处理--pc端未已经关闭会话
- (void)changeMessageStatus {
    NSMutableArray *arr = [self.array mutableCopy];
    NSMutableArray *failedArray = [[NSMutableArray alloc] init];
    if (arr.count > 0) {
        for (int i = 0; i<arr.count; i++) {
            NSArray *messageArr = [[QMDataBase shared] queryOneMessageWithID:arr[i]];
            if (messageArr.count > 0) {
                CustomMessage *message = messageArr[0];
                [self changeMessageStatusAndReload:message status:@"1"];
            }else {
                [failedArray addObject:arr[i]];
            }
        }
    }
    
    [self.array setArray:failedArray];
//    if (self.array.count > 0) {
//        [self changeMessageStatus];
//    }

}

# pragma mark -- 从七牛上下载文件
- (void)downLoadFileFromQiniuWithUrl:(CustomMessage *)message localFilePath:(NSString *)localFilePath progress:(void (^)(NSProgress *))progress completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
    if ([message.downloadState isEqualToString:@"2"]) {
        return;
    }

    NSString *string = [message.remoteFilePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:string];

    
    [self changeFileDownloadState:message state:@"2"];
    
    [[[QMNetworkManager alloc] initWithBaseURL:url] GET:@"" parameters:@{} progress:^(NSProgress *downloadProgress) {
        progress(downloadProgress);
    } success:^(NSURLSessionDownloadTask *task, id  _Nullable responseObject) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:localFilePath];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
        }
        
        NSError *error = nil;
        [fileManager moveItemAtPath:responseObject toPath:filePath error:&error];
        message.localFilePath = localFilePath;
        if (!error) {
            [[QMDataBase shared] changeMessageLocalPath:message];
            [self changeFileDownloadState:message state:@"0"];
            completion();
        }else {
            [self changeFileDownloadState:message state:@"1"];
            failure();
        }

    } failure:^(NSURLSessionDownloadTask * _Nullable task, NSError *error) {
        [self changeFileDownloadState:message state:@"1"];
        failure();
    }];
}

# pragma mark -- 存储文件至七牛服务器
- (void)sendFileToQiniuWithMessageType: (NSString *)qiniuFilePath localFilePath: (NSString *)localFilePath metaData: (NSDictionary *)metaData progress: (void (^)(float))progress completion: (void (^)(NSString *))completion failure: (void (^)(NSString *))failure {
    
    NSString *newFilePath = [qiniuFilePath stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    NSString *realFilePath = [[QMGlobaMacro pathOfDocument] stringByAppendingPathComponent:localFilePath];
    
    [[QMServiceBase sharedInstance] getQiniuToken:newFilePath completion:^(NSDictionary *object) {
        NSString *token = object[@"uptoken"];
            
        QNUploadManager *upManager;
        if ([QMGlobaMacro shared].isQINiuServer) {
            QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
                builder.useHttps = YES;
                builder.putThreshold = 10000*1024*1024;
                builder.zone = [[QNFixedZone alloc] initWithUpDomainList:@[[QMGlobaMacro shared].qiNiuZoneServer]];
            }];
            upManager = [[QNUploadManager alloc] initWithConfiguration:config];
        }else {
            upManager = [[QNUploadManager alloc] init];
        }
        
//        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        QNUploadOption *option = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
            if (progress) {
                progress(percent);
            }
        }];

        [upManager putFile:realFilePath key:newFilePath token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.ok) {
                completion(key);
            }else {
                failure(@"");
            }
        } option:option];
    } failure:^{
        failure(@"");
    }];
}

# pragma mark -- 修改消息状态
- (void)changeMessageStatusAndReload: (CustomMessage *)message status: (NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        message.status = status;
        [[QMDataBase shared] changeMessageType:message isSuccess:status];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    });
}

# pragma mark -- 修改文件下载状态
- (void)changeFileDownloadState: (CustomMessage *)message state: (NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        message.downloadState = state;
        [[QMDataBase shared] changeMessageDownloadState:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    });
}

# pragma mark -- 获取当前时间
- (NSString *)nowTime {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [dateFormatter stringFromDate:date];
}

# pragma mark -- 建立消息模型
- (CustomMessage *)createMessageWithMessageType: (NSString *)type filePath: (NSString *)filePath content: (NSString *)content metaData: (NSDictionary *)metaData {
    
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];
    if (!sessionId) {
        return nil;
    }
    
    CustomMessage *message = [[CustomMessage alloc] init];
    
    message._id = [[NSUUID UUID] UUIDString];
    message.createdTime = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]*1000];
    
    message.device = [QMGlobaMacro deviceModelName];
    message.platform = @"iOS";
    message.status = @"2";
    message.fromType = @"0";
    message.sessionId = sessionId;
    message.accessid = [QMGlobaMacro shared].custom_accessId;
    message.userId = [QMGlobaMacro shared].registUserId;
    message.userType = @"my";
    message.isRead = @"0";

    //发送自定义消息时修改消息状态
    if ([filePath isEqualToString:@"零"]) {
        message.status = @"0";
    }

    if ([type isEqualToString:@"Text"]) {
        message.message = content;
        message.messageType = @"text";
    }else if ([type isEqualToString:@"Image"]) {
        message.message = filePath;
        message.localFilePath = filePath;
        message.messageType = @"image";
    }else if ([type isEqualToString:@"Audio"]) {
        message.message = filePath;
        message.localFilePath = filePath;
        message.messageType = @"voice";
        message.recordSeconds = [metaData objectForKey:@"duration"];
//        message.isRead = @"1";
        message.voiceRead = @"1";
        message.messageStatus = @"0";
    }else if ([type isEqualToString:@"File"]) {
        message.message = filePath;
        message.fileName = [metaData objectForKey:@"name"];
        message.fileSize = [metaData objectForKey:@"size"];
        message.localFilePath = filePath;
        message.messageType = @"file";
        message.downloadState = @"1";
    }else if ([type isEqualToString:@"Card"]) {
        message.message = @"";
        message.messageType = @"card";
        message.cardImage = [metaData objectForKey:@"cardImage"];
        message.cardHeader = [metaData objectForKey:@"cardHeader"];
        message.cardSubhead = [metaData objectForKey:@"cardSubhead"];
        message.cardPrice = [metaData objectForKey:@"cardPrice"];
        message.cardUrl = [metaData objectForKey:@"cardUrl"];
    }else if ([type isEqualToString:@"CardInfo"]) {
        message.messageType = @"cardInfo";
        message.cardImage = [metaData objectForKey:@"cardImage"];
        message.cardHeader = [metaData objectForKey:@"cardHeader"];
        message.cardSubhead = [metaData objectForKey:@"cardSubhead"];
        message.cardPrice = [metaData objectForKey:@"cardPrice"];
        message.cardUrl = [metaData objectForKey:@"cardUrl"];
    }else if ([type isEqualToString:@"cardInfo_New"]) {
        message.messageType = @"cardInfo_New";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaData options:NSJSONWritingPrettyPrinted error:nil];
        message.cardInfo_New = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else if ([type isEqualToString:@"newCardInfo"]) {
        message.messageType = @"newCardInfo";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaData options:NSJSONWritingPrettyPrinted error:nil];
        message.cardMessage_New = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else if ([type isEqualToString:@"video"]) {
        message.videoStatus = @"1";
    }else if ([type isEqualToString:@"evaluate"]) {
        message.message = content;
        message.evaluateId = [metaData objectForKey:@"id"];
        message.evaluateStatus = [metaData objectForKey:@"status"];
        message.evaluateTimestamp = [metaData objectForKey:@"timestamp"];
        message.evaluateTimeout = [metaData objectForKey:@"timeout"];
        message.messageType = @"evaluate";
    }else if ([type isEqualToString:@"listCard"]) {
        message.messageType = @"listCard";
        NSArray *quickMenu = [metaData objectForKey:@"quickMenu"];
        NSString *quiclTime = [NSString stringWithFormat:@"%@",[metaData objectForKey:@"quickMenuWhen"]];
        if (quiclTime.length > 6) {
            message.createdTime = quiclTime;
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:quickMenu options:NSJSONWritingPrettyPrinted error:nil];
        message.cardMessage_New = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
//    else if ([type isEqualToString:@"xbotFormSubmit"]) {
//        message.message = content
//    }
    else {
        message.messageType = type;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metaData options:NSJSONWritingPrettyPrinted error:nil];
        message.cardInfo_New = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    if ([QMWebSocketManager shared].connectStatus == -1) {
        [self.array addObject:message._id];
    }
    
    NSDictionary *result = [[QMDataBase shared] insertMessage:message];
    
//    NSLog(@"插入数据成功了么 %@ == %@ == %@", [result objectForKey:@"success"], [result objectForKey:@"errMessage"], [result objectForKey:@"messageId"]);
    [QMGlobaMacro shared].monitorDict = result;
    
//    NSLog(@"插入数据库成功，第一次reload, 当前线程%@",[NSThread currentThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    
    return message;
}

# pragma mark -- 消息json转CustomMessage类
- (CustomMessage *)jsonDataToCustomMessage: (NSDictionary *)dictionary {
    
    CustomMessage *message = [[CustomMessage alloc] init];
    
    // TODO: 可能会有问题
    message.fromType = @"1";
    
    message.status = @"0";
    

    // 消息id
    if (dictionary[@"_id"]) {
        message._id = dictionary[@"_id"];
    }else {
        return nil;
    }
    
    // 消息类型
    NSString *contentType = dictionary[@"contentType"];
    if (contentType) {
        message.messageType = contentType;
    }else {
        message.messageType = @"text";
    }
    
    // 消息内容
    NSString *content = dictionary[@"content"];
    if (content) {
        message.message = content;
        if ([message.messageType isEqualToString:@"text"]) {
            message.isUseful = @"none";
        }else if ([message.messageType isEqualToString:@"image"]) {
            message.remoteFilePath = content;
        }else if ([message.messageType isEqualToString:@"voice"]) {
            message.remoteFilePath = content;
            message.localFilePath = [message._id stringByAppendingString:@".mp3"];
//            message.isRead = @"0";
            message.voiceRead = @"0";
            message.messageStatus = @"0";
        }else if ([message.messageType isEqualToString:@"file"]) {
            NSArray *fileArray = [message.message componentsSeparatedByString:@"?"];
            if (fileArray.count > 2) {
                message.fileName = [fileArray[1] substringFromIndex:9];
                message.fileSize = [fileArray[2] substringFromIndex:9];
                message.remoteFilePath = fileArray[0];
            }else {
                message.fileName = @"未知文件";
                message.fileSize = @"0 KB";
                message.remoteFilePath = @"";
            }
            message.downloadState = @"1";
            message.mp3FileSize = @"0";
        }else if ([message.messageType isEqualToString:@"iframe"]) {
            message.remoteFilePath = content;
        }else if ([message.messageType isEqualToString:@"richText"]) {
            NSString *richTextUrl = dictionary[@"richTextUrl"];
            NSString *richTextPicUrl = dictionary[@"richTextPicUrl"];
            NSString *richTextTitle = dictionary[@"richTextTitle"];
            NSString *richTextDescription = dictionary[@"richTextDescription"];
            message.richTextUrl = richTextUrl ? richTextUrl : @"";
            message.richTextPicUrl = richTextPicUrl ? richTextPicUrl : @"";
            message.richTextTitle = richTextTitle ? richTextTitle : @"";
            message.richTextDescription = richTextDescription ? richTextDescription : @"";
        }else if ([message.messageType isEqualToString:@"card"]) {
            NSString *cardImage = dictionary[@"cardImage"];
            NSString *cardHeader = dictionary[@"cardHeader"];
            NSString *cardSubhead = dictionary[@"cardSubhead"];
            NSString *cardPrice = dictionary[@"cardPrice"];
            NSString *cardUrl = dictionary[@"cardUrl"];
            message.cardImage = cardImage ? cardImage : @"";
            message.cardHeader = cardHeader ? cardHeader : @"";
            message.cardSubhead = cardSubhead ? cardSubhead : @"";
            message.cardPrice = cardPrice ? cardPrice : @"";
            message.cardUrl = cardUrl ? cardUrl : @"";
        }else if ([message.messageType isEqualToString:@"video"]) {
            NSString *type = dictionary[@"type"];
            if ([type isEqualToString:@"in"]) {
                message.fromType = @"0";
            }else {
                message.fromType = @"1";
            }
            message.message = content;
            NSString *videoStatus = dictionary[@"videoStatus"];
//            if ([videoStatus.lowercaseString isEqualToString:@"cancel"]) {
//                message.fromType = @"0";
//            }
//            message.message = @"不支持视频类型消息";
        }else if ([message.messageType isEqualToString:@"cardInfo"]) {
            
        }else if ([message.messageType isEqualToString:@"newCardInfo"]) {
            NSString *cardStr = dictionary[@"newCardInfo"];
            if (cardStr.length > 0) {
                message.cardMessage_New = cardStr;
                if (message.cardMessage_New.length > 0) {
                    NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    message.cardMsg_NewDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                }
            }else{
                message.cardMessage_New = @"";
                message.cardMsg_NewDict = nil;
            }
        }else if ([message.messageType isEqualToString:@"msgTask"]) {
            NSString *cardStr = dictionary[@"msgTask"];
            if (cardStr.length > 0) {
                message.cardMessage_New = cardStr;
                if (message.cardMessage_New.length > 0) {
                         NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
                         NSError *err;
                         message.cardMsg_NewDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                     }
            }else{
                message.cardMessage_New = @"";
                message.cardMsg_NewDict = nil;
            }
        }else if ([message.messageType isEqualToString:@"NewPushQues"]) {
            if (dictionary[@"common_questions_group"]) {
                NSArray *arr = dictionary[@"common_questions_group"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
                NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                message.common_questions_group = strJson;
                message.common_selected_index = @"0";
            }else {
                message.common_questions_group = @"";
            }
            
            if (dictionary[@"common_questions_img"]) {
                message.common_questions_img = dictionary[@"common_questions_img"];
            }else {
                message.common_questions_img = @"";
            }
        }else if ([message.messageType isEqualToString:@"xbotForm"]) {
            NSString *xbotForm = dictionary[@"xbotForm"];
            if (xbotForm) {
                message.xbotForm = xbotForm;
                message.xbotFirst = @"1";
            }else {
                message.xbotForm = @"";
            }
        }else {
            
        }
    }else {
        message.message = @"message is error";
    }
    
    // iframe消息宽度
    if (dictionary[@"iframeWidth"]) {
        message.width = dictionary[@"iframeWidth"];
    }
    
    // iframe消息高度
    if (dictionary[@"iframeHeight"]) {
        message.height = dictionary[@"iframeHeight"];
    }
    
    // 会话id
    if (dictionary[@"sid"]) {
        message.sessionId = dictionary[@"sid"];
    }
    
    // 访客id
    message.userId = [QMGlobaMacro shared].registUserId;
    
    // 渠道id
    if (dictionary[@"accessId"]) {
        message.accessid = dictionary[@"accessId"];
    }
    
    // 消息时间
    if (dictionary[@"when"]) {
        message.createdTime = [NSString stringWithFormat:@"%@", dictionary[@"when"]];
    }
    
    // 语音时间
    if (dictionary[@"voiceSecond"]) {
        message.recordSeconds = dictionary[@"voiceSecond"];
    }
    
    if (dictionary[@"exten"]) {
        message.agentExten = dictionary[@"exten"];
    }
    
    if (dictionary[@"displayName"]) {
        message.agentName = dictionary[@"displayName"];
    }
    
    if (dictionary[@"im_icon"]) {
        message.agentIcon = dictionary[@"im_icon"];
    }
    
    if (dictionary[@"showHtml"]) {
        BOOL isRobot = [dictionary[@"showHtml"] boolValue];
        message.isRobot = isRobot ? @"1" : @"0";
    }else {
        message.isRobot = @"0";
    }
    
    // 机器人问题id
    if (dictionary[@"questionId"]) {
        message.questionId = dictionary[@"questionId"];
    }else {
        message.questionId = @"";
    }
    
    if (dictionary[@"robotType"]) {
        message.robotType = dictionary[@"robotType"];
    }
    
    if (dictionary[@"robotId"]) {
        message.robotId = dictionary[@"robotId"];
    }else {
        message.robotId = @"";
    }
    
    if (dictionary[@"robotMsgId"]) {
        message.robotMsgId = dictionary[@"robotMsgId"];
    }else {
        message.robotMsgId = @"";
    }
    
    if (dictionary[@"confidence"]) {
        message.confidence = dictionary[@"confidence"];
    }else {
        message.confidence = @"";
    }
    
    if (dictionary[@"ori_question"]) {
        message.ori_question = dictionary[@"ori_question"];
    }else {
        message.ori_question = @"";
    }
    
    if (dictionary[@"std_question"]) {
        message.std_question = dictionary[@"ori_question"];
    }else {
        message.std_question = @"";
    }
    
    if (dictionary[@"sessionId"]) {
        message.robotSessionId = dictionary[@"sessionId"];
    }else {
        message.robotSessionId = @"";
    }
    
    if (dictionary[@"flowList"]) {
        NSArray *arr = dictionary[@"flowList"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
        NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        message.robotFlowList = strJson;
    }else {
        message.robotFlowList = @"";
    }
    
    if (dictionary[@"flowTip"]) {
        message.robotFlowTip = dictionary[@"flowTip"];
    }else {
        message.robotFlowTip = @"";
    }
    
    if (dictionary[@"flowType"]) {
        message.robotFlowType = dictionary[@"flowType"];
        if ([dictionary[@"flowType"] isEqualToString:@"button"]) {
            message.isRobot = @"2";
        }else {
            message.isRobot = @"1";
        }
    }else {
        message.robotFlowType = @"";
    }
    
    if (dictionary[@"flowStyle"]) {
        message.robotFlowsStyle = dictionary[@"flowStyle"];
    }else {
        message.robotFlowsStyle = 0;
    }
    
    if (dictionary[@"flowMultiSelect"]) {
        message.robotFlowSelect = dictionary[@"flowMultiSelect"];
    }else {
        message.robotFlowSelect = 0;
    }
    
    if (dictionary[@"user"]) {
        message.userType = dictionary[@"user"];
    }else {
        message.userType = @"";
    }
        
    if (dictionary[@"fingerUp"]) {
        message.fingerUp = dictionary[@"fingerUp"];
    }else {
        message.fingerUp = @"";
    }
    
    if (dictionary[@"fingerDown"]) {
        message.fingerDown = dictionary[@"fingerDown"];
    }else {
        message.fingerDown = @"";
    }
    
    if (dictionary[@"dealUserMsg"]) {
        message.isRead = dictionary[@"dealUserMsg"];
    }else {
        message.isRead = @"0";
    }
    
    if (dictionary[@"videoStatus"]) {
        message.videoStatus = dictionary[@"videoStatus"];
    }else {
        message.videoStatus = @"";
    }
    
    return message;
    
}



@end
