//
//  webSocketManager.h
//  webSocketTest
//
//  Created by lishuijiao on 2020/7/27.
//  Copyright © 2020 Lisj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "QMLineDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum: NSInteger {
    webSocketConnectStatusDisconnected   = -1,    //未连接
    webRegisterErrorStatusConnecting     = 0,     //连接中
    webRegisterErrorStatusConnected      = 1,     //已连接
}webSocketConnectStatus;

typedef void (^webScoketStatusBlock) (webSocketConnectStatus status);

@interface QMWebSocketManager : NSObject

@property (nonatomic, assign) webSocketConnectStatus connectStatus; //socket链接状态

@property (nonatomic, copy) webScoketStatusBlock statusBlock; //状态回调

@property (nonatomic, assign) id<QMKRegisterDelegate> delegate;

@property (nonatomic, assign) id<QMKServiceDelegate> dataSource;

+ (instancetype)shared;

- (void)connectServer;

- (void)createSocketWithAccessId:(NSString *)accessId
                        userName:(NSString *)name
                          userId:(NSString *)password
                        delegate:(nullable id<QMKRegisterDelegate>)delegate;

- (void)disConnectSocket;

@end

NS_ASSUME_NONNULL_END
