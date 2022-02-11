//
//  NSAttributedString+QMEmojiExtension.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "NSAttributedString+QMEmojiExtension.h"

@implementation NSAttributedString (QMEmojiExtension)

- (NSString *)getRichString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[QMTextAttachment class]]) {
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                     withString:((QMTextAttachment *) value).emojiCode];
                          base += ((QMTextAttachment *) value).emojiCode.length - 1;
                      }
                  }];
    
    return plainString;
}

@end



@implementation QMTextAttachment

@end
