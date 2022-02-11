//
//  QMChatRichTextCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/20.
//

#import "QMChatRichTextCell.h"
#import "QMChatShowRichTextController.h"

#define richViewHeight (QM_kScreenWidth - 67 * 2)

@implementation QMChatRichTextCell {
    NSString *_messageId;
    
    UIView *_richView;
    
    UILabel *_titleLabel;
    
    UILabel *_descriptionLabel;
    
    UILabel *_price;
    
    UIImageView *_imageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    _descriptionLabel.text = nil;
    _price.text = nil;
    _imageView.image = nil;
}

- (void)createUI {
    [super createUI];
    
    _richView = [[UIView alloc] init];
    _richView.backgroundColor = [UIColor whiteColor];
    _richView.frame = CGRectMake(0, 0, richViewHeight, 90);
    _richView.clipsToBounds = YES;
    _richView.layer.masksToBounds = YES;
    _richView.layer.cornerRadius = 8;
    [self.contentView addSubview:_richView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_richView addGestureRecognizer:tap];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(15, 17, richViewHeight - 75, 36);
    _titleLabel.font = QMFont_Medium(16);
//    _titleLabel.textColor = [UIColor colorWithHexString: isDarkStyle ? QMColor_D4D4D4_text : QMColor_151515_text];
    _titleLabel.numberOfLines = 2;
    [_richView addSubview:_titleLabel];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.frame = CGRectMake(10, _titleLabel.frame.size.height + 15, [UIScreen mainScreen].bounds.size.width - 250, 50);
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:12];
//    _descriptionLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#686868" : QMColor_999999_text];
    [_richView addSubview:_descriptionLabel];
    
    _price = [[UILabel alloc] init];
    _price.font = [UIFont fontWithName:QM_PingFangSC_Reg size:12];
    _price.textColor = [UIColor colorWithHexString:@"#F75732"];
    [_richView addSubview:_price];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake( _descriptionLabel.frame.size.width+20, _titleLabel.frame.size.height + 15, 60, 50);
    [_richView addSubview:_imageView];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    _messageId = message._id;
    [super setData:message avater:avater];
    _titleLabel.textColor = [UIColor colorWithHexString: isDarkStyle ? QMColor_D4D4D4_text : QMColor_151515_text];
    _descriptionLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#686868" : QMColor_999999_text];

    
    if ([message.fromType isEqualToString:@"1"]) {
        
        self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, richViewHeight, 120);
        _richView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, richViewHeight, 120);
        _titleLabel.text = message.richTextTitle;
        
        if (_titleLabel.text != nil) {
            CGFloat height = [QMLabelText calculateTextHeight:_titleLabel.text fontName:QM_PingFangSC_Med fontSize:16 maxWidth:richViewHeight - 75];

//            CGFloat height = [self calculateRowHeight:_titleLabel.text fontSize:15];
            if (height > 20) {
                _titleLabel.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 180, 40);
                _imageView.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width - 230, _titleLabel.frame.size.height + 15, 60, 50);
                _descriptionLabel.frame = CGRectMake(10, _titleLabel.frame.size.height + 15, [UIScreen mainScreen].bounds.size.width - 250, 50);
            }
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:_titleLabel.text];
            NSRange range = NSMakeRange(0, content.length);
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
            _titleLabel.attributedText = content;
        }
        _descriptionLabel.text = message.richTextDescription;
        
        if ([message.richTextPicUrl  isEqual: @""]) {
            _descriptionLabel.frame = CGRectMake(10, _titleLabel.frame.size.height + 15, [UIScreen mainScreen].bounds.size.width - 180, 50);
            _imageView.hidden = YES;
        }else{
            _descriptionLabel.frame = CGRectMake(10, _titleLabel.frame.size.height + 15, [UIScreen mainScreen].bounds.size.width - 250, 50);
            _imageView.hidden = NO;
            [_imageView sd_setImageWithURL:[NSURL URLWithString:message.richTextPicUrl] placeholderImage:[UIImage imageNamed:@""]];
        }
        [_descriptionLabel sizeToFit];
    }else {
        _richView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, richViewHeight, 80);
        self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, richViewHeight, 80);
        self.chatBackgroundView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
        self.sendStatus.frame = CGRectMake(CGRectGetMinX(self.chatBackgroundView.frame)-25, CGRectGetMinY(self.chatBackgroundView.frame)+15, 20, 20);
        
        _titleLabel.text = message.cardHeader;
        if (message.cardSubhead != nil) {
            _descriptionLabel.text = message.cardSubhead;
        }
        if (message.cardPrice != nil) {
            _price.text = message.cardPrice;
        }
        
        if ([message.cardImage  isEqual: @""]) {
            _titleLabel.frame = CGRectMake(10, 10, richViewHeight - 20, 25);
            _descriptionLabel.frame = CGRectMake(10, CGRectGetMaxY(_titleLabel.frame) + 5, richViewHeight - 20, 15);
            _price.frame = CGRectMake(10, CGRectGetMaxY(_descriptionLabel.frame) + 5, richViewHeight - 20, 15);
        }else {
            _imageView.frame = CGRectMake(10, 10, 60, 60);
            _titleLabel.frame = CGRectMake(80, 10, richViewHeight - 90, 25);
            _descriptionLabel.frame = CGRectMake(80, CGRectGetMaxY(_titleLabel.frame) + 5, richViewHeight - 90, 15);
            _price.frame = CGRectMake(80, CGRectGetMaxY(_descriptionLabel.frame) + 5,richViewHeight - 90, 15);
            _imageView.hidden = NO;
            [_imageView sd_setImageWithURL:[NSURL URLWithString:message.cardImage] placeholderImage:[UIImage imageNamed:@""]];
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
}

- (void)tapAction:(UITapGestureRecognizer *)gestureRecognizer {
    
    QMChatShowRichTextController *showWebVC = [[QMChatShowRichTextController alloc] init];
    if ([self.message.fromType isEqualToString:@"1"]) {
        showWebVC.urlStr = self.message.richTextUrl;
    }else{
        showWebVC.urlStr = self.message.cardUrl;
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
