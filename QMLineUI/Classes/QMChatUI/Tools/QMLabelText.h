//
//  QMLabelText.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMLabelText : NSObject


@property (nonatomic, copy)NSString *content;

@property (nonatomic, copy)NSString *type;
/// 第几次出现的标识（区别type相同的情况）
@property (nonatomic, copy)NSString *rangeValue;

@property (nonatomic, copy)NSString *status;

/// 计算文字Size
/// @param text 文本
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxWidth 最大宽度
/// @param maxHeight 最大高度
+ (CGSize)calculateText:(NSString *)text
               fontName:(NSString *)fontName
               fontSize:(NSInteger)fontSize
               maxWidth:(CGFloat)maxWidth
              maxHeight:(CGFloat)maxHeight;

/// 计算文字高度
/// @param text 文字
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxWidth 最大宽度
+ (CGFloat)calculateTextHeight:(NSString *)text
                      fontName:(NSString *)fontName
                      fontSize:(NSInteger)fontSize
                      maxWidth:(CGFloat)maxWidth;

/// 计算文字宽度
/// @param text 文字
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxHeight 最大高度
+ (CGFloat)calculateTextWidth:(NSString *)text
                     fontName:(NSString *)fontName
                     fontSize:(NSInteger)fontSize
                    maxHeight:(CGFloat)maxHeight;

+ (NSMutableArray *)dictionaryWithJsonString:(NSString *)jsonString;

+ (CGFloat)calcRobotHeight: (NSString *)htmlString;

+ (CGSize)MLEmojiLabelText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth;

/// 关键字变色
/// @param sourceString 原数据符串
/// @param sourceColor 原数据颜色
/// @param sourceFont 原数据字号
/// @param keyWordArray 关键词数据
/// @param keyWordColor 关键词颜色
/// @param keyWordFont 关键词字号
+ (NSAttributedString *)colorAttributeString:(NSString *)sourceString sourceSringColor:(UIColor *)sourceColor sourceFont:(UIFont *)sourceFont keyWordArray:(NSArray<NSString *> *)keyWordArray keyWordColor:(UIColor *)keyWordColor keyWordFont:(UIFont *)keyWordFont;

@end

NS_ASSUME_NONNULL_END
