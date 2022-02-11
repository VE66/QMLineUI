//
//  UIView+Hex.h
//  IMSDK
//
//  Created by lishuijiao on 2020/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QMView)

/**
 *  设置圆角
 */
@property (nonatomic, assign) CGFloat QMCornerRadius;

/**
  ** lineView:       需要绘制成虚线的view
  ** lineLength:     虚线的宽度
  ** lineSpacing:    虚线的间距
  ** lineColor:      虚线的颜色
  **/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;
/**边框虚线*/
+ (void)drawLineForView:(UIView *)view lineColor:(UIColor *)lineColor;
/**
 获取当前屏幕显示的viewcontroller
 */
- (UIViewController *)getCurrentVC;

/**
 ** radius:     绘制圆角
 ** width:      边框宽度
 ** color:      边框颜色
 */
- (void)QM_ClipCorners:(UIRectCorner)corners radius:(CGFloat)radius;
- (void)QM_ClipCorners:(UIRectCorner)corners radius:(CGFloat)radius border:(CGFloat)width color:(nullable UIColor *)color;

@end

NS_ASSUME_NONNULL_END
