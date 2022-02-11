//
//  UIColor+Hex.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - 颜色
static NSString *QMColor_Nav_Bg_Light = @"#FFFFFF";
static NSString *QMColor_Nav_Bg_Dark = @"#1D1B1B";

///会话页面 light_#EDEDED dark_#141212
static NSString *QMColor_Main_Bg_Light = @"#EDEDED";
static NSString *QMColor_Main_Bg_Dark = @"#141212";

///坐席消息背景色 light_#FFFFFF dark_#2C2C2C
static NSString *QMColor_News_Agent_Light = @"#FFFFFF";
static NSString *QMColor_News_Agent_Dark = @"#2C2C2C";

///访客消息背景色 #0081FF
static NSString *QMColor_News_Custom = @"#0081FF";

static NSString *QMColor_1E1E1E_BG = @"#1E1E1E";
 
static NSString *QMColor_F6F6F6_BG = @"#F6F6F6";

static NSString *QMColor_ECECEC_BG = @"#ECECEC";

static NSString *QMColor_FFFFFF_text = @"#FFFFFF";

static NSString *QMColor_3D3D3D_text = @"#3D3D3D";

static NSString *QMColor_D4D4D4_text = @"#D4D4D4";

static NSString *QMColor_D5D5D5_text = @"#D5D5D5";

static NSString *QMColor_000000_text = @"#000000";

static NSString *QMColor_151515_text = @"#151515";

static NSString *QMColor_333333_text = @"#333333";

static NSString *QMColor_666666_text = @"#666666";

static NSString *QMColor_999999_text = @"#999999";

@interface UIColor (QMColor)


/*
 从十六进制字符串获取颜色，
 color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 默认alpha位1
 **/
+ (UIColor *)colorWithHexString:(NSString *)color;

/*
从十六进制字符串获取颜色，
color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
**/
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
