//
//  QMServiceFunction.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMSessionOption.h"
#import "QMEvaluation.h"
#import "QMMessage.h"

@interface QMServiceFunction : NSObject

/**
 获取单例
 
 @return 单例对象
 */
+ (instancetype)sharedInstance;

/**
 开始会话(扩展信息使用字典)

 @param peerId 会话技能组id
 @param params 开始会话参数设置
 @param completion 开始会话成功回调
 @param failure 开始会话失败回调
 */
- (void)tryStartNewChatSession:(NSString *)peerId
                        params:(NSDictionary *)params
                       vipTrue:(BOOL)vipTrue
                    completion:(void (^)(BOOL, NSString *))completion
                       failure:(void (^)(void))failure;

/**
 开始会话(扩展信息使用自定义对象)

 @param peerId 会话技能组id
 @param option 开始会话配置
 @param completion 开始会话成功回调
 @param failure 开始会话失败回调
 */
- (void)tryStartNewChatSession:(NSString *)peerId
                        option:(QMSessionOption *)option
                    completion:(void (^)(BOOL, NSString *))completion
                       failure:(void (^)(void))failure;

/**
 开始会话(用于日程管理)

 @param scheduleId 1
 @param processId 1
 @param currentNodeId 1
 @param entranceId 1
 @param params 开始会话参数设置
 @param completion 开始会话成功回调
 @param failure 开始会话失败回调
 */
- (void)tryStartNewChatSession:(NSString *)scheduleId
                     processId:(NSString *)processId
                 currentNodeId:(NSString *)currentNodeId
                    entranceId:(NSString *)entranceId
                        params:(NSDictionary *)params
                       vipTrue:(BOOL)vipTrue
                    completion:(void (^)(BOOL, NSString *))completion
                       failure:(void (^)(void))failure;

/**
 是否存在该会话
 
 @param sid 会话id
 @param completion 存在会话
 @param failure 不存在会话
 */
- (void)tryGetAleardyChatSession:(NSString *)sid
                      completion:(void (^)(NSDictionary *))completion
                         failure:(void (^)(void))failure;

/**
 获取会话全局配置项  globalSet

 @param completion 获取会话全局设置成功回调
 @param failure 获取会话全局设置失败回调
 */
- (void)tryGetWebchatGlobleConfig:(void (^)(NSDictionary *))completion
                          failure:(void (^)(void))failure;

/**
 获取会话全局配置项  scheduleConfig
 
 @param completion 获取会话全局设置成功回调
 @param failure 获取会话全局设置失败回调
 */
- (void)tryGetWebchatScheduleConfig:(void (^)(NSDictionary *))completion
                          failure: (void (^)(void))failure;

/**
 解析会话全局配置

 @param key 会话配置字段名
 @return 返回配置值
 */
- (id)tryGetGlobalValue:(NSString *)key;

/**
 解析开始新会话配置
 
 @param key 会话配置字段名
 @return 返回配置值
 */
- (id)tryGetBeginSessionConfigValue:(NSString *)key;

/**
 解析开始新会话配置xbot配置问题
 
 @param type 技能组&日程
 @return 返回配置值
 */
- (id)tryGetBottomList:(NSString *)type;

/**
 获取所有会话技能组

 @param completion 获取会话技能组成功回调
 @param failure 获取会话技能组失败回调
 */
- (void)tryGetPeers:(void (^)(NSArray *))completion
            failure:(void (^)(void))failure;

/**
 机器人转人工服务

 @param peerId 技能组id
 @param completion 转人工服务成功回调
 @param failure 转人工服务失败回调
 */
- (void)tryConverManualWithPeerId:(NSString *)peerId
                       completion:(void (^)(void))completion
                          failure:(void (^)(void))failure;

/**
 VIP专属坐席在线验证

 @param peer 技能组id
 @param completion 成功回调
 @param failure 失败回调
 */
- (void)tryVipAgentOnline:(NSString *)peer
               completion:(void (^)(void))completion
                  failure:(void (^)(void))failure;

/**
 获取所有评价信息

 @param completion 获取评价信息成功回调
 @param failure 获取评价信息失败回调
 */
- (void)tryGetInvestingations:(void (^)(NSArray *))completion
                      failure:(void (^)(void))failure;

/**
 获取所有评价信息
 带自定义标题和感谢语的
 
 @param completion 获取评价信息成功回调
 @param failure 获取评价信息失败回调
 */

- (void)tryNewGetInvestingations: (void (^)(QMEvaluation *))completion
                         failure: (void (^)(void))failure;

/**
 获取未读消息数

 @param accessId 接入技能组的accessid
 @param userName 用户名称
 @param userId 用户id
 @param completion 获取未读消息数成功回调
 @param failure 获取未读消息数失败回调
 */
- (void)tryGetUnReadMessage:(NSString *)accessId
                   userName:(NSString *)userName
                     userId:(NSString *)userId
                 completion:(void (^)(NSInteger))completion
                    failure:(void (^)(void))failure;

/**
 提交满意评价

 @param name 评价的信息
 @param value 评价的id
 @param completion 评价成功回调
 @param failure 评价失败回调
 */
- (void)trySubmitInvestigation:(NSString *)name
                         value:(NSString *)value
                    completion:(void (^)(void))completion
                       failure:(void (^)(void))failure;

/**
 提交满意评价 包含二级标题和备注的评价 3.2.0新增
 
 @param name 评价的信息
 @param value 评价的id
 @param completion 评价成功回调
 @param failure 评价失败回调
 */
