//
//  QMAttributedManager.m
//  Demo-C
//
//  Created by ZCZ on 2021/6/24.
//

#import "QMAttributedManager.h"
#import "QMRegex.h"
#import "NSAttributedString+QMEmojiExtension.h"
@interface QMAttributedManager ()



@end

@implementation QMAttributedManager

+ (instancetype)shared {
    static QMAttributedManager *_qm_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qm_shared = [[QMAttributedManager alloc] init];
    });
    return _qm_shared;
}

- (NSAttributedString *)filterText:(NSString *)text {
    return [self filterString:text font:self.font skipFilterPhoneNum:NO];
}

- (NSAttributedString *)filterText:(NSString *)text skipFilterPhoneNum:(BOOL)fPhoneNum {
    return [self filterString:text font:self.font skipFilterPhoneNum:fPhoneNum];
}


- (NSAttributedString *)filterString:(NSString *)text font:(UIFont *)font skipFilterPhoneNum:(BOOL)fPhoneNum {
    if (!text) {
        return [NSAttributedString new];
    }
    
    font = font ? : self.font;
    
    text  = [text stringByReplacingOccurrencesOfString:@"<7moorbr/>" withString:@"\n"];
    text  = [text stringByReplacingOccurrencesOfString:@"<7moorbr>" withString:@"\n"];

    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    return [self filterAttributedString:attr font:font skipFilterPhoneNum:fPhoneNum];
}

- (NSAttributedString *)filterString:(NSString *)text font:(UIFont *)font {
    return [self filterString:text font:font skipFilterPhoneNum:NO];
}

- (NSAttributedString *)filterAttributedString:(NSAttributedString *)text font:(UIFont *)font skipFilterPhoneNum:(BOOL)fPhoneNum {
    if (text.length == 0 ) {
        return text;
    }
    
    font = font ? : self.font;
    
    NSMutableAttributedString *attr = text.mutableCopy;
    [attr addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, attr.length)];
    
    NSArray *https = [self rangeHttp:attr.string];
    for (NSTextCheckingResult *result in https) {
        if (result.range.location != NSNotFound) {
            NSString *http = [attr attributedSubstringFromRange:result.range].string;
            [attr addAttributes:@{NSLinkAttributeName:http} range:result.range];
        }
    }
    
    if (fPhoneNum == NO) {
        NSArray *phones = [QMRegex getMobileNumberLoc:attr.string];
        for (NSTextCheckingResult *result in phones) {
            if (result.range.location != NSNotFound) {
                NSString *phone = [attr attributedSubstringFromRange:result.range].string;
                phone = [@"tel://" stringByAppendingString:phone];
                [attr addAttributes:@{NSLinkAttributeName:phone} range:result.range];
            }
        }
    }
    
    while ([attr.string hasSuffix:@"\n"]) {
        [attr replaceCharactersInRange:NSMakeRange(attr.length - 1, 1) withString:@""];
    }
    
    [attr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSTextAttachment * value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            CGRect bound = value.bounds;
            CGFloat widht = UIScreen.mainScreen.bounds.size.width - (45+12)*2-18-12;
            CGFloat att_height = 160;
            if (widht < att_height) {
                CGFloat height = widht*bound.size.height/bound.size.width;
                bound.size.width = widht;
                bound.size.height = att_height > height ? height : att_height;
                value.bounds = bound;
            }
            
        }
    }];
    
    return [self filterEmoji:attr font:font];
}

- (NSAttributedString *)filterAttributedString:(NSAttributedString *)text font:(UIFont *)font  {
    return [self filterAttributedString:text font:font skipFilterPhoneNum:NO];
}

- (NSAttributedString *)filterEmoji:(NSAttributedString *)attring font:(UIFont *)font {
    NSArray *items = [self rangeEmoji:attring.string];
    items = [items sortedArrayUsingComparator:^NSComparisonResult(NSTextCheckingResult *obj1, NSTextCheckingResult *obj2) {
        return obj1.range.location < obj2.range.location;
    }];
    
    QMTextAttachment * emojiTextAttemt = [QMTextAttachment new];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"QMEmoticon" ofType:@"bundle"];
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"expressionImage" ofType:@"plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:fileName];
    NSDictionary *emDict = plistDict;
    NSMutableAttributedString *attr = attring.mutableCopy;
    for (NSTextCheckingResult *result in items) {
        if (result.range.location != NSNotFound) {
            NSAttributedString *str = [attr attributedSubstringFromRange:result.range];
            UIImage *value = emDict[str.string];
            if (value && [value isKindOfClass:UIImage.class]) {
                NSTextAttachment *arkAttch = [NSTextAttachment new];
                arkAttch.image = value;
                arkAttch.bounds = CGRectMake(0, -5, font.lineHeight, font.lineHeight);
                NSAttributedString *attach = [NSAttributedString attributedStringWithAttachment:arkAttch];
                [attr replaceCharactersInRange:result.range withAttributedString:attach];
            }
        }
    }
    return attr.copy;
}

- (NSArray <NSTextCheckingResult *>*)rangeEmoji:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }
    NSString *ragText = @":\\w+\\s*\\w*:";
    NSRegularExpression *ragx = [[NSRegularExpression alloc] initWithPattern:ragText options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    NSArray *arr = [ragx matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
    return arr;
}

- (NSArray <NSTextCheckingResult *>*)rangeHttp:(NSString *)text {
    if (text.length == 0) {
        return nil;
    }

    NSString * ragText = @"((http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w-\\.,@?^=%&:/~\\+#]*[\\w-\\@?^=%&/~\\+#])?)";

    NSRegularExpression *ragx = [[NSRegularExpression alloc] initWithPattern:ragText options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSArray *arrs = [ragx matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
    
    return arrs;
}


- (UIFont *)font {
    return _font ? : [UIFont fontWithName:@"PingFangSC-Regular" size:16];
}

@end

