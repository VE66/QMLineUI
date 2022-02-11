//
//  UIImage+QMImage.h
//  QMLineSDK
//
//  Created by 焦林生 on 2021/12/9.
//  Copyright © 2021 haochongfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QMImage)

+ (UIImage *)addImageToBgImage:(UIImage *)bgImage addImage:(UIImage *)image atSize:(CGSize)size toPoint:(CGPoint)point;

+ (UIImage *)qm_getNewImageWithOriginalImage:(UIImage *)originalImage  waterImage:(UIImage *)waterImage;

@end

NS_ASSUME_NONNULL_END
