//
//  QMDataBase.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMDataBase.h"
#import "QMGlobaMacro.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "QMChatFileTextAttachment.h"
#import "QMConnect.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+QMImage.h"

static NSString * _ID = @"_id";
static NSString * DEVICEINFO = @"deviceInfo";
static NSString * ACCOUNT = @"account";
static NSString * FROM = @"fromm";
static NSString * MESSAGE = @"message";
static NSString * CONTENTTYPE = @"ContentType";
static NSString * PLATFORM = @"platform";
static NSString * SESSIONID = @"sessionId";
static NSString * TONOTIFY = @"tonotify";
static NSString * WHEN = @"whenn";
static NSString * TYPE = @"type";
static NSString * CHATTYPE = @"chatType";
static NSString * HIDETIME = @"hideTime";
static NSString * ISSUCCESS = @"isSuccess";
static NSString * VOICESECOND = @"voiceSecond";

static NSString * REMOTEFILEPATH = @"remoteFilePath";
static NSString * LOCALFILEPATH = @"localFilePath";
static NSString * FILESIZE = @"fileSize";
static NSString * FILENAME = @"fileName";
static NSString * DOWNLOADSTATE = @"downloadState";

static NSString * WIDTH = @"width";
static NSString * HEIGHT = @"height";

static NSString * AGENTEXTEN = @"agentExten";
static NSString * AGENTNAME = @"agentName";
static NSString * AGENTICON = @"agentIcon";

static NSString * AUDIOTEXT = @"audioText";

static NSString * ISROBOT = @"isRobot";
static NSString * ISREAD = @"isRead";

static NSString * ISUSEFUL = @"isUseful";
static NSString * QUESTIONID = @"questionId";

//富文本字段
static NSString * RICHTEXTURL = @"richTextUrl";
static NSString * RICHTEXTPICURL = @"richTextPicUrl";
static NSString * RICHTEXTTITLE = @"richTextTitle";
static NSString * RICHTEXTDESCRIPTION = @"richTextDescription";

//AI字段
static NSString * ROBOTTYPE = @"robotType";
static NSString * ROBOTID = @"robotId";
static NSString * ROBOTMSGID = @"robotMsgId";
static NSString * CONFIDENCE = @"confidence";
static NSString * ORI_QUESTION = @"ori_question";
static NSString * STD_QUESTION = @"std_question";
static NSString * ROBOTSESSIONID = @"robotSessionId";
static NSString * ROBOTFLOWLIST = @"robotFlowList";
static NSString * ROBOTFLOWTIP = @"robotFlowTip";
static NSString * ROBOTFLOWTYPE = @"robotFlowType";
static NSString * ROBOTFLOWSTYLE = @"robotFlowStyle";
static NSString * ROBOTFLOWSELECT = @"robotFlowSelect";
static NSString * ROBOTFLOWSEND = @"robotFlowSend";

static NSString * MP3FILESIZE = @"mp3FileSize";
static NSString * ACCESSID = @"accessid";

//商品信息字段
static NSString * CARDIMAGE = @"cardImage";
static NSString * CARDHEADER = @"cardHeader";
static NSString * CARDSUBHEAD = @"cardSubhead";
static NSString * CARDPRICE = @"cardPrice";
static NSString * CARDURL = @"cardUrl";
//新版本的商品信息
static NSString * CARDINFO_NEW = @"cardInfo_New";
static NSString * CARDMESSAGE_NEW = @"cardMessage_New";
//注册的userId
static NSString * USERID = @"userId";

// messageCard 读取状态
static NSString * QMCardMessageReadStats = @"QMMessageReadStats";

//消息类型userType  system&robot&人工
static NSString * USERTYPE = @"userType";
//消息是否展示
static NSString * MESSAGESTATUS = @"messageStatus";
//xbot机器人点赞点踩
static NSString * FINGERUP = @"fingerUp";
static NSString * FINGERDOWN = @"fingerDown";

static NSString * VOICEREAD = @"voiceRead";
// videoStatus 视频接通状态
static NSString * VIDEOSTATUS= @"videoStatus";

//满意度id和状态
static NSString *EVALUATEID = @"evaluateId";
static NSString *EVALUATESTATUS = @"evaluateStatus";
static NSString *EVALUATETIMESTAMP = @"evaluateTimestamp";
static NSString *EVALUATETIMEOUT = @"evaluateTimeout";

static NSString *COMMONQUESTIONSGROUP = @"common_questions_group";
static NSString *COMMONSELECTEDINDEX = @"common_selected_index";
static NSString *COMMONQUESTIONSIMG = @"common_questions_img";
static NSString *XBOTFORM = @"xbotForm";
static NSString *XBOTFIRST = @"xbotFirst";

@interface QMDataBase()

@property (nonatomic, strong)NSString *dbPath;

@property (nonatomic, strong)FMDatabaseQueue *dbQueue;

@property (nonatomic, strong)FMDatabase *db1;

@end

@implementation QMDataBase

// 数据库队列、确保线程安全
- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        FMDatabaseQueue *fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
        _dbQueue = fmdbQueue;
        [self.db1 close];
        self.db1 = [fmdbQueue valueForKey:@"_db"];
//        NSLog(@"创建数据库111 === %@", self.db1);
    }
    return _dbQueue;
}

