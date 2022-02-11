//
//  QMNetworkSerialization.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/24.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark Request Serialization

@protocol QMNetworkRequestSerialization <NSObject>

- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest *_Nullable)request
                                            parameters:(nullable id)parameters
                                                 error:(NSError * _Nullable __autoreleasing *_Nullable)error;

@end

@interface QMNetworkRequestSerializer: NSObject <QMNetworkRequestSerialization>

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

+ (instancetype _Nullable )serializer;

- (nullable NSMutableURLRequest *)requestWithMethod:(NSString *_Nullable)method
                                          URLString:(NSString *_Nullable)URLString
                                parameters:(nullable id)parameters
                                              error:(NSError * _Nullable __autoreleasing *_Nullable)error;

@end

#pragma mark Response Serialization

@protocol QMNetworkResponseSerialization <NSObject>

- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                                    data:(nullable NSData *)data
                                   error:(NSError * _Nullable __autoreleasing *_Nullable)error;

@end


@interface QMNetworkResponseSerializer: NSObject <QMNetworkResponseSerialization>

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

+ (instancetype _Nullable )serilaizer;


- (nullable id)responseWithData:(nullable NSURLResponse *)response
                           data:(nullable NSData *)data
                          error:(NSError * _Nullable __autoreleasing *_Nullable)error;

@end






