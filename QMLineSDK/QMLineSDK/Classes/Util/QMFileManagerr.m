//
//  QMFileManager.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/12/11.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMFileManagerr.h"

@implementation QMFileManagerr

+ (instancetype)sharedInstance {
    static QMFileManagerr *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)createFileWith:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:localPath]) {
        self.filePath = localPath;
    }else {
        [fileManager createFileAtPath:localPath contents:nil attributes:nil];
        self.filePath = localPath;
    }
}

- (void)writeDataToFile:(NSString *)content {
//    if (self.filePath) {
//        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.filePath];
//        NSString *jsonStr = [content stringByAppendingString:@"\n"];
//        [fileHandle seekToEndOfFile];
//        NSData *dataStr = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//        [fileHandle writeData:dataStr];
//    }else {
//
//    }
}

@end