// 单例
+ (instancetype)shared {
    static QMDataBase *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject];
        NSString *filePath = [documents stringByAppendingPathComponent:@"CustomMessageTable.sqlite"];
        
        FMDatabase *fmdb = [FMDatabase databaseWithPath:filePath];
        instance.db1 = fmdb;
        instance.dbPath = filePath;
        
        if (![instance isExistTable]) {
            [instance createTable];
        }else {
            NSArray *columns = [instance getAllColumns];
            
            NSArray *keys = @[_ID, ACCOUNT, DEVICEINFO, FROM, MESSAGE, CONTENTTYPE, PLATFORM, SESSIONID, TONOTIFY, WHEN, TYPE, CHATTYPE, HIDETIME, ISSUCCESS, VOICESECOND, REMOTEFILEPATH, LOCALFILEPATH, FILESIZE, FILENAME, DOWNLOADSTATE, WIDTH, HEIGHT, AGENTEXTEN, AGENTNAME, AGENTICON, AUDIOTEXT, ISROBOT, ISREAD, ISUSEFUL, QUESTIONID, RICHTEXTURL, RICHTEXTPICURL, RICHTEXTTITLE, RICHTEXTDESCRIPTION, ROBOTTYPE, ROBOTID, MP3FILESIZE, ACCESSID, CARDIMAGE, CARDHEADER, CARDSUBHEAD, CARDPRICE, CARDURL, USERID, ROBOTMSGID, CONFIDENCE, ORI_QUESTION, STD_QUESTION, ROBOTSESSIONID, ROBOTFLOWLIST, ROBOTFLOWTIP, ROBOTFLOWTYPE, CARDINFO_NEW, CARDMESSAGE_NEW, QMCardMessageReadStats, USERTYPE, MESSAGESTATUS, FINGERUP, FINGERDOWN, ROBOTFLOWSTYLE, VOICEREAD, VIDEOSTATUS, EVALUATEID, EVALUATESTATUS, EVALUATETIMESTAMP, EVALUATETIMEOUT, COMMONQUESTIONSGROUP, COMMONSELECTEDINDEX, ROBOTFLOWSELECT, ROBOTFLOWSEND, XBOTFORM, XBOTFIRST, COMMONQUESTIONSIMG];
            
            NSMutableArray *resultArr = [NSMutableArray array];
            for (NSString *key in keys) {
                if (![columns containsObject:key]) {
                    [resultArr addObject:key];
                }
            }
            
            [[instance dbQueue] inDatabase:^(FMDatabase *db) {
                for (NSString *column in resultArr) {
                    if (column) {
                        NSString *alterSql = [NSString stringWithFormat:@"alter table CustomMessageTable add %@ text", column];
                        if ([column isEqualToString:QMCardMessageReadStats]) {
                            alterSql = [NSString stringWithFormat:@"alter table CustomMessageTable add %@ integer DEFAULT 0", column];
                        }
                        [db executeUpdate:alterSql];
                    }
                }
            }];
        }
    });
    return instance;
}

- (BOOL)isExistTable {
    
    __block BOOL res = NO;
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *tableName = @"CustomMessageTable";
        res = [db tableExists:tableName];
        
    }];
    return res;
}

- (NSArray *)getAllColumns {
    __block NSMutableArray *columns = [NSMutableArray array];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *tableName = @"CustomMessageTable";
        FMResultSet *result = [db getTableSchema:tableName];
        while ([result next]) {
            NSString *column = [result stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return columns;
}

# pragma mark -- 创建表
- (void)createTable {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists CustomMessageTable (%@ text primary key, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ integer DEFAULT 0, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text)", _ID, ACCOUNT, DEVICEINFO, FROM, MESSAGE, CONTENTTYPE, PLATFORM, SESSIONID, TONOTIFY, WHEN, TYPE, CHATTYPE, HIDETIME, ISSUCCESS, VOICESECOND, REMOTEFILEPATH, LOCALFILEPATH, FILESIZE, FILENAME, DOWNLOADSTATE, WIDTH, HEIGHT, AGENTEXTEN, AGENTNAME, AGENTICON, AUDIOTEXT, ISROBOT, ISREAD, ISUSEFUL, QUESTIONID, RICHTEXTURL, RICHTEXTPICURL, RICHTEXTTITLE, RICHTEXTDESCRIPTION, ROBOTTYPE, ROBOTID, MP3FILESIZE, ACCESSID, CARDIMAGE, CARDHEADER, CARDSUBHEAD, CARDPRICE, CARDURL, USERID, ROBOTMSGID, CONFIDENCE, ORI_QUESTION, STD_QUESTION, ROBOTSESSIONID, ROBOTFLOWLIST, ROBOTFLOWTIP, ROBOTFLOWTYPE, CARDINFO_NEW, CARDMESSAGE_NEW, QMCardMessageReadStats, USERTYPE, MESSAGESTATUS, FINGERUP, FINGERDOWN, ROBOTFLOWSTYLE, VOICEREAD, VIDEOSTATUS, EVALUATEID, EVALUATESTATUS, EVALUATETIMESTAMP, EVALUATETIMEOUT, COMMONQUESTIONSGROUP, COMMONSELECTEDINDEX, ROBOTFLOWSELECT, ROBOTFLOWSEND, XBOTFORM, XBOTFIRST, COMMONQUESTIONSIMG];
    
    [[self dbQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL result = [db executeUpdate:sql];
        
        NSLog(result?@"创建成功":@"创建失败");
    }];
}

# pragma mark -- 插入消息
- (NSDictionary *)insertMessage:(CustomMessage *)message {
    
    NSString *sql = [NSString stringWithFormat:@"insert into CustomMessageTable (%@, %@, %@, %@, %@,  %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", _ID, ACCOUNT, DEVICEINFO, FROM, MESSAGE, CONTENTTYPE, PLATFORM, SESSIONID, TONOTIFY, WHEN, TYPE, CHATTYPE, HIDETIME, ISSUCCESS, VOICESECOND, REMOTEFILEPATH, LOCALFILEPATH, FILESIZE, FILENAME, DOWNLOADSTATE, WIDTH, HEIGHT, AGENTEXTEN, AGENTNAME, AGENTICON, AUDIOTEXT, ISROBOT, ISREAD, ISUSEFUL, QUESTIONID, RICHTEXTURL, RICHTEXTPICURL, RICHTEXTTITLE, RICHTEXTDESCRIPTION, ROBOTTYPE, ROBOTID, MP3FILESIZE, ACCESSID, CARDIMAGE, CARDHEADER, CARDSUBHEAD, CARDPRICE, CARDURL, USERID, ROBOTMSGID, CONFIDENCE, ORI_QUESTION, STD_QUESTION, ROBOTSESSIONID, ROBOTFLOWLIST, ROBOTFLOWTIP, ROBOTFLOWTYPE, CARDINFO_NEW, CARDMESSAGE_NEW, QMCardMessageReadStats, USERTYPE, MESSAGESTATUS, FINGERUP, FINGERDOWN, ROBOTFLOWSTYLE, VOICEREAD, VIDEOSTATUS, EVALUATEID, EVALUATESTATUS, EVALUATETIMESTAMP, EVALUATETIMEOUT, COMMONQUESTIONSGROUP, COMMONSELECTEDINDEX, ROBOTFLOWSELECT, ROBOTFLOWSEND, XBOTFORM, XBOTFIRST, COMMONQUESTIONSIMG];

    __block NSDictionary *dict = [NSDictionary dictionary];
    
    NSArray *messageArr = [self queryOneMessageWithID:message._id];
    if (messageArr.count > 0) {
        return dict;
    }

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql, message._id, message.account, message.device, @"", message.message, message.messageType, message.platform, message.sessionId, @"", message.createdTime, @"", message.fromType, @"", message.status, message.recordSeconds, message.remoteFilePath, message.localFilePath, message.fileSize, message.fileName, message.downloadState, message.width, message.height, message.agentExten, message.agentName, message.agentIcon, @"", message.isRobot, message.isRead, message.isUseful, message.questionId, message.richTextUrl, message.richTextPicUrl, message.richTextTitle, message.richTextDescription, message.robotType, message.robotId, message.mp3FileSize, message.accessid, message.cardImage, message.cardHeader, message.cardSubhead, message.cardPrice, message.cardUrl, message.userId, message.robotMsgId, message.confidence, message.ori_question, message.std_question, message.robotSessionId, message.robotFlowList, message.robotFlowTip, message.robotFlowType, message.cardInfo_New, message.cardMessage_New,message.cardType, message.userType, message.messageStatus, message.fingerUp, message.fingerDown, message.robotFlowsStyle, message.voiceRead, message.videoStatus, message.evaluateId, message.evaluateStatus, message.evaluateTimestamp, message.evaluateTimeout, message.common_questions_group, message.common_selected_index, message.robotFlowSelect, message.robotFlowSend, message.xbotForm, message.xbotFirst, message.common_questions_img];
//        NSLog(result?@"插入数据成功,当前线程%@":@"插入数据失败,当前线程%@",[NSThread currentThread] );
        
        dict = @{
                 @"messageId": message._id,
                 @"success": [NSString stringWithFormat:@"%d", result],
                 @"errMessage": [db lastErrorMessage]
                 };
//        NSLog(@"错误信息%@, 当前线程%@", [db lastErrorMessage], [NSThread currentThread]);
    }];

    return dict;
}

