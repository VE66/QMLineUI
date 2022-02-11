//
//  QMChatBaseCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/19.
//

#import "QMChatBaseCell.h"

@implementation QMChatBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconImage.image = nil;
    self.chatBackgroundView.backgroundColor = nil;
    self.timeLabel.text = nil;
    self.readStatus.text = nil;
}

- (void)createUI {
    
    self.iconImage = [[UIImageView alloc] init];
    self.iconImage.backgroundColor = [UIColor clearColor];
    self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImage.QMCornerRadius = 8;
    [self.contentView addSubview:self.iconImage];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.hidden = YES;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor colorWithHexString:QMColor_666666_text];
    self.timeLabel.font = QMFONT(12);
    [self.contentView addSubview:self.timeLabel];
    
    self.chatBackgroundView = [[UIView alloc] init];
    self.chatBackgroundView.QMCornerRadius = 8;
    [self.contentView addSubview:self.chatBackgroundView];

    self.sendStatus = [[UIImageView alloc] init];
    self.sendStatus.userInteractionEnabled = YES;
    [self.contentView addSubview:self.sendStatus];

    UITapGestureRecognizer *tapResendMessage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reSendAction:)];
    [self.sendStatus addGestureRecognizer:tapResendMessage];
    
    self.readStatus = [[UILabel alloc] init];
    self.readStatus.hidden = YES;
    self.readStatus.textAlignment = NSTextAlignmentCenter;
    self.readStatus.backgroundColor = [UIColor clearColor];
    self.readStatus.textColor = [UIColor grayColor];
    self.readStatus.font = QMFONT(12);
    [self.contentView addSubview:self.readStatus];
    
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kChatIconMargin);
        make.top.equalTo(self.contentView).offset(kChatTopMargin).priority(999);
        make.width.height.mas_equalTo(kChatIconWidth);
    }];
    
    [self.chatBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kChatIconMargin);
        make.right.equalTo(self.contentView).offset(-kChatIconMargin);
        make.top.equalTo(self.iconImage.mas_top).priority(999);
        make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin);
        make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight).priority(999);
    }];
    
    [self setupTapRecognizer];

}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    
    _message = message;
    
    CGFloat topMargin = kChatTopMargin;
    if (self.timeLabel.hidden == YES) {
        self.timeLabel.frame = CGRectZero;
    }else {
        self.timeLabel.frame = CGRectMake(0, kChatTopMargin, QM_kScreenWidth, 15);
        topMargin += kChatTopMargin + 15;
    }
    
    NSString *spString = message.createdTime;
    NSDate *confromTime = [NSDate dateWithTimeIntervalSince1970:[spString integerValue]/1000];
    self.timeLabel.text = [NSString getTimeDate:confromTime timeStatus:YES];

    if ([message.fromType isEqualToString:@"0"]) {
        if ([NSURL URLWithString:avater]) {
            [self.iconImage sd_setImageWithURL:[NSURL URLWithString:avater] placeholderImage:[UIImage imageNamed:@"qm_default_user"]];
        }else {
            self.iconImage.image = [UIImage imageNamed:@"qm_default_user"];
        }
        
        [self.iconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kChatIconMargin);
            make.top.mas_equalTo(topMargin);
            make.width.height.mas_equalTo(kChatIconWidth);
        }];
        [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kChatLeftAndRightWidth);
            make.top.equalTo(self.iconImage.mas_top);
            make.width.mas_lessThanOrEqualTo(QMChatTextMaxWidth);
            make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin).priority(999);
            make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight).priority(999);
        }];
        [self.sendStatus mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.chatBackgroundView.mas_left).offset(-QMFixWidth(5));
            make.centerY.equalTo(self.chatBackgroundView);
            make.width.height.mas_equalTo(20);
        }];
      
        if ([message.status isEqualToString:@"0"] &&
            [QMPushManager share].isOpenRead) {
            if ([message.isRead isEqualToString:@"1"]) {
                self.readStatus.hidden = NO;
                self.readStatus.text = @"已读";
            }else if ([message.isRead isEqualToString:@"0"]) {
                self.readStatus.hidden = NO;
                self.readStatus.text = @"未读";
            }else {
                self.readStatus.hidden = YES;
            }
            [self.readStatus mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.chatBackgroundView.mas_left).offset(-QMFixWidth(5));
                make.bottom.equalTo(self.chatBackgroundView.mas_bottom).offset(-5);
                make.size.mas_equalTo(CGSizeMake(QMFixWidth(25), 17));
            }];
        }
        self.chatBackgroundView.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    }else {
        //接收
        if ([message.userType isEqualToString:@"system"]) {
            [self.iconImage sd_setImageWithURL:[NSURL URLWithString:[QMConnect sdkSystemMessageIcon]] placeholderImage:[UIImage imageNamed:@"qm_default_robot"]];
        }else {
            if ([NSURL URLWithString:message.agentIcon]) {
                [self.iconImage sd_setImageWithURL:[NSURL URLWithString:message.agentIcon] placeholderImage:[UIImage imageNamed:@"qm_default_agent"]];
            }else {
                if ([message.isRobot isEqualToString:@"1"]) {
                    self.iconImage.image = [UIImage imageNamed:@"qm_default_robot"];
                }else {
                    self.iconImage.image = [UIImage imageNamed:@"qm_default_agent"];
                }
            }
        }
        
        [self.iconImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kChatIconMargin);
            make.top.mas_equalTo(topMargin);
            make.width.height.mas_equalTo(kChatIconWidth);
        }];
        [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
            make.top.equalTo(self.iconImage.mas_top);
            make.width.mas_lessThanOrEqualTo(QMChatTextMaxWidth);
            make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin).priority(999);
            make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight).priority(999);
        }];
        self.chatBackgroundView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
        self.sendStatus.hidden = YES;
    }
    
    if ([message.fromType isEqualToString:@"0"]) {
        if ([message.status isEqualToString:@"0"]) {
            self.sendStatus.hidden = YES;
        }else if ([message.status isEqualToString:@"1"]) {
            self.sendStatus.hidden = NO;
            self.sendStatus.image = [UIImage imageNamed:@"qm_send_failed"];
            [self removeSendingAnimation];
        } else if ([message.status isEqualToString:@"2"]) {
            self.sendStatus.hidden = NO;
            self.sendStatus.image = [UIImage imageNamed:@"icon_sending"];
            [self showSendingAnimation];
            [[NSNotificationCenter defaultCenter] removeObserver:self]; // 防止cell重用已监听其他id
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressChange:) name:message._id object:nil];
        }
    }
}

