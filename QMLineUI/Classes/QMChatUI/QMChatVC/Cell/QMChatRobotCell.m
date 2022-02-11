//
//  QMChatRobotCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/9.
//

#import "QMChatRobotCell.h"
#import "QMChatShowImageViewController.h"

@interface QMChatRobotCell ()<UITextViewDelegate>

@end
@implementation QMChatRobotCell

- (void)createUI {
    [super createUI];
    
    [self.chatBackgroundView addSubview:self.contentLab];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(6).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.right.equalTo(self.chatBackgroundView).offset(-8);
        make.bottom.equalTo(self.chatBackgroundView).offset(-1).priorityHigh();
        make.height.mas_greaterThanOrEqualTo(38).priorityHigh();
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    
    self.contentLab.text = message.message;
    if (message.attrAttachmentReplaced == 1) {
        [self handleImage:message];
    }
    
    if (message.contentAttr && message.contentAttr.length > 0) {
        self.contentLab.attributedText = message.contentAttr;
    }
    
    if (isDarkStyle) {
        self.contentLab.textColor = [UIColor colorWithHexString:QMColor_FFFFFF_text];
    }
}

- (void)handleImage:(CustomMessage *)model {
    
    // 处理html替换成原本图片-原图片过大加载过慢
    __block BOOL needReload = NO;
    __block BOOL replacedAll = YES;
    
    [model.contentAttr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, model.contentAttr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[QMChatFileTextAttachment class]]) {
            QMChatFileTextAttachment *attach = (QMChatFileTextAttachment *)value;
            
            if ([attach.type isEqualToString:@"image"] && attach.need_replaceImage == YES) {
                NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                path = [path stringByAppendingPathComponent:attach.url.lastPathComponent];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path] == true) {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
                    if (data.length > 0) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        attach.image = image;
                        attach.need_replaceImage = NO;
                        needReload = YES;
                    }
                } else {
                    replacedAll = NO;
                }
            }
        }
    }];
    
    if (replacedAll) {
        model.attrAttachmentReplaced = 2;
    }
    
    if (needReload) {
        self.contentLab.attributedText = model.contentAttr;
        if (self.needReloadCell) {
            self.needReloadCell(model);
        }
    }
}

- (QMChatTextView *)contentLab {
    if (!_contentLab) {
        _contentLab = [[QMChatTextView alloc] init];
        _contentLab.font = [UIFont systemFontOfSize:16];
        _contentLab.textAlignment = NSTextAlignmentLeft;
        _contentLab.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_151515_text];
        _contentLab.backgroundColor = [UIColor clearColor];
        _contentLab.QMCornerRadius = 10;
        _contentLab.delegate = self;
    }
    return _contentLab;
}

#pragma mark -------textViewDelegate-----
- (BOOL)handelTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRang {
    if ([textAttachment isKindOfClass:[QMChatFileTextAttachment class]]) {
        QMChatFileTextAttachment *attach = (QMChatFileTextAttachment *)textAttachment;
        if ([attach.type isEqualToString:@"image"]) {
            QMChatShowImageViewController * showPicVC = [[QMChatShowImageViewController alloc] init];
            showPicVC.modalPresentationStyle = UIModalPresentationFullScreen;
                NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                path = [path stringByAppendingPathComponent:attach.url.lastPathComponent];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path] == true) {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:NSDataReadingMappedAlways error:nil];
                    if (data.length > 0) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        showPicVC.image = image;
                    }
                }
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
        } else {
            self.tapNetAddress(attach.url);
        }
        return false;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    return [self handelTextAttachment:textAttachment inRange:characterRange];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([URL.absoluteString hasPrefix:@"http"]) {
        NSString *text = URL.absoluteString;
        if ([text hasPrefix:@"http://7moor_param="]) {
            text = [[text stringByReplacingOccurrencesOfString:@"http://7moor_param=" withString:@""] stringByRemovingPercentEncoding];
            NSArray *items = [text componentsSeparatedByString:@"QM_recogType"];
            if (items.count > 1) {
                NSString *recogType = items.firstObject;
                if ([recogType isEqualToString:@"4"]) {
                    // 自定义事件
                } else {
                    NSString *value = items.lastObject;
                    self.tapArtificialAction(value);
                }
            } else {
                self.tapArtificialAction(@"");
            }
        } else {
            self.tapNetAddress(text);
        }
    } else {

        NSString *text = URL.absoluteString;
        if ([text hasPrefix:@"tel:"]) {
            if ([text containsString:@"tel://"] == NO) {
                text = [text stringByReplacingOccurrencesOfString:@"tel:" withString:@"tel://"];
            }
            NSURL *url = [NSURL URLWithString:text];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        else {
            text =  [text stringByRemovingPercentEncoding];
            
            NSString *tempString = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSArray *array = [tempString componentsSeparatedByString:@"："];
            if (array.count > 1) {
                self.tapSendMessage(array[1], array[0]);
            }
        }
    }
    return false;
}



@end
