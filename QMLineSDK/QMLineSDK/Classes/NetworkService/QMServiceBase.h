//
//  QMServiceBase.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/11/1.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QMServiceBase : NSObject

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) NSMutableDictionary *dic;

/**
 获取单例
 
 @return 单例对象
 */
+ (instancetype)sharedInstance;

#pragma mark - Function

/**
 开始会话(技能组)

 @param peerId 技能组id
 @param params 扩展信息
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)newChatSession:(NSString *)peerId
                params:(NSDictionary *)params
               vipTrue:(BOOL)vipTrue
            completion:(void (^)(NSDictionary *))completion
               failure:(void (^)(void))failure;

/**
 开始会话(日程管理)

 @param scheduleId 1
 @param processId 1
 @param currentNodeId 1
 @param entranceId 1
 @param params 开始会话参数设置
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)newChatSession:(NSString *)scheduleId
             processId:(NSString *)processId
         currentNodeId:(NSString *)currentNodeId
            entranceId:(NSString *)entranceId
                params:(NSDictionary *)params
               vipTrue:(BOOL)vipTrue
            completion:(void (^)(NSDictionary *))completion
               failure:(void (^)(void))failure;

/**
 是否存在该会话
 
 @param sid sid
 @param account 账户
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getAleardyChatSession:(NSString *)sid
                      account:(NSString *)account
                   completion:(void (^)(NSDictionary *))completion
                      failure:(void (^)(void))failure;

/**
 获取全局配置

 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getWebchatGlobleConfig:(void (^)(NSDictionary *))completion
                       failure:(void (^)(void))failure;

/**
 获取所有技能组

 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getPeers:(void (^)(NSDictionary *))completion
         failure:(void (^)(void))failure;

/**
 获取所有评价

 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getInvestingations:(void (^)(NSDictionary *))completion
                   failure:(void (^)(void))failure;

/**
 获取未读消息数

 @param accessId 会话渠道id
 @param userName 用户名称
 @param userId 用户id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getUnreadMessageNumbers:(NSString *)accessId
                       userName:(NSString *)userName
                         userId:(NSString *)userId
                     completion:(void (^)(NSDictionary *))completion
                        failure:(void (^)(void))failure;

/**
 机器人转人工服务
 
 @param peerId 技能组id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)convertManualWithPeerId:(NSString *)peerId
                     completion:(void (^)(NSDictionary *))completion
                        failure:(void (^)(void))failure;

/**
 vip专属坐席不在线、转接到其他坐席

 @param peerId 技能组id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)vipAgentConvertOtherAgent:(NSString *)peerId
                       completion:(void (^)(NSDictionary *))completion
                          failure:(void (^)(void))failure;

/**
 提交满意度评价

 @param name 评价信息
 @param value 评价id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)submitInvestigation:(NSString *)name
                      value:(NSString *)value
                 completion:(void (^)(NSDictionary *))completion
                    failure:(void (^)(void))failure;

/**
 提交满意度评价 包含二级标题和备注的评价 3.2.0新增
 
 @param name 评价信息
 @param value 评价id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */

- (void)tryNewSubmitInvestigation:(NSString *)name
                            value:(NSString *)value
                       radioValue:(NSArray *)radioValue
                           remark:(NSString *)remark
                              way:(NSString *)way
                        operation:(NSString *)operation
                        sessionId:(NSString *)sessionId
                       completion:(void (^)(NSDictionary *))completion
                          failure:(void (^)(void))failure;

