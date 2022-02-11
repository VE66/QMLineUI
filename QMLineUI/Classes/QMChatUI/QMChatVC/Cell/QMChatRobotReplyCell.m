//
//  QMChatRobotReplyCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/17.
//

#import "QMChatRobotReplyCell.h"

@interface QMChatRobotReplyCell ()

@property (nonatomic, strong) UIButton *helpBtn;
@property (nonatomic, strong) UIButton *noHelpBtn;
@property (nonatomic, strong) UILabel *lineLabel;
@property (nonatomic, strong) QMChatTextView *describeLbl;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *fingerUp;
@property (nonatomic, copy) NSString *fingerDown;
@property (nonatomic, strong) UIView *answerBgView;

@end

@implementation QMChatRobotReplyCell

- (void)createUI {
    [super createUI];
    
//    [self.chatBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
//        make.right.equalTo(self.contentView).offset(-kChatLeftAndRightWidth);
//        make.top.equalTo(self.timeLabel.mas_bottom).offset(kChatTopMargin).priority(999);
//        make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin);
//        make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight);
//    }];
    
    self.answerBgView = [UIView new];
    self.answerBgView.QMCornerRadius = 10;
    [self.contentView addSubview:self.answerBgView];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(2.5).priority(999);
        make.left.equalTo(self.chatBackgroundView).offset(8);
        make.right.equalTo(self.chatBackgroundView).offset(-8);
        make.height.mas_greaterThanOrEqualTo(40).priorityHigh();
    }];
    
    [self.answerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).priority(999);
        make.left.equalTo(self.chatBackgroundView);
        make.right.equalTo(self.chatBackgroundView);
        make.bottom.equalTo(self.chatBackgroundView).priority(999);
    }];
    
    self.helpBtn = [[UIButton alloc] init];
    [self.helpBtn setBackgroundImage:[UIImage imageNamed:@"qm_useful_nor"] forState:UIControlStateNormal];
    [self.helpBtn setBackgroundImage:[UIImage imageNamed:@"qm_useful_sel"] forState:UIControlStateSelected];
    [self.helpBtn setTitle:@"有帮助" forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.helpBtn.titleLabel.font = QMFont_Medium(13);
    [self.helpBtn addTarget:self action:@selector(helpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerBgView addSubview:self.helpBtn];
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerBgView.mas_right).offset(-169);
        make.top.equalTo(self.answerBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 35));
    }];

    self.noHelpBtn = [[UIButton alloc] init];
    [self.noHelpBtn setBackgroundImage:[UIImage imageNamed:@"qm_useless_nor"] forState:UIControlStateNormal];
    [self.noHelpBtn setBackgroundImage:[UIImage imageNamed:@"qm_useless_sel"] forState:UIControlStateSelected];
    [self.noHelpBtn setTitle:@"无帮助" forState:UIControlStateNormal];
    [self.noHelpBtn setTitleColor:[UIColor colorWithHexString:@"#F8624F"] forState:UIControlStateNormal];
    [self.noHelpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    self.noHelpBtn.titleLabel.font = QMFont_Medium(13);
    [self.noHelpBtn addTarget:self action:@selector(noHelpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerBgView addSubview:self.noHelpBtn];
    [self.noHelpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerBgView.mas_right).offset(-95);
        make.top.equalTo(self.answerBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 35));
    }];
    
    self.lineLabel = [[UILabel alloc] init];
    self.lineLabel.backgroundColor = [UIColor colorWithHexString:QMColor_999999_text];
    [self.answerBgView addSubview:_lineLabel];
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.answerBgView);
        make.top.equalTo(self.helpBtn.mas_bottom).offset(5);
        make.height.mas_equalTo(0.6);
    }];
    
    self.describeLbl = [[QMChatTextView alloc] init];
    self.describeLbl.font = QMFont_Medium(13);
    self.describeLbl.textColor = [UIColor grayColor];
    self.describeLbl.backgroundColor = [UIColor clearColor];
    self.describeLbl.textAlignment = NSTextAlignmentLeft;
    [self.answerBgView addSubview:self.describeLbl];
    [self.describeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineLabel.mas_bottom);
        make.left.equalTo(self.answerBgView).offset(5);
        make.right.equalTo(self.answerBgView).offset(-5);
        make.bottom.equalTo(self.answerBgView).offset(-5).priority(999);
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];

    [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
        make.right.equalTo(self.contentView).offset(-kChatLeftAndRightWidth);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(kChatTopMargin).priority(999);
        make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin);
        make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight);
    }];
    
    self.fingerUp = message.fingerUp.length > 0 ? message.fingerUp : NSLocalizedString(@"title.thanks_yes", nil);
    self.fingerDown = message.fingerDown.length > 0 ? message.fingerDown : NSLocalizedString(@"title.thanks_no", nil);
    
    if ([message.isRobot isEqualToString:@"1"] &&
        ![message.questionId isEqualToString:@""]) {
        [self.answerBgView setHidden:NO];
         
        if (message.isUseful) {
            [self setupStatus:message.isUseful];
        }
        else {
            [self setupStatus:@"none"];
        }
    }else {
        [self.answerBgView setHidden:YES];
    }

}

- (void)setupStatus:(NSString *)status {
    if ([status isEqualToString:@"useful"] ||
        [status isEqualToString:@"useless"]) {
        self.helpBtn.userInteractionEnabled = NO;
        self.noHelpBtn.userInteractionEnabled = NO;
        [self.lineLabel setHidden:NO];
        [self.describeLbl setHidden:NO];
        [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).priority(999);
            make.left.equalTo(self.chatBackgroundView);
            make.right.equalTo(self.chatBackgroundView);
            make.bottom.equalTo(self.chatBackgroundView).priority(999);
            make.height.mas_greaterThanOrEqualTo(75).priorityHigh();
        }];
        if ([status isEqualToString:@"useful"]) {
            
            [self.noHelpBtn setSelected:NO];
            [self.helpBtn setSelected:YES];
            self.describeLbl.text = self.fingerUp;
        }
        else {
            [self.noHelpBtn setSelected:YES];
            [self.helpBtn setSelected:NO];
            self.describeLbl.text = self.fingerDown;
        }
    }
    else {
        self.helpBtn.userInteractionEnabled = YES;
        self.noHelpBtn.userInteractionEnabled = YES;
        [self.lineLabel setHidden:YES];
        [self.describeLbl setHidden:YES];
        [self.noHelpBtn setSelected:NO];
        [self.helpBtn setSelected:NO];
        [self.answerBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).priority(999);
            make.left.equalTo(self.chatBackgroundView);
            make.right.equalTo(self.chatBackgroundView);
            make.bottom.equalTo(self.chatBackgroundView).priority(999);
        }];
    }
}

#pragma mark 机器人答案反馈点击事件
- (void)helpBtnAction: (UIButton *)sender {
    self.didBtnAction(YES);
    [self setupStatus:@"useful"];
}

- (void)noHelpBtnAction: (UIButton *)sender {
    self.didBtnAction(NO);
    [self setupStatus:@"useless"];
}

@end
