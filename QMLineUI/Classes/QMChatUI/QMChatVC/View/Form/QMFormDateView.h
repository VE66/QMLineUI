//
//  QMFormDateView.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMFormDateView : UIView

typedef void(^dateChooseFinishedBlock)(NSString *date);
typedef void(^dateChooseCancelBlock)(void);

/**
 日期选择器默认显示时间、返回时间格式以及成功或取消回调函数配置

 @param defaultDate 默认日期
 @param dateFormat 日期格式
 @param finishedBlock 成功回调函数
 @param cancelBlock 取消回调函数
 */
+ (instancetype)showDateChooseViewWithDefaultDate:(NSString *)defaultDate dateFormat:(NSString *)dateFormat finishedBlock:(dateChooseFinishedBlock)finishedBlock cancelBlock:(dateChooseCancelBlock)cancelBlock;

- (void)setDefaultDate:(NSString *)defaultDate dateFormat:(NSString *)dateFormat;

@end

NS_ASSUME_NONNULL_END
