//
//  QMLabelText.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import "QMLabelText.h"
#import "QMChatUI.h"
@implementation QMLabelText

/// 计算文字Size
/// @param text 文本
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxWidth 最大宽度
/// @param maxHeight 最大高度
+ (CGSize)calculateText:(NSString *)text fontName:(NSString *)fontName fontSize:(NSInteger)fontSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight {
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]};
    CGSize maxSize = CGSizeMake(maxWidth, maxHeight);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect labelRect = [text boundingRectWithSize:maxSize options: options attributes:attribute context:nil];
    return labelRect.size;
}

/// 计算文字高度
/// @param text 文字
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxWidth 最大宽度
+ (CGFloat)calculateTextHeight:(NSString *)text fontName:(NSString *)fontName fontSize:(NSInteger)fontSize maxWidth:(CGFloat)maxWidth {
    CGSize textSize = [self calculateText:text fontName:fontName fontSize:fontSize maxWidth:maxWidth maxHeight:0];
    return textSize.height;
}

/// 计算文字宽度
/// @param text 文字
/// @param fontName 字体
/// @param fontSize 字体大小
/// @param maxHeight 最大高度
+ (CGFloat)calculateTextWidth:(NSString *)text fontName:(NSString *)fontName fontSize:(NSInteger)fontSize maxHeight:(CGFloat)maxHeight {
    CGSize textSize = [self calculateText:text fontName:fontName fontSize:fontSize maxWidth:0 maxHeight:maxHeight];
    return textSize.width;
}

+ (NSMutableArray *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

// 计算文本图片混合高度
+ (CGFloat)calcRobotHeight: (NSString *)htmlString {
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    if ([htmlString containsString:@"</p>"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    } else if ([htmlString containsString:@"<p>"]) {
        if ([htmlString hasPrefix:@"<p>"]) {
            htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
        }
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    }
    __block CGFloat height = 0;
    __block NSString *tempString = htmlString;
    
    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    [regularExpretion enumerateMatchesInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length != 0) {
            NSString *actionString = [NSString stringWithFormat:@"%@",[htmlString substringWithRange:result.range]];
            
            NSRange range = [tempString rangeOfString:actionString];
            
            // 判断知否包含图片资源
            NSArray *components = nil;
            if ([actionString rangeOfString:@"src=\""].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src=\""];
            }else if ([actionString rangeOfString:@"src="].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src="];
            }
            
            if (components.count >= 2) {
                
                // 文本高度计算
                
                height += [QMLabelText MLEmojiLabelText:[tempString substringToIndex:range.location] fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth].height;
                
                // 图片高度固定
                height += 100;
                
                tempString = [tempString substringFromIndex:range.location+range.length];
            }else {
                tempString = [tempString stringByReplacingCharactersInRange:range withString:@""];
            }
        }
    }];
    
    // 文本高度计算
    height += [QMLabelText MLEmojiLabelText:tempString fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth].height;
    
    return height;
}


+ (CGSize)MLEmojiLabelText:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize maxWidth:(CGFloat)maxWidth {
    MLEmojiLabel *label = [MLEmojiLabel new];
    label.text = text;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:fontName size:fontSize];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.disableEmoji = NO;
    label.disableThreeCommon = NO;
    label.isNeedAtAndPoundSign = YES;
    label.customEmojiRegex = @"\\:[^\\:]+\\:";
    label.customEmojiPlistName = @"expressionImage.plist";
    label.customEmojiBundleName = @"QMEmoticon.bundle";
    CGSize textSize = [label preferredSizeWithMaxWidth:maxWidth];
    return textSize;
}

+ (NSAttributedString *)colorAttributeString:(NSString *)sourceString sourceSringColor:(UIColor *)sourceColor sourceFont:(UIFont *)sourceFont keyWordArray:(NSArray<NSString *> *)keyWordArray keyWordColor:(UIColor *)keyWordColor keyWordFont:(UIFont *)keyWordFont{
    if (sourceString == nil || ![sourceString isKindOfClass:[NSString class]]) {
        sourceString = @"";
    }
    NSMutableArray *muKeyWordsArr;
    if (keyWordArray == nil) {
        muKeyWordsArr = [NSMutableArray arrayWithCapacity:0];
    }else{
        muKeyWordsArr = keyWordArray.mutableCopy;
    }
    if (sourceColor == nil) {
        sourceColor = [UIColor blackColor];
    }
    if (keyWordColor == nil) {
        keyWordColor = [UIColor blackColor];
    }
    if (sourceFont == nil) {
        sourceFont = [UIFont systemFontOfSize:15];
    }
    if (keyWordFont == nil) {
        keyWordFont = [UIFont systemFontOfSize:15];
    }
    NSMutableAttributedString *attributeContent;
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [ps setLineBreakMode:NSLineBreakByTruncatingTail];
    NSDictionary *attriDic = @{NSFontAttributeName : sourceFont,NSForegroundColorAttributeName : sourceColor,NSParagraphStyleAttributeName : ps};
    attributeContent = [[NSMutableAttributedString alloc] initWithString:sourceString attributes:attriDic];
    [muKeyWordsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *searchKey = (NSString *)obj;
        NSError *error = nil;
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:searchKey options:NSRegularExpressionCaseInsensitive error:&error];
        if (!expression) {
        }else {
            [expression enumerateMatchesInString:sourceString options:NSMatchingReportProgress range:NSMakeRange(0, sourceString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                [attributeContent addAttributes:@{NSFontAttributeName : keyWordFont,NSForegroundColorAttributeName:keyWordColor} range:result.range];
            }];
        }
    }];
    return attributeContent;
}

@end
