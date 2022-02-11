//
//  QMChatNewCardCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/29.
//

#import "QMChatNewCardCell.h"
#import "QMChatShowRichTextController.h"

@implementation QMChatNewCardCell {
    NSDictionary *_cardDic;
    
    NSString *_messageId;
    
    UIView *_newCardView;
    
    UILabel *_titleLabel;
    
    UILabel *_descriptionLabel;
        
    UIImageView *_imageView;
    
    UILabel *_attrOne;
    
    UILabel *_attrTwo;
    
    UILabel *_price;

    UILabel *_otherOne;
    
    UILabel *_otherTwo;

    UILabel *_otherThree;
}

- (void)createUI {
    [super createUI];
    
    _newCardView = [[UIView alloc] init];
    _newCardView.frame = CGRectMake(0, 0, QM_kScreenWidth - 67*2, 110);
    _newCardView.layer.masksToBounds = YES;
    _newCardView.layer.cornerRadius = 8;
    [self.contentView addSubview:_newCardView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_newCardView addGestureRecognizer:tap];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(10, 15, [UIScreen mainScreen].bounds.size.width - 180, 30);
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _titleLabel.numberOfLines = 2;
    [_newCardView addSubview:_titleLabel];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.frame = CGRectMake(10, _titleLabel.frame.size.height + 15, [UIScreen mainScreen].bounds.size.width - 250, 50);
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
    _descriptionLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : @"#595959"];
    [_newCardView addSubview:_descriptionLabel];
        
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake( 10, 10, 80, 80);
    _imageView.QMCornerRadius = 4;
    _imageView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [_newCardView addSubview:_imageView];
    
    _attrOne = [[UILabel alloc] init];
    _attrOne.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_attrOne];

    _attrTwo = [[UILabel alloc] init];
    _attrTwo.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_attrTwo];

    _price = [[UILabel alloc] init];
    _price.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_price];

    _otherOne = [[UILabel alloc] init];
    _otherOne.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_otherOne];

    _otherTwo = [[UILabel alloc] init];
    _otherTwo.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_otherTwo];

    _otherThree = [[UILabel alloc] init];
    _otherThree.font = [UIFont systemFontOfSize:12.0f];
    [_newCardView addSubview:_otherThree];

}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    _messageId = message._id;
    [super setData:message avater:avater];
    
    _titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : @"#000000"];
    _attrOne.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _attrTwo.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _price.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _otherOne.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _otherTwo.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    _otherThree.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    
    NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return;
    }

    _cardDic = dic;
    
    _imageView.hidden = NO;
    _imageView.frame = CGRectMake(10, 20, 60, 60);
    NSString *imgUrl = dic[@"img"];
    if (imgUrl && [imgUrl stringByRemovingPercentEncoding] == imgUrl) {
        imgUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURL *imgUR = [NSURL URLWithString:imgUrl];
    
    [_imageView sd_setImageWithURL:imgUR];


    NSString *otherTitleOne = dic[@"other_title_one"];
    NSString *otherTitleTwo = dic[@"other_title_two"];
    NSString *otherTitleThree = dic[@"other_title_three"];
    
    if (otherTitleOne.length > 0) {
        _otherOne.text = otherTitleOne;
        _otherOne.frame = CGRectMake(10, CGRectGetMaxY(_imageView.frame) + 10, QM_kScreenWidth - 67*2 - 20, 15);
    }else {
        _otherOne.frame = CGRectMake(10, CGRectGetMaxY(_imageView.frame) + 10, QM_kScreenWidth - 67*2 - 20, 0);
    }
    if (otherTitleTwo.length > 0) {
        _otherTwo.text = otherTitleTwo;
        _otherTwo.frame = CGRectMake(10, CGRectGetMaxY(_otherOne.frame) + 5, QM_kScreenWidth - 67*2 - 20, 15);
    }else {
        _otherTwo.frame = CGRectMake(10, CGRectGetMaxY(_otherOne.frame), QM_kScreenWidth - 67*2 - 20, 0);
    }
    if (otherTitleThree.length > 0) {
        _otherThree.text = otherTitleThree;
        _otherThree.frame = CGRectMake(10, CGRectGetMaxY(_otherTwo.frame) + 5, QM_kScreenWidth - 67*2 - 20, 15);
    }else {
        _otherThree.frame = CGRectMake(10, CGRectGetMaxY(_otherTwo.frame), QM_kScreenWidth - 67*2 - 20, 0);
    }

    if ([message.fromType isEqualToString:@"1"]) {
        NSString *price = dic[@"price"];
        NSString *attrOne = dic[@"attr_one"][@"content"];
        NSString *attrTwo = dic[@"attr_two"][@"content"];
        
        NSString *attrOneColor = dic[@"attr_one"][@"color"];
        NSString *attrTwoColor = dic[@"attr_two"][@"color"];

        BOOL isTwoLine = NO;
        BOOL isThreeLine = NO;
        
        _titleLabel.text = dic[@"title"];
        CGFloat strHeight = [QMLabelText calculateTextHeight:dic[@"title"] fontName:QM_PingFangSC_Reg fontSize:14.0 maxWidth:QM_kScreenWidth - 235];

        if (price.length > 0 || attrTwo.length > 0) {
            isThreeLine = YES;
            _titleLabel.numberOfLines = 1;
            _titleLabel.frame = CGRectMake(80, 15, QM_kScreenWidth - 235, 20);
        }else {
            _titleLabel.numberOfLines = 2;
            _titleLabel.frame = CGRectMake(80, 15, QM_kScreenWidth - 235, strHeight > 35 ? 35 : strHeight);
        }
        
        if (attrOne.length > 0) {
            isTwoLine = YES;
            _attrOne.text = attrOne;
//            _attrOne.frame = CGRectMake(CGRectGetMaxX(_newCardView.frame)-25, CGRectGetMaxY(_titleLabel.frame) + 5, 25, 15);
            _attrOne.textAlignment = NSTextAlignmentLeft;
        }else {
            _attrOne.text = @"";
        }
        _attrOne.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 67*2 - 30, CGRectGetMaxY(_titleLabel.frame) + 5, 30, 15);

        _attrOne.textColor = [UIColor colorWithHexString:attrOneColor.length ? attrOneColor : QMColor_666666_text];
        
        NSString *sub_Title = dic[@"sub_title"];
        if (sub_Title.length > 0) {
            _descriptionLabel.text = sub_Title;
        }else {
            _descriptionLabel.text = @"";
        }
        CGFloat subStrHeight = [QMLabelText calculateTextHeight:sub_Title fontName:QM_PingFangSC_Reg fontSize:12.0 maxWidth:QM_kScreenWidth - 255];
        if (isThreeLine && isTwoLine) {
            _descriptionLabel.numberOfLines = 1;
            _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 255, 15);
        }else if (isTwoLine && !isThreeLine) {
            _descriptionLabel.numberOfLines = 2;
            _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 255, subStrHeight > 30 ? 30 : subStrHeight);
        }else if (!isTwoLine && isThreeLine) {
            _descriptionLabel.numberOfLines = 1;
            _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 235, 15);
        }else {
            subStrHeight = [QMLabelText calculateTextHeight:sub_Title fontName:QM_PingFangSC_Reg fontSize:12.0 maxWidth:QM_kScreenWidth - 235];
            _descriptionLabel.numberOfLines = 2;
            _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 235, subStrHeight > 30 ? 30 : subStrHeight);
        }
        
        if (price.length > 0) {
            _price.text = price;
            _price.frame = CGRectMake(80, CGRectGetMaxY(_descriptionLabel.frame) + 10, 72, 15);
        }else {
            _price.text = @"";
            _price.frame = CGRectMake(80, CGRectGetMaxY(_descriptionLabel.frame), 72, 0);
        }

        if (attrTwo.length > 0) {
            _attrTwo.text = attrTwo;
//            _attrTwo.frame = CGRectMake(CGRectGetMaxX(_newCardView.frame)-50, CGRectGetMaxY(_descriptionLabel.frame) + 10, 40, 15);
        }else {
            _attrTwo.text = @"";
//            _attrTwo.frame = CGRectMake(CGRectGetMaxX(_newCardView.frame)-50, CGRectGetMaxY(_descriptionLabel.frame), 0, 0);
        }
        _attrTwo.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 67*2 - 50, CGRectGetMaxY(_descriptionLabel.frame) + 10, 40, 15);

        _attrTwo.textColor = [UIColor colorWithHexString:attrTwoColor.length ? attrTwoColor : QMColor_666666_text];

        _newCardView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 67*2, CGRectGetMaxY(_otherThree.frame) > 100 ? CGRectGetMaxY(_otherThree.frame) + 10 : 100);
        self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 67*2, CGRectGetMaxY(_otherThree.frame) > 100 ? CGRectGetMaxY(_otherThree.frame) + 10 : 100);
    }else
    {
        _titleLabel.text = dic[@"title"];
        NSString *sub_Title = dic[@"sub_title"];
        NSString *price = dic[@"price"];
        NSString *attrOne = dic[@"attr_one"][@"content"];
        NSString *attrTwo = dic[@"attr_two"][@"content"];
        NSString *itemType = dic[@"item_type"];
        if (itemType.length > 0) {
            _titleLabel.numberOfLines = 1;
            _titleLabel.frame = CGRectMake(80, 10, [UIScreen mainScreen].bounds.size.width - 225 - 60, 18);

            if (price.length > 0) {
                _price.text = price;
                _price.textAlignment = NSTextAlignmentRight;
                _price.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame), 10, 60, 18);
            }else {
                _price.text = @"";
            }

            if (sub_Title.length > 0) {
                _descriptionLabel.text = sub_Title;
                _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 40, 18);
            }else {
                _descriptionLabel.text = @"";
                _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 40, 18);
            }

            if (attrOne.length > 0) {
                _attrOne.text = attrOne;
                _attrOne.textAlignment = NSTextAlignmentRight;
                _attrOne.frame = CGRectMake(CGRectGetMaxX(_descriptionLabel.frame), CGRectGetMaxY(_titleLabel.frame) + 5, 40, 18);
                NSString *color = dic[@"attr_one"][@"color"];
                if (color.length > 0) {
                    _attrOne.textColor = [UIColor colorWithHexString:color];
                }
            }else {
                _attrOne.text = @"";
            }

            NSString *otherTitleOne = dic[@"other_title_one"];
            if (otherTitleOne.length > 0) {
                _otherOne.text = otherTitleOne;
                _otherOne.frame = CGRectMake(80, CGRectGetMaxY(_descriptionLabel.frame) + 5, [UIScreen mainScreen].bounds.size.width - 225 - 50, 16);
            }else {
                _otherOne.frame = CGRectMake(80, CGRectGetMaxY(_imageView.frame) + 10, [UIScreen mainScreen].bounds.size.width - 225 - 50, 16);
            }

            if (attrTwo.length > 0) {
                _attrTwo.text = attrTwo;
                _attrTwo.textAlignment = NSTextAlignmentRight;
                _attrTwo.frame = CGRectMake(CGRectGetMaxX(_otherOne.frame), CGRectGetMaxY(_descriptionLabel.frame) + 5, 50, 16);
                NSString *color = dic[@"attr_two"][@"color"];
                if (color.length > 0) {
                    _attrTwo.textColor = [UIColor colorWithHexString:color];
                }
            }else {
                _attrTwo.text = @"";
            }

            _newCardView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 67 * 2, 100);
            self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 67 * 2, 100);
        }else {
            CGFloat strHeight = [QMLabelText calculateTextHeight:dic[@"title"] fontName:QM_PingFangSC_Reg fontSize:14.0 maxWidth:QM_kScreenWidth - 235];
            _titleLabel.frame = CGRectMake(80, 10, QM_kScreenWidth - 235, strHeight > 35 ? 35 : strHeight);
            if (sub_Title.length > 0) {
                _descriptionLabel.text = sub_Title;
                CGFloat subStrHeight = [QMLabelText calculateTextHeight:sub_Title fontName:QM_PingFangSC_Reg fontSize:12.0 maxWidth:QM_kScreenWidth - 225];
                _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 235, subStrHeight > 30 ? 30 : subStrHeight);
            }else {
                _descriptionLabel.text = @"";
                _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, QM_kScreenWidth - 235, 15);
            }

            _newCardView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 67 * 2, CGRectGetMaxY(_otherThree.frame) > 100 ? CGRectGetMaxY(_otherThree.frame) + 10 : 100);
            self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25,QM_kScreenWidth - 67 * 2, CGRectGetMaxY(_otherThree.frame) > 100 ? CGRectGetMaxY(_otherThree.frame) + 10 : 100);
        }
        if ([message.status isEqualToString:@"0"] && [QMPushManager share].isOpenRead) {
            if ([message.isRead isEqualToString:@"1"]) {
                self.readStatus.hidden = NO;
                self.readStatus.text = @"已读";
            }else if ([message.isRead isEqualToString:@"0"]) {
                self.readStatus.hidden = NO;
                self.readStatus.text = @"未读";
            }else {
                self.readStatus.hidden = YES;
            }
            self.readStatus.frame = CGRectMake(CGRectGetMinX(self.chatBackgroundView.frame)-35, CGRectGetMaxY(self.chatBackgroundView.frame)-22, 25, 17);
        }
    }
    
    _newCardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    self.chatBackgroundView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
}

- (void)tapAction:(UITapGestureRecognizer *)gestureRecognizer {
    QMChatShowRichTextController * showWebVC = [[QMChatShowRichTextController alloc] init];
    NSString *urlStr = _cardDic[@"target_url"];
    if (urlStr.length > 0) {
        showWebVC.urlStr = urlStr;
    }else {
        return;
    }
    showWebVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showWebVC animated:true completion:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
