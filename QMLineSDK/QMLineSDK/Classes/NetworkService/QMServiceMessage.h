//
//  QMServiceMessage.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QiniuSDK.h"

@class CustomMessage;
@class QMAgent;

@interface QMServiceMessage : NSObject

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, assign) BOOL isSave;
/**
 获取单例
 
 @return 单例对象
 */
+ (instancetype)sharedInstance;


/**
 获取新消息
 */
- (void)tryGetNewMessage:(void (^)(void))completion
                 failure:(void (^)(void))failure;

/**
 发送文本消息

 @param text 消息内容
 @param completion 发送文本消息成功回调
 @param failure 发送文本消息失败回调
 */
- (void)sendTextMessage:(NSString *)text
             completion:(void (^)(void))completion
                failure:(void (^)(NSString *))failure;

/**
 发送图片消息

 @param filePath 本地图片路径
 @param image 图片对象
 @param completion 发送图片消息成功回调
 @param failure 发送消息失败回调
 */
- (void)sendImageMessage:(NSString *)filePath
                   image:(UIImage *)image
              completion:(void (^)(void))completion
                 failure:(void (^)(NSString *))failure;

/**
 发送语音消息

 @param filePath 本地语音路径
 @param data 语音数据
 @param duration 语音时长
 @param completion 发送语音消息成功回调
 @param failure 发送语音消息失败回调
 */
- (void)sendAudioMessage:(NSString *)filePath
                    data:(NSData *)data
                duration:(NSString *)duration
              completion:(void (^)(void))completion
                 failure:(void (^)(NSString *))failure;

/**
 语音转文本
 @param filePath 本地语音路径
 @param messageId 消息id
 @param when 发送时间
 */
- (void)sendAudioToText:(NSString *)messageId
               filePath:(NSString *)filePath
                   when:(NSString *)when
             completion:(void (^)(void))completion
                failure:(void (^)(void))failure;

/**
 发送文件消息

 @param filePath 文件本地路径
 @param fileName 文件名称
 @param fileSize 文件大小
 @param progressHander 上传文件进度
 @param completion 发送文件消息成功回调
 @param failure 发送消息失败回调
 */
- (void)sendFilePath:(NSString *)filePath
            fileName:(NSString *)fileName
            fileSize:(NSString *)fileSize
      progressHander:(void (^)(float))progressHander
          completion:(void (^)(void))completion
             failure:(void (^)(NSString *))failure;

//用于xbot表单消息上传附件
- (void)sendFile:(NSDictionary *)fileDic
  progressHander:(void (^)(float))progressHander
      completion: (void (^)(NSString *))completion
         failure:(void (^)(NSString *))failure;

/**
 存储卡片消息到本地数据库

 @param cardinfo 卡片消息字典
 @param completion 存储卡片消息成功回调
 @param failure 存储卡片消息失败回调
 */
- (void)sendCardMessage:(NSDictionary *)cardinfo
                   type:(NSString *)type
             completion: (void (^)(void))completion
                failure: (void (^)(void))failure;

/**
 发送卡片消息

 @param cardinfo 卡片消息字典
 @param completion 发送卡片消息成功回调
 @param failure 发送卡片消息失败回调
 */
- (void)sendCardInfoMessage:(NSDictionary *)cardinfo
                 completion:(void (^)(void))completion
                    failure:(void (^)(NSString *))failure;

/**
 发送满意度消息
 
 @param text 满意度标题&评价内容
 @param ID 满意度id 即会话id
 @param status 满意度状态
 */
//- (void)sendEvaluateMessage:(NSString *)text
//                     withID:(NSString *)ID
//                 withStatus:(NSString *)status
//              withTimestamp:(NSString *)timestamp;
- (void)sendEvaluateMessage:(NSDictionary *)dic;

- (void)sendFormMessage:(NSDictionary *)dic;

/**
 自定义类型消息
 @param type 消息类型(暂不支持以定义的消息类型回显)
 @param mateData 消息体
 */
- (void)sendOtherInfoData:(NSDictionary *)mateData
                     type:(NSString *)type;

/**
 消息重新发送

 @param message 消息实例
 @param completion 消息重新发送成功回调
 @param failure 消息重新发送失败回调
 */
- (void)reSendMessageWithMessageType:(CustomMessage *)message
                          completion:(void (^)(void))completion
                             failure:(void (^)(NSString *))failure;

/**
 断网时发生消息的处理
 pc端未关闭会话
 */
- (void)afreshStatusErrorMessage;

/**
 断网时发生消息的处理
 pc端已经关闭会话
 */
- (void)changeMessageStatus;

/**
 建立消息模型

 @param type 消息类型
 @param filePath 文件本地路径
 @param content 消息内容
 @param metaData 扩展信息
 @return 返回消息实例
 */
- (CustomMessage *)createMessageWithMessageType:(NSString *)type
                                       filePath:(NSString *)filePath
                                        content:(NSString *)content
                                       metaData:(NSDictionary *)metaData;

/**
 下载文件

 @param message 消息模型
 @param localFilePath 本地存储路径
 @param progress 下载进度
 @param completion 下载文件成功回调
 @param failure 下载文件失败回调
 */
- (void)downLoadFileFromQiniuWithUrl:(CustomMessage *)message
                       localFilePath:(NSString *)localFilePath
                            progress:(void (^)(NSProgress *))progress
                          completion:(void (^)(void))completion
                             failure:(void (^)(void))failure;

- (void)insertTextToIMDB:(CustomMessage *)message;

/**
 定时断开会话的提醒
 */
- (void)sendBreakTipMessage:(NSString *)text;

@end




