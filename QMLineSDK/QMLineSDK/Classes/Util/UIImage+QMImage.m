//
//  UIImage+QMImage.m
//  QMLineSDK
//
//  Created by 焦林生 on 2021/12/9.
//  Copyright © 2021 haochongfeng. All rights reserved.
//

#import "UIImage+QMImage.h"

@implementation UIImage (QMImage)

+ (UIImage *)addImageToBgImage:(UIImage *)bgImage addImage:(UIImage *)image atSize:(CGSize)size toPoint:(CGPoint)point {
    CGSize atSize = size;

    if (size.width == 0 || size.width == NSNotFound) {
        atSize = bgImage.size;
    }
    UIGraphicsBeginImageContext(atSize);
    
    [bgImage drawInRect:CGRectMake(0, 0, atSize.width, atSize.height)];
    [image drawInRect:CGRectMake(point.x, point.y, image.size.width, image.size.height)];
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg;
}

+ (UIImage *)qm_getNewImageWithOriginalImage:(UIImage *)originalImage  waterImage:(UIImage *)waterImage {

    UIGraphicsBeginImageContext(originalImage.size);
    
    // 原始图片渲染
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    
    CGFloat waterX = originalImage.size.width/2-waterImage.size.width/2;
    CGFloat waterY = originalImage.size.height/2-waterImage.size.height/2;
    CGFloat waterW = 40;
    CGFloat waterH = 40;
    
    // 打入的水印图片 渲染
    [waterImage drawInRect:CGRectMake(waterX, waterY, waterW, waterH)];
    
    UIGraphicsEndPDFContext();
    
    // UIImage
    UIImage * imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    return imageNew;
}


@end