- (void)progressChange:(NSNotification *)notfi {
    if ([notfi.name isEqualToString:_message._id]) {
        float progress = [notfi.object floatValue];
        [self setProgress:progress];
    }
}

- (void)showSendingAnimation {
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0.0;
    animation.toValue = @(2*M_PI);
    animation.duration = 1.0;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    __weak QMChatBaseCell *strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [strongSelf.sendStatus.layer addAnimation:animation forKey:@"transform.rotation.z"];
    });
}

- (void)removeSendingAnimation {
    __weak QMChatBaseCell *strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [strongSelf.sendStatus.layer removeAnimationForKey:@"transform.rotation.z"];
    });
}

- (void)setProgress: (float)progress {
    
}

- (void)setupTapRecognizer {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerAction)];
    [self.chatBackgroundView addGestureRecognizer:tapRecognizer];
}


- (void)tapRecognizerAction {
    
}

- (void)reSendAction: (UITapGestureRecognizer *)gesture {
    if ([QMPushManager share].isFinish == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_FINISH object:@"tapAction"];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"button.sendAgain", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.message.status isEqualToString:@"1"]) {

            [QMConnect resendMessage:self.message successBlock:^{
                QMLog(@"消息重发成功");
            } failBlock:^(NSString *reason){
                QMLog(@"消息重发失败");
            }];
        }
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:doneAction];
    [alert addAction:cancelAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
