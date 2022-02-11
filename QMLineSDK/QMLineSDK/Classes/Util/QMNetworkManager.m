//
//  QMNetworkManager.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/24.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMNetworkManager.h"
#import "QMGlobaMacro.h"

typedef void (^QMDownloadProgressBlock)(NSProgress *);
typedef void (^QMDownloadFailureBlock)(NSURLSessionDownloadTask * _Nullable, NSError *);
typedef void (^QMDownloadSuccessBlock)(NSURLSessionDownloadTask *, id _Nullable);

@interface QMNetworkManager()<NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, copy)QMDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, copy)QMDownloadSuccessBlock downloadSuccessBlock;
@property (nonatomic, copy)QMDownloadFailureBlock downloadFailureBlock;

@end

@implementation QMNetworkManager

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 初始化
    self.baseURL = url;
    
    self.requestSerialzer = [QMNetworkRequestSerializer serializer];
    self.responseSerialzer = [QMNetworkResponseSerializer serilaizer];
    
    return self;
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(nullable id)parameters success:(nullable void(^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    BOOL main = [self.baseURL.absoluteString isEqualToString:sdkRequestUrlStr1];
    [self Request:main urlString:URLString parameters:parameters success:success failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
        [self Request:!main urlString:URLString parameters:parameters success:success failure:failure];
    }];
    
    return nil;
}

- (nullable NSURLSessionDataTask *)Request:(BOOL)main urlString:(NSString *)URLString parameters:(nullable id)parameters success:(nullable void(^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void(^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {

    NSString *BaseURL = sdkRequestUrlStr1;
    if (![[QMGlobaMacro shared] isDynamicConnection]) {
        BaseURL = [[QMGlobaMacro shared] oemHttp];
    }else {
        BaseURL = main ? sdkRequestUrlStr1 : sdkRequestUrlStr2;
    }
    
    NSString *urlString = [BaseURL stringByAppendingPathComponent:URLString];
    
    // 处理request
    NSError *serialzerError = nil;
    NSMutableURLRequest *request = [self.requestSerialzer requestWithMethod:@"POST" URLString:urlString parameters:parameters error:&serialzerError];
//    request.timeoutInterval = 30;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@", response);
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        }else {
            id responseObject = [self.responseSerialzer responseWithData:response data:data error:&error];
            if (success) {
                success(dataTask, responseObject);
            }
        }
        
    }];
    
    [dataTask resume];
    
    return dataTask;
}

- (nullable NSURLSessionDownloadTask *)GET:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress *))progress success:(void (^)(NSURLSessionDownloadTask *, id _Nullable))success failure:(void (^)(NSURLSessionDownloadTask * _Nullable, NSError *))failure {
    
    self.downloadProgressBlock = progress;
    self.downloadSuccessBlock = success;
    self.downloadFailureBlock = failure;
    
    NSString *urlString = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *dataTask = [session downloadTaskWithRequest:request];
    
    [dataTask resume];
    
    return dataTask;
}

#pragma mark -- NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    self.downloadSuccessBlock(downloadTask, location.path);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSProgress *progress = [[NSProgress alloc] init];
    [progress setTotalUnitCount:totalBytesExpectedToWrite];
    [progress setCompletedUnitCount:totalBytesWritten];
    self.downloadProgressBlock(progress);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.downloadFailureBlock((NSURLSessionDownloadTask *)task, error);
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, card);
}

@end
