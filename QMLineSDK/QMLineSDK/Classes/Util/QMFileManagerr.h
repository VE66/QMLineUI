//
//  QMFileManager.h
//  QMLineSDK
//
//  Created by haochongfeng on 2018/12/11.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMFileManagerr : NSObject

@property (nonatomic, copy)NSString *filePath;

+ (instancetype)sharedInstance;

- (void)createFileWith:(NSString *)fileName;

- (void)writeDataToFile:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
