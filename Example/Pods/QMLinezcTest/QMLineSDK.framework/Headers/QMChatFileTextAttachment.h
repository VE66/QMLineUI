//
//  QMChatFileTextAttachment.h
//  QMLineSDK
//
//  Created by 焦林生 on 2021/12/9.
//  Copyright © 2021 haochongfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatFileTextAttachment : NSTextAttachment

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *org_imageurl;
// video image
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL need_replaceImage;

@end

NS_ASSUME_NONNULL_END
