//
//  QMChatCardCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/20.
//

#import "QMChatCardCell.h"

#define cardTitleMaxWidth (QM_kScreenWidth - 110 - 24 - 15)

@implementation QMChatCardCell {
    
    UIView *_cardView;
    
    UILabel *_headerLabel;
    
    UILabel *_subheadLabel;
    
    UILabel *_priceLabel;
    
    UIImageView *_imageView;
    
    UIButton *_sendButton;
    
    UILabel *_lineLabel;
}

- (void)createUI {
    [super createUI];
    
    self.iconImage.hidden = YES;
    self.chatBackgroundView.hidden = YES;

    _cardView = [[UIView alloc] init];
//    _cardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _cardView.layer.masksToBounds = YES;
    _cardView.layer.cornerRadius = 8;
    [self.contentView addSubview:_cardView];

    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(15, 15, 80, 80);
    _imageView.QMCornerRadius = 4;
    _imageView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [_cardView addSubview:_imageView];
    
    _headerLabel = [[UILabel alloc] init];
    _headerLabel.frame = CGRectMake(110, 14, cardTitleMaxWidth, 35);
    _headerLabel.font = QMFont_Medium(16);
//    _headerLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_151515_text];
    _headerLabel.numberOfLines = 2;
    [_cardView addSubview:_headerLabel];

    _subheadLabel = [[UILabel alloc] init];
    _subheadLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
//    _subheadLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#626262" : QMColor_999999_text];
    [_cardView addSubview:_subheadLabel];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor colorWithHexString:@"#F75732"];
    _priceLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [_cardView addSubview:_priceLabel];

    _lineLabel = [[UILabel alloc] init];
    _lineLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? @"#373737" : @"#CACACA"];
    [_cardView addSubview:_lineLabel];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setTitle:NSLocalizedString(@"button.send", nil) forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 25/2;
    _sendButton.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_sendButton];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    
    [super setData:message avater:avater];
    
    self.message = message;
    
    [self setDarkStyle];

    if ([message.messageType isEqualToString:@"card"]) {
        _cardView.frame = CGRectMake(12, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 24, 165);
        _cardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
        CGFloat headerHeight = 45;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:message.cardImage] placeholderImage:[UIImage imageNamed:@"qm_default_agent"]];
        
        _headerLabel.numberOfLines = 2;
        _headerLabel.text = message.cardHeader;

        headerHeight = [QMLabelText calculateTextHeight:message.cardHeader fontName:QM_PingFangSC_Med fontSize:16 maxWidth:cardTitleMaxWidth];
        _subheadLabel.text = message.cardSubhead;
        _priceLabel.text = message.cardPrice;
        
        _headerLabel.frame = CGRectMake(110, 14, cardTitleMaxWidth, headerHeight > 45 ? 45 : headerHeight);
        _subheadLabel.frame = CGRectMake(110, CGRectGetMaxY(_headerLabel.frame)+10, cardTitleMaxWidth, 13);
        _priceLabel.frame = CGRectMake(110, CGRectGetMaxY(_subheadLabel.frame)+10, cardTitleMaxWidth, 12);
        _lineLabel.frame = CGRectMake(15, 110, QM_kScreenWidth - 24 - 30, 0.5);
        _sendButton.frame = CGRectMake(QM_kScreenWidth/2-30, 125, 60, 25);
    }else if ([message.messageType isEqualToString:@"cardInfo_New"]) {
        _cardView.frame = CGRectMake(12, CGRectGetMaxY(self.timeLabel.frame)+25, QM_kScreenWidth - 24, 110);
        _cardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];

        
        NSData *jsonData = [message.cardInfo_New dataUsingEncoding:NSUTF8StringEncoding];
          NSError *err;
          NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
          if(err) {
              return;
          }
        NSDictionary *newCardInfoDic = dic;
        NSString *imgUrl = newCardInfoDic[@"img"];
        if (imgUrl && [imgUrl stringByRemovingPercentEncoding] == imgUrl) {
            imgUrl = [imgUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        [_imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
        _headerLabel.numberOfLines = 1;
        _headerLabel.text = newCardInfoDic[@"title"];

        _subheadLabel.text = newCardInfoDic[@"sub_title"];
        _priceLabel.text = @"";
        
        _headerLabel.frame = CGRectMake(110, 15, cardTitleMaxWidth, 16);
        _subheadLabel.frame = CGRectMake(110, CGRectGetMaxY(_headerLabel.frame)+12, cardTitleMaxWidth, 13);
        _sendButton.frame = CGRectMake(CGRectGetWidth(_cardView.frame) - 60 - 15, 70, 60, 25);
    }
}

- (void)setDarkStyle {
    _cardView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _headerLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_151515_text];
    _subheadLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#626262" : QMColor_999999_text];
}

- (void)sendAction: (UIButton *) button {
    if ([self.message.messageType isEqualToString:@"card"]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:self.message.cardImage forKey:@"cardImage"];
        [dic setObject:self.message.cardHeader forKey:@"cardHeader"];
        [dic setObject:self.message.cardSubhead forKey:@"cardSubhead"];
        [dic setObject:self.message.cardPrice forKey:@"cardPrice"];
        [dic setObject:self.message.cardUrl forKey:@"cardUrl"];
        
        [QMConnect sendMsgCardInfo:dic successBlock:^{
            QMLog(@"发送商品信息成功");
        } failBlock:^(NSString *reason){
            QMLog(@"发送失败");
        }];
    }else if ([self.message.messageType isEqualToString:@"cardInfo_New"]) {
        NSData *jsonData = [self.message.cardInfo_New dataUsingEncoding:NSUTF8StringEncoding];
          NSError *err;
          NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
          if(err) {
              return;
          }
        [QMConnect sendMsgCardInfo:dic successBlock:^{
            QMLog(@"发送商品信息成功");
        } failBlock:^(NSString *reason){
            QMLog(@"发送失败");
        }];
    }
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
