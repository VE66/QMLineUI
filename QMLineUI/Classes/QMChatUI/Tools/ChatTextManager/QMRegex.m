//
//  QMRegex.m
//  Demo-C
//
//  Created by ZCZ on 2021/6/28.
//

#import "QMRegex.h"

static NSString const *QM_MobileReg = @"1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])[0-9]{8}";
static NSString const *QM_TelephoneReg = @"(1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])[0-9]{8})|([0][1-9]{2,3}-[0-9]{5,10})";


@interface QMRegex ()

@end

@implementation QMRegex

+ (BOOL)isMobileNumber:(NSString *)mobile {
    if ([mobile isKindOfClass:NSString.class] && mobile.length > 0) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:(NSString *)QM_MobileReg options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        NSInteger numb = [reg numberOfMatchesInString:mobile options:NSMatchingAnchored range:NSMakeRange(0, mobile.length)];
        
        return numb > 0;
    } else {
        return NO;
    }
}

+ (NSArray <NSTextCheckingResult *>*)getTelephoneLoc:(NSString *)text {
    if ([text isKindOfClass:NSString.class] && text.length > 0) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:(NSString *)QM_TelephoneReg options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        
        NSArray *telephones = [reg matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
        return telephones;
    } else {
        return nil;
    }
}

+ (NSArray <NSTextCheckingResult *>*)getMobileNumberLoc:(NSString *)text {
    if ([text isKindOfClass:NSString.class] && text.length > 0) {
        NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:(NSString *)QM_MobileReg options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        
        NSArray *telephones = [reg matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
        return telephones;
    } else {
        return nil;
    }
}




@end