# pragma mark -- 根据sessionID查询库中所有消息
- (NSArray *)queryMessageWithSessionID:(int)index {
    
    NSArray *array = [self getMessageWithSessionID:index];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        CustomMessage *message = [[CustomMessage alloc] init];
        message = [self getMsg:dict mssg:message];
        [items addObject:message];
    }
    return items;
}

- (NSArray *)getMessageWithSessionID:(int)index {
    
    NSMutableArray *array = [NSMutableArray array];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID]) {
        return array;
    }
    
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_SESSION_ID];
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ? order by %@ desc limit %d", SESSIONID, WHEN, index];

    __block NSString *monitor = [NSString stringWithFormat:@"Num=%d", index];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[sessionId]];

        while ([set next]) {
            [array addObject:set.resultDictionary];
        }

        monitor = [monitor stringByAppendingString:[NSString stringWithFormat:@"Err=%@Res=%lu", [db lastErrorMessage], (unsigned long)array.count]];
        [set close];
    }];
       
    [QMGlobaMacro shared].monitorContext = monitor;
    
    return array;
}

# pragma mark -- 根据accessid查询库中所有消息
- (NSArray *)queryMessageWithAccessId:(int)index {
    
    NSArray *array = [self getMessageWithAccessId:index];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        CustomMessage *message = [[CustomMessage alloc] init];
        message = [self getMsg:dict mssg:message];
        [items addObject:message];
    }
    return items;
}

- (NSArray *)getMessageWithAccessId:(int)index {
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ? order by %@ desc limit %d", ACCESSID, WHEN, index];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:[NSArray arrayWithObject: [QMGlobaMacro shared].custom_accessId]];

        while ([set next]) {
            [array addObject:set.resultDictionary];
        }
        [set close];
    }];
    return array;
}

# pragma mark -- 根据userId查询库中所有消息
- (NSArray *)queryMessageWithUserId:(int)index {
    return [self queryMessageWithSessionID:index];
}

# pragma mark -- 根据消息ID查询一条消息
- (NSArray *)queryOneMessageWithID:(NSString *)messageId {
    
    NSArray *array = [self getNewMessageWithID:messageId];
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        CustomMessage *message = [[CustomMessage alloc] init];
        message = [self getMsg:dict mssg:message];
        [items addObject:message];
    }
    return items;
}

- (NSArray *)getNewMessageWithID:(NSString *)messageId  {
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ?", _ID];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[messageId]];

        while ([set next]) {
            [array addObject:set.resultDictionary];
        }
        [set close];
    }];
    return array;
}

# pragma mark -- 查询MP3文件大小
- (NSString *)queryMp3FileMessageSize:(NSString *)messageId {
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ?", _ID];

    __block NSString *string = @"0";
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[messageId]];
        
        while ([set next]) {
            CustomMessage *message = [[CustomMessage alloc] init];
            message = [self getMsg:set.resultDictionary mssg:message];
            string = message.mp3FileSize;
        }
    }];
    return string;
}

