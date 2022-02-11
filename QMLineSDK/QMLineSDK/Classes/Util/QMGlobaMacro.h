//
//  QMGlobaMacro.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    QMChatModeNone = 0,
    QMChatModeSchedule,
    QMChatModePeers,
} QMChatMode;

#define QMUIKitResource(name) [[NSBundle mainBundle] pathForResource:@"QMLineBundle" ofType:@"bundle"] == nil ? ([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"Frameworks/QMLineSDK.framework/QMLineBundle.bundle"] stringByAppendingPathComponent:name]) : ([[[NSBundle mainBundle] pathForResource:@"QMLineBundle" ofType:@"bundle"] stringByAppendingPathComponent:name])

//// 研发环境tcp
//static NSString *ping_host = @"139.199.128.94";  // 默认tcp地址
//static int ping_port = 7021; // 默认tcp端口
//static NSString *baseUrlStr = @"http://140.143.60.140:3209"; // 默认http请求地址
//static NSString *sdkRequestUrlStr1 = @"http://140.143.60.140:3209"; // 第一个http请求地址
//static NSString *sdkRequestUrlStr2 = @"http://140.143.60.140:3209"; // 第二个http请求地址

////// 测试tcp
//static NSString *ping_host = @"139.199.128.94";  // 默认tcp地址
//static int ping_port = 7121; // 默认tcp端口
//static NSString *baseUrlStr = @"http://58.87.118.20:3109"; // 默认http请求地址
//static NSString *sdkRequestUrlStr1 = @"http://58.87.118.20:3109"; // 第一个http请求地址
//static NSString *sdkRequestUrlStr2 = @"http://58.87.118.20:3109"; // 第二个http请求地址

//static NSString *baseUrlStr = @"http://58.87.118.20:3309"; // 默认http请求地址
//static NSString *sdkRequestUrlStr1 = @"http://58.87.118.20:3309"; // 第一个http请求地址
//static NSString *sdkRequestUrlStr2 = @"http://58.87.118.20:3309"; // 第二个http请求地址

//预发布环境
//static NSString *ping_host = @"139.199.128.94";
//static int ping_port = 7021;
//static NSString *baseUrlStr = @"http://pre-webchat.7moor.com";
//static NSString *sdkRequestUrlStr1 = @"http://pre-webchat.7moor.com";
//static NSString *sdkRequestUrlStr2 = @"http://pre-webchat.7moor.com";

// 阿里云正式环境tcp
static NSString *ping_host = @"cc-sdk-tcp05.7moor-fs1.com";  // 默认tcp地址
static int ping_port = 8008; // 默认tcp端口
static NSString *baseUrlStr = @"https://cc-sdk-http.7moor-fs1.com"; // 默认http请求地址
static NSString *sdkRequestUrlStr1 = @"https://cc-sdk-http.7moor-fs1.com"; // 第一个http请求地址
static NSString *sdkRequestUrlStr2 = @"https://cc-sdk-http.7moor-fs1.com"; // 第二个http请求地址
static NSString *sdkwebSocketUrl = @"ws://cc-sdk-socket01.7moor-fs1.com/webSocket";

// 腾讯云正式环境tcp
//static NSString *ping_host = @"tx-sdk-tcp01.7moor-fs1.com";  // 默认tcp地址
//static int ping_port = 8006; // 默认tcp端口
//static NSString *baseUrlStr = @"https://ykf-webchat.7moor-fs1.com"; // 默认http请求地址
//static NSString *sdkRequestUrlStr1 = @"https://ykf-webchat.7moor-fs1.com"; // 第一个http请求地址
//static NSString *sdkRequestUrlStr2 = @"https://ykf-webchat.7moor-fs1.com"; // 第二个http请求地址
//static NSString *webSocket = @"ws://tx-sdk-socket01.7moor-fs1.com/webSocket";

/**
 连接id 用于接口请求参数
 */
static NSString *CUSTOM_CONNECT_ID = @"Custom_Connect_Id";

/**
 会话id 用户数据库查询
 */
static NSString *CUSTOM_SESSION_ID = @"Custom_Session_Id";

/**
 sdk版本信息
 */
static NSString *sdkIOSVersion = @"v4.0.0";

/**
 sdk版本信息
 */
static const float custom_version = 4.0;

/**
 文件存储路径
 */

#pragma mark - appEngin


#pragma mark - 工具类
@interface QMGlobaMacro : NSObject

+ (instancetype)shared;

@property (nonatomic, copy) NSString *custom_sessionId;

/**
 注册的userid 用于数据库查询
 */
@property (nonatomic, copy) NSString *registUserId;

/**
 注册的accessId 用于请求参数和数据查询
 */
@property (nonatomic, copy) NSString *custom_accessId;

/**
 防止重复请求
 */
@property (nonatomic, assign) BOOL isRequest;

/**
 远程推送的token
 */
@property (nonatomic, copy) NSData *token;

/**
 插入数据临时监控
 */
@property (nonatomic, copy) NSDictionary *monitorDict;

/**
 查询数据临时监控
 */
@property (nonatomic, copy) NSString *monitorContext;

/**
 是否动态获取tcp地址，默认true
 */
@property (nonatomic, assign) BOOL isDynamicConnection;

/**
 自建tcp地址
 */
@property (nonatomic, copy) NSString *oemHost;

/**
 自建tcp端口
 */
@property (nonatomic, assign) int oemPort;

/**
 自建http地址
 */
@property (nonatomic, copy) NSString *oemHttp;

/**
 记录人工之后访客是否说话
 */
@property (nonatomic, assign) BOOL isSpeekMessage;

/**
 记录坐席是否说话 >0 已说话
 */
@property (nonatomic, assign) NSNumber *replyMsg;

/**
 该会话的_id;
 */
@property (nonatomic, copy) NSString *chatID;

/**
 手机设备型号

 @return 型号
 */
@property (nonatomic, copy) NSString *phoneDeviceId;

/**
 记录入口 --技能组还是日程
 主要用于判断newbeginSession接口调用的是否正确 3种状态 1、空字符串不做判断 都可以进入  2、日程只能进日程接口  3、技能组只能进技能组接口
 */
@property (nonatomic, assign) QMChatMode chatMode;

/**
 显示对方撤回一条消息的文案
    
 默认文案：对方撤回一条消息
 */
@property (nonatomic, copy) NSString *WithdrawMessage;

@property (nonatomic, assign) BOOL isWebSocket;

/**
 账户编号
 newBeginSession返回
 */
@property (nonatomic, copy) NSString *account;

//定时测试
//是否注册成功
@property (nonatomic, assign) BOOL isRegist;

//是否开始注册tcp
@property (nonatomic, assign) BOOL isStartTcp;

//定时时间到
@property (nonatomic, assign) BOOL isStop;

//七牛上传地址
@property (nonatomic, copy) NSString *qiNiuFileServer;
//七牛zone 上传地址
@property (nonatomic, copy) NSString *qiNiuZoneServer;
//是否更改七牛服务
@property (nonatomic, assign) BOOL isQINiuServer;

+ (NSString *)deviceModelName;

+ (NSString *)JSONString:(NSDictionary *)dictionary;

+ (NSString *)pathOfDocument;

+ (NSString *)nowDate;

@end
