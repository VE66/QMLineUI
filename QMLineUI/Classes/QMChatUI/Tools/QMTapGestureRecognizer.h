//
//  QMTapGestureRecognizer.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic ,copy)NSString * picName;

@property (nonatomic ,copy)NSString * picType;

@property (nonatomic ,strong)UIImage *image;

@property (nonatomic ,copy)NSString * messageId;

@end

NS_ASSUME_NONNULL_END