# pragma mark -- 根据消息ID删除一条消息
- (void)deleteMessageWithID:(NSString *)messageID {
    
    NSString *sql = [NSString stringWithFormat:@"delete from 'CustomMessageTable' where %@ = ?", _ID];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[messageID]];

//        NSLog(result?@"ID删除成功":@"ID删除失败");
    }];
}

# pragma mark -- 删除card类型消息
- (void)deleteMessageWithCardType:(NSString *)type {
    NSString *sql = [NSString stringWithFormat:@"delete from CustomMessageTable where %@ = ?", CONTENTTYPE];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[type]];

//        NSLog(result?@"删除card成功":@"删除card失败");
    }];
}

- (void)deleteMessageWithCardType {
    NSString *sql = [NSString stringWithFormat:@"delete from CustomMessageTable where %@ = ?", CONTENTTYPE];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[@"card"]];
    }];
}

# pragma mark -- 修改card类型消息时间
- (void)changeMessageCardTime:(NSString *)time {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", WHEN, CONTENTTYPE];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, time, @"card"];

//        NSLog(result?@"时间更新成功":@"时间更新失败");
    }];
}

# pragma mark -- 修改消息发送状态 updateDataWithType
- (void)changeMessageType: (CustomMessage *)message isSuccess:(NSString *)isSuccess {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ISSUCCESS, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
       
        BOOL result = [db executeUpdate:sql, isSuccess, message._id];

//        NSLog(result?@"状态更新成功":@"状态更新失败");
    }];
}

# pragma mark -- 修改消息内容
- (void)changeMessage: (CustomMessage *)message content:(NSString *)content {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", MESSAGE, _ID];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
    
        BOOL result = [db executeUpdate:sql, content, message._id];
        
//        NSLog(result?@"内容更新成功":@"内容更新失败");
    }];
}

# pragma mark -- 首次登陆修复发送中的消息状态
- (void)changeMessageStatus {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ISSUCCESS, ISSUCCESS];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", @"2"];

//        NSLog(result?@"状态更新成功":@"状态更新失败");
    }];
}

# pragma mark -- 修改消息发送时间
- (void)changeMessage: (CustomMessage *)message time:(NSString *)time {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", WHEN, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, time, message._id];

//        NSLog(result?@"时间更新成功":@"时间更新失败");
    }];
}

# pragma mark -- 修改文件下载状态
- (void)changeMessageDownloadState: (CustomMessage *)message {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", DOWNLOADSTATE, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, message.downloadState, message._id];

//        NSLog(result?@"下载更新成功":@"下载更新失败");
    }];
}

# pragma mark -- 首次登陆修复下载中的状态
- (void)changeMessageDownloadState {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", DOWNLOADSTATE, DOWNLOADSTATE];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", @"2"];

//        NSLog(result?@"下载更新成功":@"下载更新失败");
    }];
}

# pragma mark -- 修改本地文件路径
- (void)changeMessageLocalPath: (CustomMessage *)message {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", LOCALFILEPATH, _ID];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, message.localFilePath, message._id];

//        NSLog(result?@"路径更新成功":@"路经更新失败");
    }];
}

# pragma mark -- 修改远程文件路径
- (void)changeMessageRemotePath: (CustomMessage *)message {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", REMOTEFILEPATH, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, message.remoteFilePath, message._id];
        
//        NSLog(result?@"路径更新成功":@"路径更新失败");
    }];
}

# pragma mark -- 修改语音消息读取状态
- (void)changeMessageAudioStatus: (NSString *)messageId {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", VOICEREAD, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", messageId];

//        NSLog(result?@"语音更新成功":@"语音更新失败");
    }];
}
//- (void)changeMessageAudioStatus: (NSString *)messageId {
//
//    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ISREAD, _ID];
//
//    [[self dbQueue] inDatabase:^(FMDatabase *db) {
//
//        BOOL result = [db executeUpdate:sql, @"1", messageId];
//
////        NSLog(result?@"语音更新成功":@"语音更新失败");
//    }];
//}

# pragma mark -- 修改机器人问题状态？
- (void)changeRobotQuestionStatus: (NSString *)messageId status:(NSString *)status {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ISUSEFUL, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, status, messageId];

//        NSLog(result?@"问题更新成功":@"问题更新失败");
    }];
}

# pragma mark -- 撤回消息？
- (void)changeMessageStatus: (NSString *)messageId {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ?, %@ = ? WHERE %@ = ?", CONTENTTYPE, MESSAGE, _ID];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        NSString *string = [QMGlobaMacro shared].WithdrawMessage.length > 0 ? [QMGlobaMacro shared].WithdrawMessage : @"对方撤回一条消息";
        BOOL result = [db executeUpdate:sql, @"withdrawMessage", string, messageId];
//        BOOL result = [db executeUpdate:sql, @"withdrawMessage", @"对方撤回一条消息", messageId];

//        NSLog(result?@"撤回成功":@"撤回失败");
    }];
}

# pragma mark -- MP3文件的大小
- (void)changeMp3FileMessageSize: (NSString *)messageId fileSize:(NSString *)fileSize {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", MP3FILESIZE, _ID];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, fileSize, messageId];

//        NSLog(result?@"MP3更新成功":@"MP3更新失败");
    }];
}

# pragma mark -- 语音转文本的文字
- (BOOL)updateVoiceMessageToText:(NSString *)text withMessageId:(NSString *)messageId {
    
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", FILENAME, _ID];
    
    __block BOOL isTrue = false;

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, text, messageId];
        
        isTrue = result;
        
//        NSLog(result?@"语音转文本文字更新成功":@"语音转文本文字更新失败");

    }];
    
    if (isTrue) {
        [self changeVoiceTextShowoOrNot:@"1" messageId:messageId];
    }

    return isTrue;
}

