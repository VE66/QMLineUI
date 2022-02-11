//
//  QMLineError.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/26.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMLineError.h"

#define QM_EMPTY_ACCESSID   @"注册的key不能为空"
#define QM_EMPTY_USERNAME   @"注册的用户名不能为空"
#define QM_EMPTY_USERID     @"注册的用户ID不能为空"
#define QM_ACCESSID_ERROR   @"注册的key不存在或者错误"
#define QM_USERID_VIOLATION @"注册的用户ID不合法，请按规则填写"
#define QM_CONNECT_FAILED   @"建立服务器连接失败"
#define QM_AUTH_FAILED      @"校验token失败,请检查注册参数"
#define QM_SERVER_EXCEPTION @"服务异常"
#define QM_UNKNOW_ERROR     @"未知错误"

@implementation QMLineError

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

+ (instancetype)initWithError:(QMRegisterErrorCode)errorCode {
    return [self initWithError:errorCode error:nil];
}


+ (instancetype)initWithError:(QMRegisterErrorCode)errorCode error:(NSString *)message {

    QMLineError *error = [[QMLineError alloc] init];
    
    switch (errorCode) {
        case 4000:
            [error setErrorCode:QMRegisterErrorCodeEmptyAccessId];
            [error setErrorDesc:QM_EMPTY_ACCESSID];
            break;
        case 4001:
            [error setErrorCode:QMRegisterErrorCodeEmptyUsername];
            [error setErrorDesc:QM_EMPTY_USERNAME];
            break;
        case 4002:
            [error setErrorCode:QMRegisterErrorCodeEmptyUserId];
            [error setErrorDesc:QM_EMPTY_USERID];
            break;
        case 4003:
            [error setErrorCode:QMRegisterErrorCodeAccessIdError];
            [error setErrorDesc:QM_ACCESSID_ERROR];
            break;
        case 4004:
            [error setErrorCode:QMRegisterErrorCodeUserIdViolation];
            [error setErrorDesc:QM_USERID_VIOLATION];
            break;
//        case 4005:
//            [error setErrorCode:QMRegisterErrorCodeConnectFailed];
//            [error setErrorDesc:QM_CONNECT_FAILED];
//            break;
        case 4005:
            [error setErrorCode:QMRegisterErrorCodeConnectFailed];
            [error setErrorDesc:message];
            break;
        case 4006:
            [error setErrorCode:QMRegisterErrorCodeAuthFailed];
            [error setErrorDesc:QM_AUTH_FAILED];
            break;
        case 4007:
            [error setErrorCode:QMRegisterErrorCodeServiceException];
            [error setErrorDesc:QM_SERVER_EXCEPTION];
            break;
        default:
            [error setErrorCode:QMRegisterErrorCodeUnknow];
            [error setErrorDesc:QM_UNKNOW_ERROR];
            break;
    }
    
    return error;

}
@end