/**
 提交留言

 @param peerId 技能组id
 @param phone 电话号码
 @param email 邮箱
 @param content 留言内容
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)submitLeaveMessage:(NSString *)peerId
                     phone:(NSString *)phone
                     email:(NSString *)email
                   content:(NSString *)content
                completion:(void (^)(NSDictionary *))completion
                   failure:(void (^)(void))failure;

/**
 提交留言

 @param peerId 技能组id
 @param information 留言信息
 @param fields 留言自定义字段
 @param content 留言内容
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)submitLeaveMessage:(NSString *)peerId
               information:(NSDictionary *)information
                    fields:(NSArray *)fields
                   content:(NSString *)content
                completion:(void (^)(NSDictionary *))completion
                   failure:(void (^)(void))failure;

/**
 机器人帮助状态反馈、是否有帮助

 @param status 反馈结果 有帮助 or 无帮助
 @param questionId 机器人回复的问题id
 @param messageId 消息id
 @param robotType 机器人类型
 @param robotId 机器人id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)submitRobotFeedback:(NSString *)status
                 questionId:(NSString *)questionId
                  messageId:(NSString *)messageId
                  robotType:(NSString *)robotType
                    robotId:(NSString *)robotId
                 robotMsgId:(NSString *)robotMsgId
                 completion:(void (^)(NSDictionary *))completion
                    failure:(void (^)(void))failure;

/**
 智能机器人满意度评价
 @param robotId 机器人id
 @param satisfaction true&false
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)SubmitIntelligentRobotSatisfaction:(NSString *)robotId
                              satisfaction:(NSString *)satisfaction
                                completion:(void (^)(NSDictionary *))completion
                                   failure:(void (^)(void))failure;

/**
 xbot机器人帮助状态反馈、是否有帮助
 
 @param status 反馈结果 有帮助 or 无帮助
 @param messageId 消息id
 @param robotId 机器人id
 @param oriquestion 访客问题
 @param question 标准问题
 @param answer 答案
 @param confidence 置信度
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)submitXbotRobotFeedback:(NSString *)status
                      messageId:(NSString *)messageId
                        robotId:(NSString *)robotId
                    oriquestion:(NSString *)oriquestion
                       question:(NSString *)question
                         answer:(NSString *)answer
                     confidence:(NSString *)confidence
                      robotType:(NSString *)robotType
                 robotSessionId:(NSString *)robotSessionId
                     questionId:(NSString *)questionId  
                     completion:(void (^)(NSDictionary *))completion
                        failure:(void (^)(void))failure;

/**
 xbot机器人满意度评价
 @param satisfaction true&false
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)SubmitXbotRobotSatisfaction:(NSString *)satisfaction
                         completion:(void (^)(NSDictionary *))completion
                            failure:(void (^)(void))failure;

/**
 xbot联想功能
 @param text 联想文本
 @param cateIds xbot机器人cateIds
 @param robotId 机器人id
 @param robotType 机器人类型
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)SubmitXbotRobotAssociationInput:(NSString *)text
                                cateIds:(NSArray *)cateIds
                                robotId:(NSString *)robotId
                              robotType:(NSString *)robotType
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(void))failure;

/**
 是否已经满意度评价
 */
- (void)sdkGetImCsrInvestigate:(NSString *)chatId
                    completion:(void (^)(NSDictionary *))completion
                       failure:(void (^)(void))failure;

#pragma mark - Message

/**
 获取新消息

 @param ids 缓存的消息id
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getNewMessage:(NSArray *)ids
           completion:(void (^)(NSDictionary *))completion
              failure:(void (^)(void))failure;

/**
 发送消息

 @param type 消息类型
 @param params 消息数据
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)sendMessage:(NSString *)type
             params:(NSDictionary *)params
         completion:(void (^)(NSDictionary *))completion
            failure:(void (^)(NSString *))failure;

/**
 语音转文本
 */
- (void)getVoiceToText:(NSString *)messageId
             accountId:(NSString *)accountId
              filePath:(NSString *)filePath
                  when:(NSString *)when
            completion:(void (^)(NSDictionary *))completion
               failure:(void (^)(void))failure;


#pragma mark - Util

/**
 获取七牛token
 用于上传文件至七牛存储

 @param fileName 文件名称
 @param completion 请求成功回调
 @param failure 请求失败回调
 */
- (void)getQiniuToken:(NSString *)fileName
           completion:(void (^)(NSDictionary *))completion
              failure:(void (^)(void))failure;


#pragma mark - address

/**
 动态获取tcp的地址和端口

 @param main 使用地址1还是地址2
 @param accessId 在线客服渠道id
 @param userName 用户名
 @param userId 用户id
 @param completion 成功
 @param failure 失败
 */
- (void)getRequestAddress:(BOOL)main
                 accessId:(NSString *)accessId
                 userName:(NSString *)userName
                   userId:(NSString *)userId
               completion:(void (^)(NSString *))completion
                  failure:(void (^)(void))failure;


- (void)getRequestwebSocketAddress:(NSString *)accessId
                          userName:(NSString *)userName
                            userId:(NSString *)userId
                        completion:(void (^)(NSString *))completion
                           failure:(void (^)(void))failure;

@end
