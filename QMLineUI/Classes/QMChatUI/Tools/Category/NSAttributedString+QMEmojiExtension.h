//
//  NSAttributedString+QMEmojiExtension.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (QMEmojiExtension)

- (NSString *)getRichString;

@end


@interface QMTextAttachment : NSTextAttachment

@property(strong, nonatomic) NSString *emojiCode;

@property(assign, nonatomic) CGSize emojiSize;

@end


NS_ASSUME_NONNULL_END