# pragma mark -- 语音转文本消息是否展示
- (void)changeVoiceTextShowoOrNot:(NSString *)status messageId:(NSString *)messageId {
    
    if ([messageId isEqualToString:@"all"]) {
        NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", MESSAGESTATUS, CONTENTTYPE];
        
        [[self dbQueue] inDatabase:^(FMDatabase *db) {
            
            BOOL result = [db executeUpdate:sql, @"0", @"voice"];
            
//            NSLog(result?@"全部语音转文本消息是否展示成功":@"全部语音转文本消息是否展示失败");
        }];
    }else {
        NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", MESSAGESTATUS, _ID];
        
        [[self dbQueue] inDatabase:^(FMDatabase *db) {
            
            BOOL result = [db executeUpdate:sql, status, messageId];
            
//            NSLog(result?@"语音转文本消息是否展示成功":@"语音转文本消息是否展示失败");
        }];
    }
}

# pragma mark -- 查询语音消息是否展示
- (NSString *)queryVoiceTextStatusWithmessageId:(NSString *)messageId {
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ?", _ID];

    __block NSString *string = @"0";
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[messageId]];
        
        while ([set next]) {
            CustomMessage *message = [[CustomMessage alloc] init];
            message = [self getMsg:set.resultDictionary mssg:message];
            string = message.messageStatus;
        }
        [set close];
    }];

    return string;
}

//更新已读未读状态
- (BOOL)updateIsReadStatusWithSessionId:(NSString *)sessionId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ? and %@ = 0 and %@ = 0 and %@ = 0", ISREAD, SESSIONID, ISSUCCESS, ISREAD, CHATTYPE];
    
    __block BOOL isTrue = false;
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", sessionId];
        
        isTrue = result;
        
//        NSLog(result?@"已读未读状态更新成功":@"已读未读状态更新失败");
    }];
    
    return isTrue;
}

//获取坐席发送的消息的未读消息的_id
- (NSArray *)queryIsReadFromAgent {
    
    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ? and %@ = ? and %@ = 1 and %@ = 0", ACCESSID, USERID, CHATTYPE, ISREAD];
    
    NSMutableArray *messageArray = [NSMutableArray array];
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[[QMGlobaMacro shared].custom_accessId, [QMGlobaMacro shared].registUserId]];
        
        while ([set next]) {
            NSString * messageID = [set.resultDictionary valueForKey:_ID];
            [messageArray addObject:messageID];
        }
    }];
    return messageArray;
//    NSMutableArray *messageArray = [NSMutableArray array];
//
//    NSArray *array = [self queryUnreadMessage];
//
//    for (NSDictionary *dict in array) {
//        CustomMessage *message = [[CustomMessage alloc] init];
//        message = [self getMsg:dict mssg:message];
//        [messageArray addObject:message];
//    }
//
//    return messageArray;
}

//- (NSArray *)queryUnreadMessage {
//    
//    NSString *sql = [NSString stringWithFormat:@"select * from 'CustomMessageTable' where %@ = ? and %@ = ? and %@ = 1 and %@ = 0", ACCESSID, USERID, CHATTYPE, ISREAD];
//    
//    NSMutableArray *messageArray = [NSMutableArray array];
//    
//    [[self dbQueue] inDatabase:^(FMDatabase *db) {
//        
//        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:@[[QMGlobaMacro shared].custom_accessId, [QMGlobaMacro shared].registUserId]];
//        
//        while ([set next]) {
//            [messageArray addObject:set.resultDictionary];
//        }
//        [set close];
//    }];
//    return messageArray;
//}

//更新坐席未读消息状态
- (BOOL)updateAgentIsReadStatus {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ? and %@ = ? and %@ = 1", ISREAD, ACCESSID, USERID, CHATTYPE];
    __block BOOL isTrue = false;
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", [QMGlobaMacro shared].custom_accessId, [QMGlobaMacro shared].registUserId];
        
        isTrue = result;
        
//        NSLog(result?@"更新坐席未读消息状态成功":@"更新坐席未读消息状态失败");
    }];
    
    return isTrue;

}

//更新满意度评价状态--evaluateStatus
- (BOOL)updateEvaluateStatusWithEvaluateId:(NSString *)evaluateId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", EVALUATESTATUS, EVALUATEID];
    __block BOOL isTrue = false;
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, @"1", evaluateId];
        
        isTrue = result;
        
//        NSLog(result?@"更新满意度评价状态成功":@"更新满意度评价状态失败");
    }];
    
    return isTrue;
}

//修改commonProblemindex
- (BOOL)updateCommonProblemIndex:(NSString *)index withMessageID:(NSString *)messageId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", COMMONSELECTEDINDEX, _ID];
    __block BOOL isTrue = false;
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, index, messageId];
        
        isTrue = result;
        
//        NSLog(result?@"修改commonProblemindex状态成功":@"修改commonProblemindex状态失败");
    }];
    
    return isTrue;
}

//修改flowList
- (BOOL)updateRobotFlowList:(NSString *)flowList withMessageID:(NSString *)messageId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ROBOTFLOWLIST, _ID];
    __block BOOL isTrue = false;
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, flowList, messageId];
        
        isTrue = result;
        
//        NSLog(result?@"修改flowList状态成功":@"修改flowList状态失败");
    }];
    
    return isTrue;
}

//修改flowSend
- (BOOL)updateRobotFlowSend:(NSString *)flowSend withMessageID:(NSString *)messageId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", ROBOTFLOWSEND, _ID];
    __block BOOL isTrue = false;
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, flowSend, messageId];
        
        isTrue = result;
        
//        NSLog(result?@"修改flowSend状态成功":@"修改flowSend状态失败");
    }];
    
    return isTrue;
}

//修改XbotForm状态 -- 主要针对第一次弹出
- (BOOL)updateFormStatus:(NSString *)status withMessageID:(NSString *)messageId {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", XBOTFIRST, _ID];
    __block BOOL isTrue = false;
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql, status, messageId];
        
        isTrue = result;
        
