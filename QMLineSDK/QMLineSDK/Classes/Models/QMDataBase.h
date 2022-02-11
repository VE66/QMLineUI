//
//  QMDataBase.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMessage.h"
@class FMDatabase;

@interface QMDataBase : NSObject

@property (nonatomic, strong)FMDatabase *db;

@property (nonatomic, copy)NSString *filePath;

/**
 获取单例
 
 @return 单例对象
 */
+ (instancetype)shared;

/**
 验证表是否存在
 */
- (BOOL)isExistTable;

/**
 获取列名

 @return 列名数组
 */
- (NSArray *)getAllColumns;

/**
 创建数据库
 */
//- (void)createDataBase;

/**
 创建表
 */
- (void)createTable;

/**
 数据库插入消息记录

 @param message 消息对象
 */
- (NSDictionary *)insertMessage:(CustomMessage *)message;

/**
 根据会话id查询消息

 @param index 查询条数
 @return 返回消息数组
 */
- (NSArray *)queryMessageWithSessionID:(int)index;

/**
 根据渠道id查询消息

 @param index 查询条数
 @return 返回消息数组
 */
- (NSArray *)queryMessageWithAccessId:(int)index;

/**
 根据用户id查询消息

 @param index 查询条数
 @return 返回消息数组
 */
- (NSArray *)queryMessageWithUserId:(int)index;

/**
 查询单条消息

 @param messageId 消息id
 @return 返回消息对象
 */
- (NSArray *)queryOneMessageWithID:(NSString *)messageId;

/**
 查询MP3文件大小

 @param messageId 消息id
 @return 返回大小
 */
- (NSString *)queryMp3FileMessageSize:(NSString *)messageId;

/**
 删除一条消息

 @param messageID 消息id
 */
- (void)deleteMessageWithID:(NSString *)messageID;

/**
 删除所有卡片类型的消息
 */
- (void)deleteMessageWithCardType:(NSString *)type;

/**
 更新卡片消息时间

 @param time 时间字符串
 */
- (void)changeMessageCardTime:(NSString *)time;

/**
 更新消息状态

 @param message 消息对象
 @param isSuccess 消息状态
 */
- (void)changeMessageType:(CustomMessage *)message isSuccess:(NSString *)isSuccess;

/**
 更新消息内容

 @param message 消息对象
 @param content 消息内容
 */
- (void)changeMessage:(CustomMessage *)message content:(NSString *)content;

/**
 首次登陆修复消息状态
 */
- (void)changeMessageStatus;

/**
 更新消息发送时间

 @param message 消息对象
 @param time 时间字符串
 */
- (void)changeMessage:(CustomMessage *)message time:(NSString *)time;

/**
 更新文件消息下载状态

 @param message 消息对象
 */
- (void)changeMessageDownloadState: (CustomMessage *)message;

/**
 首次登陆修复消息状态
 */
- (void)changeMessageDownloadState;

/**
 更新本地文件路径

 @param message 消息对象
 */
- (void)changeMessageLocalPath: (CustomMessage *)message;

/**
 更新远程文件路径

 @param message 消息对象
 */
- (void)changeMessageRemotePath: (CustomMessage *)message;

/**
 更新消息已读状态

 @param messageId 消息id
 */
- (void)changeMessageAudioStatus: (NSString *)messageId;

/**
 更新机器人问题状态

 @param messageId 消息id
 @param status 问题状态
 */
- (void)changeRobotQuestionStatus: (NSString *)messageId status:(NSString *)status;

/**
 撤回消息

 @param messageId 消息id
 */
- (void)changeMessageStatus: (NSString *)messageId;

/**
 更新mp3文件大小

 @param messageId 消息id
 @param fileSize 文件大小
 */
- (void)changeMp3FileMessageSize: (NSString *)messageId fileSize:(NSString *)fileSize;


/**
 删除所有卡片类型的消息
 */
- (void)deleteMessageWithCardType;


/**
 更新Card消息已读状态

 @param messageId 消息id
 */
- (void)changeCardMessageType:(QMMessageCardReadType)type messageId:(NSString *)messageId;
- (void)changeAllCardMessageTypeHidden;

/**
更新语音转文本的文字

@param text 文字
@param messageId 消息id
*/
- (BOOL)updateVoiceMessageToText:(NSString *)text withMessageId:(NSString *)messageId;

/**
更新语音转文本的展示状态

@param status 是否展示 0不展示  1展示
@param messageId 消息id
*/
- (void)changeVoiceTextShowoOrNot:(NSString *)status messageId:(NSString *)messageId;

/**
查询语音转文字是否显示

@param messageId 消息id
*/
- (NSString *)queryVoiceTextStatusWithmessageId:(NSString *)messageId;

/**
查询语音转文字是否显示
*/
- (BOOL)updateIsReadStatusWithSessionId:(NSString *)sessionId;

/**
 查询坐席的未读消息
 */
- (NSArray *)queryIsReadFromAgent;

/**
 更新坐席未读消息状态
 */
- (BOOL)updateAgentIsReadStatus;

//更新满意度评价状态--evaluateStatus
- (BOOL)updateEvaluateStatusWithEvaluateId:(NSString *)evaluateId;

//修改commonProblemindex
- (BOOL)updateCommonProblemIndex:(NSString *)index withMessageID:(NSString *)messageId;

//修改flowList
- (BOOL)updateRobotFlowList:(NSString *)flowList withMessageID:(NSString *)messageId;

//修改flowSend
- (BOOL)updateRobotFlowSend:(NSString *)flowSend withMessageID:(NSString *)messageId;

//修改XbotForm状态 -- 主要针对第一次弹出
- (BOOL)updateFormStatus:(NSString *)status withMessageID:(NSString *)messageId;

- (void)deleteListCard;

@end