- (void)tryNewSubmitInvestigation:(NSString *)name
                            value:(NSString *)value
                       radioValue:(NSArray *)radioValue
                           remark:(NSString *)remark
                              way:(NSString *)way
                        operation:(NSString *)operation
                        sessionId:(NSString *)sessionId
                       completion:(void (^)(void))completion
                          failure:(void (^)(void))failure;

/**
 提交留言

 @param peer 会话技能组id
 @param phone 留言电话
 @param email 留言邮箱
 @param content 留言内容
 @param completion 提交留言成功回调
 @param failure 提交留言失败回调
 */
- (void)trySubmitLeaveContent:(NSString *)peer
                        phone:(NSString *)phone
                        email:(NSString *)email
                      content:(NSString *)content
                   completion:(void (^)(void))completion
                      failure:(void (^)(void))failure;

/**
 提交留言(自定义留言字段)

 @param peer 会话技能组id
 @param information 留言信息
 @param leavemsgFields 留言自定义字段内容
 @param content 留言内容
 @param completion 提交留言成功回调
 @param failure 提交留言失败回调
 */
- (void) trySubmitLeaveContent:(NSString *)peer
                   information:(NSDictionary *)information
                leavemsgFields:(NSArray *)leavemsgFields
                       content:(NSString *)content
                    completion:(void (^)(void))completion
                       failure:(void (^)(void))failure;

/**
 机器人帮助结果反馈

 @param status 反馈结果 有帮助/无帮助
 @param questionId 机器人回复的问题id
 @param messageId 消息id
 @param robotType 机器人类型
 @param robotId 机器人id
 @param completion 反馈成功回调
 @param failure 反馈失败回调
 */
- (void)trySubmitRobotFeedback:(NSString *)status
                    questionId:(NSString *)questionId
                     messageId:(NSString *)messageId
                     robotType:(NSString *)robotType
                       robotId:(NSString *)robotId
                    robotMsgId:(NSString *)robotMsgId
                    completion:(void (^)(void))completion
                       failure:(void (^)(void))failure;

/** 智能机器人满意度评价
 @param robotId 机器人id
 @param satisfaction true&false
 @param completion 成功
 @param failure 失败
*/
- (void)trySubmitIntelligentRobotSatisfaction:(NSString *)robotId
                                 satisfaction:(NSString *)satisfaction
                                   completion:(void (^)(void))completion
                                      failure:(void (^)(void))failure;

/**
 xbot机器人帮助结果反馈
 
 @param status 反馈结果 有帮助/无帮助
 @param message 消息体
 @param completion 反馈成功回调
 @param failure 反馈失败回调
 */
- (void)trySubmitXbotRobotFeedback:(NSString *)status
                           message:(CustomMessage *)message
                        completion:(void (^)(void))completion
                           failure:(void (^)(void))failure;

/** xbot机器人满意度评价
 @param satisfaction true&false
 @param completion 成功
 @param failure 失败
 */
- (void)trySubmitXbotRobotSatisfaction:(NSString *)satisfaction
                            completion:(void (^)(void))completion
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
- (void)trySubmitXbotRobotAssociationInput:(NSString *)text
                                   cateIds:(NSArray *)cateIds
                                   robotId:(NSString *)robotId
                                 robotType:(NSString *)robotType
                                completion:(void (^)(NSArray *))completion
                                   failure:(void (^)(void))failure;

/** 是否评价过满意度评价
 @param completion 成功
 @param failure 失败
 */
- (void)tryGetImCsrInvestigate:(void (^)(void))completion
                       failure:(void (^)(NSString *))failure;

/**
 定时关闭会话
 这个API 老客户在用 没办法更改了
 
 @param completion 反馈成功回调
 @param failure 反馈失败回调
 */
- (void)tryChatTimerBreaking:(void (^)(NSDictionary *))completion
                     failure:(void (^)(void))failure;

- (void)tryGetSdkServerTime:(void (^)(NSString *))completion
                    failure:(void (^)(void))failure;
- (void)trysdkCheckImCsrTimeoutParams:(NSDictionary *)params success:(void (^)(void))success failureBlock:(void (^)(void))failure;


/**
 获取常见问题
 */
- (void)trygetCommonQuestion:(void (^)(NSArray *))completion failure:(void(^)(NSString *))failure;
- (void)tryGetSubCommonQuestionWithcid:(NSString *)cid completion:(void (^)(NSArray *))completion failure:(void (^)(NSString *))failure;
- (void)tryGetCommonDataWithParams:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(NSError *))failure;

- (void)tryLoginoutAction:(void(^)(BOOL, NSString *))completion;

/**
消费未读消息
*/
- (void)tryDealImMsgWithMessageId:(NSArray *)messageId;

#pragma mark - 获取使用tcp还是webSocket
- (void)tryGetSDKConnectionEntranceWithAccessId:(NSString *)accessid
                                     completion:(void (^)(BOOL))completion
                                        failure:(void (^)(void))failure;

/**
 视频操作
 @param type  操作类型
 @param originator  操作角色
 @param completion 反馈成功回调
 @param failure 反馈失败回调
 */
- (void)tryHandleVideoOperation:(NSString *)type originator:(NSString *)originator completion:(void (^)(void))completion failure:(void (^)(void))failure;

- (void)tryClientAutoClose:(NSString *)chatId completion:(void (^)(void))completion failure:(void (^)(void))failure;
/**
 人工客服输入监听
 */
- (void)tryInputMonitor:(NSString *)chatContent completion:(void (^)(void))completion failure:(void (^)(void))failure;
//- (void)tryStartTimer;

@end