//        NSLog(result?@"修改XbotForm状态成功":@"修改XbotForm状态失败");
    }];
    
    return isTrue;
}

//删除listCard
# pragma mark -- 删除card类型消息
- (void)deleteListCard {
    NSString *sql = [NSString stringWithFormat:@"delete from CustomMessageTable where %@ = ?", CONTENTTYPE];

    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:sql withArgumentsInArray:@[@"listCard"]];

//        NSLog(result?@"删除listCard成功":@"删除card失败");
    }];
}

- (void)changeCardMessageType:(QMMessageCardReadType)type messageId:(NSString *)messageId {
        NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = ?", QMCardMessageReadStats, _ID];
        [[self dbQueue] inDatabase:^(FMDatabase *db) {
            BOOL rel = [db executeUpdate:sql, @(type).description, messageId];
//            NSLog(@"rel = %@", rel ? @"修改成功" : @"修改失败");

        }];
}

- (void)changeAllCardMessageTypeHidden {
    NSString *sql = [NSString stringWithFormat:@"update CustomMessageTable set %@ = ? where %@ = '%@'", QMCardMessageReadStats, CONTENTTYPE, @"msgTask"];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        BOOL rel = [db executeUpdate:sql, @(QMMessageCardTypeHidden).description];
        
//        NSLog(@"rel = %@", rel ? @"修改成功" : @"修改失败");
    }];
}

