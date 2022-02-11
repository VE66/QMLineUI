//
//  QMNetworkSerialization.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/24.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMNetworkSerialization.h"

@implementation QMNetworkRequestSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 初始化
    
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
    
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    mutableRequest.timeoutInterval = 10;
        
    mutableRequest = [[self requestBySerializingRequest:mutableRequest parameters:parameters error:error] mutableCopy];
        
    return mutableRequest;
}

#pragma QMNetworkRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request parameters:(id)parameters error:(NSError *__autoreleasing *)error {

    NSParameterAssert(request);
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    if (parameters) {
        
        if (![NSJSONSerialization isValidJSONObject:parameters]) {
            return nil;
        }
        
        NSData * data = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:error];
        
        if (!data) {
            return nil;
        }
    
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (!jsonString) {
            return nil;
        }
        
        jsonString = [NSString stringWithFormat:@"data=%@", jsonString];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
//        NSLog(@"最终的jsonString == %@", jsonString);
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!jsonData ) {
            return nil;
        }

        [mutableRequest setHTTPBody:jsonData];
    }
    
    return mutableRequest;
}

@end


@implementation QMNetworkResponseSerializer

+ (instancetype)serilaizer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.readingOptions = NSJSONReadingMutableContainers;
    
    return self;
}

- (id)responseWithData:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    return [self responseObjectForResponse:response data:data error:error];
}

#pragma QMNetworkResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    
    
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];

    if (data.length == 0 || isSpace)  {
        return nil;
    }
    NSError *serializationError = nil;
    
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
    
    if (!responseObject) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:serializationError.domain code:serializationError.code userInfo:serializationError.userInfo];
        }
        return nil;
    }
    
    return responseObject;
}

@end
