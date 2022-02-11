//
//  QMPushManager.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMPushManager : NSObject

@property (nonatomic, assign) BOOL isStyle;

@property (nonatomic, assign) BOOL selectedPush;

@property (nonatomic, assign) BOOL isFinish;

@property (nonatomic, assign) BOOL isOpenRead;

@property (nonatomic, strong) PHAsset *asset;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