- (CustomMessage *)getMsg:(NSDictionary *)rs mssg:(CustomMessage *)mssg {
    
    mssg._id = [self valueFromDict:rs key:_ID];
    
    mssg.device = [self valueFromDict:rs key:DEVICEINFO];
    
    mssg.message = [self valueFromDict:rs key:MESSAGE];
    
    if ([mssg.message containsString:@"<img"]) {
        mssg.attrAttachmentReplaced = 1;
    } else {
        mssg.attrAttachmentReplaced = 0;
    }
    
    NSString *messageType = [self valueFromDict:rs key:CONTENTTYPE];
    if (messageType) {
        mssg.messageType = messageType;
    }else {
        mssg.messageType = @"text";
    }
    
    mssg.platform = [self valueFromDict:rs key:PLATFORM];
    
    mssg.createdTime = [self valueFromDict:rs key:WHEN];
    
    mssg.fromType = [self valueFromDict:rs key:CHATTYPE];
    
    mssg.status = [self valueFromDict:rs key:ISSUCCESS];
    
    // 查询id
    mssg.sessionId = [self valueFromDict:rs key:SESSIONID];
    
    mssg.userId = [self valueFromDict:rs key:USERID];
    
    mssg.accessid = [self valueFromDict:rs key:ACCESSID];
    
    // 语音
    mssg.recordSeconds = [self valueFromDict:rs key:VOICESECOND];
    
    // 文件
    mssg.fileName = [self valueFromDict:rs key:FILENAME];
    
    mssg.fileSize = [self valueFromDict:rs key:FILESIZE];
    
    mssg.localFilePath = [self valueFromDict:rs key:LOCALFILEPATH];
    
    mssg.remoteFilePath = [self valueFromDict:rs key:REMOTEFILEPATH];
    
    mssg.downloadState = [self valueFromDict:rs key:DOWNLOADSTATE];
    
    mssg.mp3FileSize = [self valueFromDict:rs key:MP3FILESIZE];
    
    // 网页
    mssg.width = [self valueFromDict:rs key:WIDTH];
    
    mssg.height = [self valueFromDict:rs key:HEIGHT];
    
    // 坐席
    mssg.agentExten = [self valueFromDict:rs key:AGENTEXTEN];
    
    mssg.agentName = [self valueFromDict:rs key:AGENTNAME];
    
    mssg.agentIcon = [self valueFromDict:rs key:AGENTICON];
    
    // 状态
    mssg.isRobot = [self valueFromDict:rs key:ISROBOT];
    
    mssg.isRead = [self valueFromDict:rs key:ISREAD];
    
    mssg.isUseful = [self valueFromDict:rs key:ISUSEFUL];
    
    // 机器人问题id
    mssg.questionId = [self valueFromDict:rs key:QUESTIONID];
    
    mssg.account = [self valueFromDict:rs key:ACCOUNT];
    
    mssg.richTextUrl = [self valueFromDict:rs key:RICHTEXTURL];
    
    mssg.richTextPicUrl = [self valueFromDict:rs key:RICHTEXTPICURL];
    
    mssg.richTextTitle = [self valueFromDict:rs key:RICHTEXTTITLE];
    
    mssg.richTextDescription = [self valueFromDict:rs key:RICHTEXTDESCRIPTION];
    
    mssg.robotId = [self valueFromDict:rs key:ROBOTID];

    mssg.robotType = [self valueFromDict:rs key:ROBOTTYPE];
    
    mssg.robotMsgId = [self valueFromDict:rs key:ROBOTMSGID];
    
    mssg.confidence = [self valueFromDict:rs key:CONFIDENCE];
    
    mssg.ori_question = [self valueFromDict:rs key:ORI_QUESTION];
    
    mssg.std_question = [self valueFromDict:rs key:STD_QUESTION];
    
    mssg.robotSessionId = [self valueFromDict:rs key:ROBOTSESSIONID];
    
    mssg.robotFlowList = [self valueFromDict:rs key:ROBOTFLOWLIST];
    
    mssg.robotFlowTip = [self valueFromDict:rs key:ROBOTFLOWTIP];
    
    mssg.robotFlowType = [self valueFromDict:rs key:ROBOTFLOWTYPE];
    
    mssg.cardImage = [self valueFromDict:rs key:CARDIMAGE];
    
    mssg.cardHeader = [self valueFromDict:rs key:CARDHEADER];
    
    mssg.cardSubhead = [self valueFromDict:rs key:CARDSUBHEAD];
    
    mssg.cardPrice = [self valueFromDict:rs key:CARDPRICE];
    
    mssg.cardUrl = [self valueFromDict:rs key:CARDURL];
    
    mssg.cardInfo_New = [self valueFromDict:rs key:CARDINFO_NEW];
    
    mssg.cardMessage_New = [self valueFromDict:rs key:CARDMESSAGE_NEW];
    if (mssg.cardMessage_New.length > 0) {
        NSData *jsonData = [mssg.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        mssg.cardMsg_NewDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    }
    
    mssg.cardType = [[self valueFromDict:rs key:QMCardMessageReadStats] integerValue];

    mssg.userType = [self valueFromDict:rs key:USERTYPE];
    
    mssg.messageStatus = [self valueFromDict:rs key:MESSAGESTATUS];
    
    mssg.fingerUp = [self valueFromDict:rs key:FINGERUP];
    
    mssg.fingerDown = [self valueFromDict:rs key:FINGERDOWN];
    
    mssg.robotFlowsStyle = [self valueFromDict:rs key:ROBOTFLOWSTYLE];

    mssg.voiceRead = [self valueFromDict:rs key:VOICEREAD];
    
    mssg.videoStatus = [self valueFromDict:rs key:VIDEOSTATUS];

    mssg.evaluateId = [self valueFromDict:rs key:EVALUATEID];
    
    mssg.evaluateStatus = [self valueFromDict:rs key:EVALUATESTATUS];
    
    mssg.evaluateTimestamp = [self valueFromDict:rs key:EVALUATETIMESTAMP];
    
    mssg.evaluateTimeout = [self valueFromDict:rs key:EVALUATETIMEOUT];
    
    mssg.common_questions_group = [self valueFromDict:rs key:COMMONQUESTIONSGROUP];
    
    mssg.common_selected_index = [self valueFromDict:rs key:COMMONSELECTEDINDEX];
    
    mssg.robotFlowSelect = [self valueFromDict:rs key:ROBOTFLOWSELECT];
    
    mssg.robotFlowSend = [self valueFromDict:rs key:ROBOTFLOWSEND];

    mssg.xbotForm = [self valueFromDict:rs key:XBOTFORM];
    
    mssg.xbotFirst = [self valueFromDict:rs key:XBOTFIRST];
    
    mssg.common_questions_img = [self valueFromDict:rs key:COMMONQUESTIONSIMG];
    
    if ([mssg.isRobot isEqualToString:@"1"] ||
        [mssg.isRobot isEqualToString:@"2"]) {
        
        mssg.contentAttr = [self handleTextToAttributedString:mssg.message andMessageId:mssg._id];
    }
    
    return mssg;
}

- (NSString *)valueFromDict:(NSDictionary *)dict key:(NSString *)key {
    id value = [dict valueForKey:key];
    if ([value isKindOfClass:NSNull.class]) {
        return @"";
    }
    return value;
}

- (NSAttributedString *)handleTextToAttributedString:(NSString *)text andMessageId:(NSString *)messageId {
    
    if (!text || text.length == 0) {
        return [NSAttributedString new];
    }
    
    if ([text hasPrefix:@"\n"]) {
        text = [text stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    }
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    text = [text stringByReplacingOccurrencesOfString:@"m7_action" withString:@"href"];
    text = [text stringByReplacingOccurrencesOfString:@"robotTransferAgent" withString:@"http://7moor_param=m7_action_robotTransferAgent"];
    
    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray *videoItems = [NSMutableArray array];
    
    NSArray *macthItems = [regularExpretion matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)].reverseObjectEnumerator.allObjects;
    
    NSString *videoTip = @"<7moor_video_html>";
    
    for (int i = 0; i < macthItems.count; i++) {
        NSTextCheckingResult *result = macthItems[i];
        NSString *actionString = [NSString stringWithFormat:@"%@",[text substringWithRange:result.range]];

        CustomMessage *item = [[CustomMessage alloc] init];

        NSArray *components = nil;
        if ([actionString rangeOfString:@"<video controls src=\""].location != NSNotFound) {
            components = [actionString componentsSeparatedByString:@"src=\""];
            item.type = @"video";
        } else if ([actionString rangeOfString:@"<video controls src="].location != NSNotFound) {
            components = [actionString componentsSeparatedByString:@"src="];
            item.type = @"video";
        } else if ([actionString rangeOfString:@"<img"].location != NSNotFound) {
            components = [actionString componentsSeparatedByString:@"src="];
            item.type = @"image";
        }
        
        if (components.count == 0) {
            continue;
        }
        
        NSString *tip_titel = [videoTip stringByAppendingFormat:@"%@-moor_Video+", @(i).description];
        
        item.title = tip_titel;
        text = [text stringByReplacingCharactersInRange:result.range withString:tip_titel];
        if (components.count > 1) {
            NSString *url = components[1];
            if ([url hasPrefix:@"\'"]) {
                url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            if ([url hasPrefix:@"\""]) {
                url = [url stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            url = [url componentsSeparatedByString:@"\""].firstObject;
            item.url = url;
            
            NSString *path = [QMGlobaMacro pathOfDocument];
            path = [path stringByAppendingPathComponent:url.lastPathComponent];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path] == false) {
                [QMConnect downloadFileWithUrl:url successBlock:^{
                    if (messageId) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"qm_downImageCompleted" object:messageId];
                    }
                } failBlock:^(NSString * err) {
                    
                }];
            }
            
        }
        [videoItems addObject:item];
        
    }
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
   

    for (CustomMessage *item in videoItems) {
        QMChatFileTextAttachment *attach = [[QMChatFileTextAttachment alloc] init];
        if ([item.type isEqualToString:@"video"]) {
            AVURLAsset *urlSet= [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:item.url] options:nil];
            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlSet];
            gen.appliesPreferredTrackTransform = true;
            CMTime time = CMTimeMakeWithSeconds(1.0, 1);
            CMTime actualTime;
            
            CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:nil];
            if (image) {
                UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                UIImage *playImage = [UIImage imageNamed:QMUIKitResource(@"chat_video_player")];
                if (playImage) {
                    
                    CGSize atSize = CGSizeMake(200, 150);
                    atSize.height = atSize.width * thumb.size.height / thumb.size.width;
                    CGPoint point = CGPointMake(atSize.width/2.0 - playImage.size.width/2.0, atSize.height/2.0 - playImage.size.height/2.0);
                    attach.bounds = CGRectMake(0, 0, atSize.width, atSize.height);
                    
//                    thumb = [UIImage qm_getNewImageWithOriginalImage:thumb waterImage:playImage];
                }
                
                attach.image = thumb;
            } else {
                attach.bounds = CGRectMake(0, 0, 200, 150);
                attach.image = [UIImage imageNamed:QMUIKitResource(@"qm_Chat_Video")];
            }
            attach.url = item.url;
            
            NSRange rang = [attr.string rangeOfString:item.title];
            if (rang.location != NSNotFound) {
                NSAttributedString *at = [NSAttributedString attributedStringWithAttachment:attach];
                [attr replaceCharactersInRange:rang withAttributedString:at];
            }
        } else {
            attach.bounds = CGRectMake(0, 0, 200, 150);
            attach.url = item.url;
            attach.need_replaceImage = YES;
            attach.type = item.type;
            NSString *path = [QMGlobaMacro pathOfDocument];
            path = [path stringByAppendingPathComponent:item.url.lastPathComponent];

            if ([[NSFileManager defaultManager] fileExistsAtPath:path] == true) {
                NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
                if (data.length > 0) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    attach.image = image;
                    attach.need_replaceImage = NO;
                } else {
                    attach.image = [UIImage imageNamed:QMUIKitResource(@"chat_card_placeholder")];
                }
            } else {
                attach.image = [UIImage imageNamed:QMUIKitResource(@"chat_card_placeholder")];
            }
            NSRange rang = [attr.string rangeOfString:item.title];
            if (rang.location != NSNotFound) {
                NSAttributedString *at = [NSAttributedString attributedStringWithAttachment:attach];
                NSMutableAttributedString *subAttr = [NSMutableAttributedString new];
                NSAttributedString *nextAttr = [[NSAttributedString alloc] initWithString:@"\n"];
                [subAttr appendAttributedString:nextAttr];
                [subAttr appendAttributedString:at];
                [subAttr appendAttributedString:nextAttr];
                [attr replaceCharactersInRange:rang withAttributedString:subAttr];
            }

        }
    }
    
    [attr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:NSTextAttachment.class]) {
            NSTextAttachment *nvalue = (NSTextAttachment *)value;
            CGRect bound = nvalue.bounds;
            CGFloat widht = 240;
            CGFloat att_height = 2400;
            if (widht < bound.size.width) {
                CGFloat height = widht*bound.size.height/bound.size.width;
                bound.size.width = widht;
                bound.size.height = att_height > height ? height : att_height;
                nvalue.bounds = bound;
            }

        }
    }];
    
    [attr enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:UIFont.class]) {
            UIFont *font = (UIFont *)value;
            if (font) {
//                font = [UIFont fontWithDescriptor:font.fontDescriptor size:font.pointSize + 4];
                font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
            } else {
                font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
            }
            [attr addAttributes:@{NSFontAttributeName: font} range:range];
        }
    }];
    
    //type 1 文本 2 http 3 电话
    attr = [self handleAttributedWithAttri:attr type:@"1"];
    
    attr = [self handleAttributedWithAttri:attr type:@"2"];
    
    attr = [self handleAttributedWithAttri:attr type:@"3"];
    
    if ([attr.string hasSuffix:@"\n"]) {
        [attr replaceCharactersInRange:NSMakeRange(attr.length - 1, 1) withString:@""];
    }
    
    NSMutableParagraphStyle *parag = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    parag.lineSpacing = 4;
    parag.paragraphSpacingBefore = 2;
    [attr addAttributes:@{NSParagraphStyleAttributeName: parag} range:NSMakeRange(0, attr.length)];
    
    return attr;
    
}

