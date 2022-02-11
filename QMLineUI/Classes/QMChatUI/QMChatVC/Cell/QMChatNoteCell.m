//
//  QMChatNoteCell.m
//  IMSDK
//
//  Created by 焦林生 on 2022/1/6.
//

#import "QMChatNoteCell.h"

@interface QMChatNoteCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *contentLabel;

@end
@implementation QMChatNoteCell

- (void)createUI {
    [super createUI];
    
    _coverView = [[UIView alloc] init];
    _coverView.QMCornerRadius = 8;
    [self.contentView addSubview:_coverView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = QMFont_Medium(17);
    [_coverView addSubview:_titleLabel];
    
    _sendButton = [[UIButton alloc] init];
    [_sendButton setTitle:NSLocalizedString(@"立即评价", nil) forState:UIControlStateNormal];
    _sendButton.QMCornerRadius = 2;
    [_sendButton setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [_sendButton setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    _sendButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
    [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_coverView addSubview:_sendButton];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    _contentLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:13];
    [_coverView addSubview:_contentLabel];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kChatLeftAndRightWidth);
        make.width.mas_equalTo(QMChatTextMaxWidth);
        make.top.equalTo(self.contentView).offset(20).priority(999);
        make.bottom.equalTo(self.contentView).offset(-10).priority(999);
    }];
        
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverView.mas_top).offset(20).priority(999);
        make.centerX.equalTo(self.coverView);
    }];
    
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.centerX.equalTo(self.coverView);
        make.width.mas_equalTo(QMFixWidth(100));
        make.height.mas_equalTo(25);
        make.bottom.equalTo(self.coverView.mas_bottom).offset(-15);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.coverView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.bottom.equalTo(self.coverView.mas_bottom).offset(-15);
    }];

}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
//    [super setData:message avater:avater];
    self.iconImage.hidden = YES;
    self.timeLabel.hidden = YES;
    self.chatBackgroundView.hidden = YES;
    
    [self setDarkStyle];
    
    [_coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kChatLeftAndRightWidth);
        make.width.mas_equalTo(QMChatTextMaxWidth);
        make.top.equalTo(self.contentView).offset(20).priority(999);
        make.height.mas_greaterThanOrEqualTo(90).priority(999);
        make.bottom.equalTo(self.contentView).offset(-10).priority(999);
    }];
    
    if ([message.evaluateStatus isEqualToString:@"2"]) {
        _titleLabel.text = NSLocalizedString(@"感谢您对本次服务做出评价", nil);
        _sendButton.hidden = YES;
        _contentLabel.hidden = NO;
        _contentLabel.text = message.message;
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.coverView);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15).priority(999);
            make.bottom.equalTo(self.coverView.mas_bottom).offset(-15).priority(999);
        }];
    } else {
        _titleLabel.text = NSLocalizedString(@"请您对本次服务做出评价", nil);
        _sendButton.hidden = NO;
        _contentLabel.hidden = YES;
        [_sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15).priority(999);
            make.centerX.equalTo(self.coverView);
            make.width.mas_equalTo(QMFixWidth(100));
            make.bottom.equalTo(self.coverView.mas_bottom).offset(-15).priority(999);
        }];
    }

}

- (void)setDarkStyle {
    
    _coverView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#02071D"];
    _contentLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#808FA6" : QMColor_News_Custom];
}

- (void)sendAction:(UIButton *)button {
    if ([self.message.evaluateStatus isEqualToString:@"0"]) {
        
        if (self.message.evaluateTimestamp.length > 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:self.message.evaluateTimestamp forKey:@"timestamp"];
            [params setValue:self.message.evaluateTimeout forKey:@"timeout"];
            [QMConnect sdkCheckImCsrTimeoutParams:params success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.noteSelected) {
                        self.noteSelected(self.message);
                    }
                });
            } failureBlock:^{
                [QMRemind showMessage:NSLocalizedString(@"title.evaluation_timeout", nil) showTime:5 andPosition:QM_kScreenHeight/2 - 10];
            }];
        }else {
            if (self.noteSelected) {
                self.noteSelected(self.message);
            }
        }
    }else if ([self.message.evaluateStatus isEqualToString:@"1"]) {
        [QMRemind showMessage:@"已评价"];
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