- (NSMutableAttributedString *)handleAttributedWithAttri:(NSMutableAttributedString *)attrString type:(NSString *)type {
    
    if (attrString.string.length == 0) {
        return nil;
    }
    
    NSString * ragText = @"";
    if ([type isEqualToString:@"1"]) {
        ragText = @"[0-9]{1,2}：[^\\n]*\\n";
    }
    else if ([type isEqualToString:@"2"]){
        ragText =  @"((http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w-\\.,@?^=%&:/~\\+#]*[\\w-\\@?^=%&/~\\+#])?)";
    }
    else {
        ragText = @"(1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])[0-9]{8})|([0][1-9]{2,3}-[0-9]{5,10})";
    }

    NSRegularExpression *ragx = [[NSRegularExpression alloc] initWithPattern:ragText options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSArray *arrs = [ragx matchesInString:attrString.string options:NSMatchingReportProgress range:NSMakeRange(0, attrString.string.length)];
    
    for (NSTextCheckingResult *result in arrs) {
        if (result.range.location != NSNotFound) {
            NSString *str = [attrString attributedSubstringFromRange:result.range].string;
            str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [attrString addAttributes:@{NSLinkAttributeName:[NSURL URLWithString:str]} range:result.range];
            
            if ([type isEqualToString:@"3"]) {
                NSString *phone = [attrString attributedSubstringFromRange:result.range].string;
                phone = [@"tel://" stringByAppendingString:phone];
                [attrString addAttributes:@{NSLinkAttributeName:phone} range:result.range];
            }
        }
    }
    
    return attrString;
}


@end
