//
//  QMChatVoiceCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/20.
//

#import "QMChatVoiceCell.h"
#import "QMAudioPlayer.h"
#import "QMAudioAnimation.h"

@interface QMChatVoiceCell() <AVAudioPlayerDelegate, MLEmojiLabelDelegate>

@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UIImageView *voicePlayImageView;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) UIImageView *completedImageView;
@property (nonatomic, strong) UILabel *secondsLabel;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) UIView *textView;
@property (nonatomic, strong) MLEmojiLabel *textLab;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *completedLabel;

@end

@implementation QMChatVoiceCell

- (void)createUI {
    [super createUI];
    
    _voiceView = [[UIView alloc] init];
    _voiceView.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    _voiceView.QMCornerRadius = 8;
    [self.chatBackgroundView addSubview:_voiceView];
    
    _voicePlayImageView = [[UIImageView alloc] init];
    _voicePlayImageView.animationDuration = 1.0;
    _voicePlayImageView.userInteractionEnabled = YES;
    [_voiceView addSubview:_voicePlayImageView];
    
    _secondsLabel = [[UILabel alloc] init];
    _secondsLabel.font = QMFONT(16);
    [_voiceView addSubview:_secondsLabel];

    _badgeView = [[UIImageView alloc] init];
    _badgeView.backgroundColor = [UIColor redColor];
    _badgeView.QMCornerRadius = 4;
    [_badgeView setHidden:YES];
//    [self.contentView addSubview:_badgeView];
    
    _textView = [[UIView alloc] init];
    _textView.QMCornerRadius = 8;
    [_textView setHidden:YES];
    [self.contentView addSubview:_textView];

    _textLab = [MLEmojiLabel new];
    _textLab.numberOfLines = 0;
    _textLab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    _textLab.lineBreakMode = NSLineBreakByTruncatingTail;
    _textLab.delegate = self;
    _textLab.disableEmoji = NO;
    _textLab.disableThreeCommon = NO;
    _textLab.isNeedAtAndPoundSign = YES;
    _textLab.customEmojiRegex = @"\\:[^\\:]+\\:";
    _textLab.customEmojiPlistName = @"expressionImage.plist";
    _textLab.customEmojiBundleName = @"QMEmoticon.bundle";
    [_textView addSubview:_textLab];

    _completedImageView = [[UIImageView alloc] init];
    _completedImageView.hidden = YES;
    [_textView addSubview:_completedImageView];
    
    _completedLabel = [[UILabel alloc] init];
    _completedLabel.text = @"转换完成";
    _completedLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    _completedLabel.hidden = YES;
    [_textView addSubview:_completedLabel];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.frame = CGRectMake(15, 10, 20, 20);
    _indicatorView.color = [UIColor grayColor];
    [_textView addSubview:_indicatorView];

    _audioSession = [AVAudioSession sharedInstance];
    
    [_voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.chatBackgroundView);
        make.height.mas_equalTo(QMChatTextMinHeight);
    }];
    
    [_voicePlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.chatBackgroundView).offset(-12);
        make.centerY.equalTo(self.chatBackgroundView);
        make.height.mas_equalTo(30);
    }];
    
    [_secondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.voicePlayImageView.mas_left);
        make.centerY.equalTo(self.voicePlayImageView);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceView.mas_bottom);
        make.left.equalTo(self.chatBackgroundView.mas_left);
        make.right.equalTo(self.chatBackgroundView.mas_right);
        make.bottom.equalTo(self.chatBackgroundView.mas_bottom);
    }];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapGesture:)];
    [self.chatBackgroundView addGestureRecognizer:longPressGesture];
    
//    UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPressGesture:)];
//    [self.chatBackgroundView addGestureRecognizer:tapPressGesture];
    
    // 默认为听筒
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    self.message = message;
    
    [self setDarkStyle];

    if ([message.fromType isEqualToString:@"0"]) {

        self.voicePlayImageView.image = [UIImage imageNamed:@"qm_chat_sendVoicePlaying"];
        
        [self.voiceView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.chatBackgroundView);
            make.height.mas_equalTo(QMChatTextMinHeight).priority(999);
        }];
        
        [self.voicePlayImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.voiceView).offset(-QMFixWidth(12));
            make.centerY.equalTo(self.voiceView);
            make.width.mas_equalTo(QMFixWidth(15));
            make.height.mas_equalTo(18);
        }];
        
        [self.secondsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.voicePlayImageView.mas_left).offset(-QMFixWidth(8)).priority(999);
            make.centerY.equalTo(self.voicePlayImageView);
            make.left.equalTo(self.voiceView);
            make.width.mas_equalTo(QMFixWidth(80));
        }];
        
        [self.readStatus mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.voiceView.mas_left).offset(-QMFixWidth(5));
            make.bottom.equalTo(self.voiceView.mas_bottom).offset(-5);
            make.size.mas_equalTo(CGSizeMake(QMFixWidth(25), 17));
        }];
        
        if ([message.status isEqualToString:@"0"]) {
            self.secondsLabel.textColor = [UIColor whiteColor];
            self.secondsLabel.text = [NSString stringWithFormat:@"%@''",message.recordSeconds];
            self.secondsLabel.textAlignment = NSTextAlignmentRight;
            self.secondsLabel.hidden = NO;
        }else {
            self.secondsLabel.hidden = YES;
        }

        [[QMAudioAnimation sharedInstance]setAudioAnimationPlay:YES and:self.voicePlayImageView];
        
//        [_badgeView setHidden:YES];
    }
    else {
        self.voicePlayImageView.image = [UIImage imageNamed:@"qm_chat_receiveVoicePlaying"];
        
        [self.voicePlayImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chatBackgroundView).offset(12);
            make.centerY.equalTo(self.chatBackgroundView);
            make.width.mas_equalTo(QMFixWidth(15));
            make.height.mas_equalTo(18);
        }];
        
        [self.secondsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.voicePlayImageView.mas_right).offset(8);
            make.centerY.equalTo(self.voicePlayImageView);
            make.right.equalTo(self.chatBackgroundView);
            make.width.mas_equalTo(QMFixWidth(80));
        }];
        
        self.secondsLabel.hidden = NO;
        self.secondsLabel.textColor = [UIColor blackColor];
        self.secondsLabel.text = [NSString stringWithFormat:@"%@''",message.recordSeconds ? message.recordSeconds : 0];
        self.secondsLabel.textAlignment = NSTextAlignmentLeft;
        
        [[QMAudioAnimation sharedInstance]setAudioAnimationPlay:NO and:self.voicePlayImageView];
        
//        CustomMessage *msg = [QMConnect getOneDataFromDatabase:message._id].firstObject;
//        if ([msg.voiceRead isEqualToString:@"1"]) {
//            [_badgeView setHidden:YES];
//        }else {
//            [_badgeView setHidden:NO];
//        }
    }
    
    NSString *fileName;
    if ([self existFile:self.message.message]) {
        fileName = self.message.message;
    }else {
        fileName = self.message._id;
    }

    if ([[QMAudioPlayer sharedInstance] isPlaying:fileName] == true) {
        [[QMAudioAnimation sharedInstance]startAudioAnimation:_voicePlayImageView];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showOrNotVoiceText];
    });
    
}

- (void)showOrNotVoiceText {
    
    NSString *voiceStatus = [QMConnect queryVoiceTextStatusWithmessageId:self.message._id];
    CGFloat X = 0;
    if ([voiceStatus isEqualToString: @"1"] && self.message.fileName.length > 0) {
        self.textView.hidden = NO;
        self.indicatorView.hidden = YES;
        self.textLab.hidden = NO;
        self.completedLabel.hidden = NO;
        self.completedImageView.hidden = NO;
        [self.indicatorView  stopAnimating];
        
        self.textLab.text = self.message.fileName;
        CGSize size = [self.textLab preferredSizeWithMaxWidth: QMChatTextMaxWidth];
        CGFloat textViewWidth = size.width + 30 > 95 ? size.width + 30 : 95;
        if ([self.message.fromType isEqualToString:@"0"]) {
            X = QM_kScreenWidth - textViewWidth - 67;
        }else {
            X = 67;
        }
        
        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.voiceView.mas_bottom).offset(5).priority(999);
            make.left.equalTo(self.chatBackgroundView.mas_left);
            make.right.equalTo(self.chatBackgroundView.mas_right);
            make.bottom.equalTo(self.chatBackgroundView.mas_bottom).priority(999);
            make.height.mas_greaterThanOrEqualTo(size.height + 50).priority(999);
        }];
        [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(QMFixWidth(10));
            make.top.mas_equalTo(13);
            make.size.mas_equalTo(CGSizeMake(size.width, size.height));
        }];
        [self.completedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(QMFixWidth(15));
            make.top.equalTo(self.textLab.mas_bottom).offset(12);
            make.width.height.mas_equalTo(12);
        }];
        [self.completedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.completedImageView.mas_right).offset(QMFixWidth(5));
            make.centerY.equalTo(self.completedImageView);
        }];
//        self.textLab.frame = CGRectMake(15, 13, size.width, size.height);
//        self.completedImageView.frame = CGRectMake(15, CGRectGetMaxY(self.textLab.frame) + 12, 12, 12);
//        self.completedLabel.frame = CGRectMake(32, CGRectGetMaxY(self.textLab.frame) + 12, 48, 12);
//        self.textView.frame = CGRectMake( X, CGRectGetMaxY(self.chatBackgroundView.frame) + 5, textViewWidth, size.height + 25 + 35);
    }
    else if ([voiceStatus isEqualToString:@"2"]) {
        self.textView.hidden = NO;
        self.indicatorView.hidden = NO;
        self.textLab.hidden = YES;
        [self.indicatorView startAnimating];
        
        if ([self.message.fromType isEqualToString:@"0"]) {
            X = QM_kScreenWidth - 125 - 67;
        }else {
            X = 67;
        }

        self.textView.frame = CGRectMake( X, CGRectGetMaxY(self.chatBackgroundView.frame) + 5, 125, 40);
    }
    
}

- (void)setDarkStyle {
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    self.textLab.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#D3D3D3" : QMColor_151515_text];
    self.completedLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#646464" : QMColor_999999_text];
    self.completedImageView.image = isDarkStyle ? [UIImage imageNamed:@"QM_VoiceFinish_icon"] : [UIImage imageNamed:@"qm_chat_completed"];
}

- (void)longPressTapGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *reciverMenu = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"button.receiver", nil) action:@selector(reciverMenu:)];
        UIMenuItem *speakerMenu = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"button.speaker", nil) action:@selector(speakerMenu:)];
        UIMenuItem *convertMenu = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"button.ConvertText", nil) action:@selector(convertMenu:)];
        UIMenuItem *removeMenu = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"button.delete", nil) action:@selector(removeMenu:)];
        NSString *voiceStatus = [QMConnect queryVoiceTextStatusWithmessageId:self.message._id];
        if ([voiceStatus isEqualToString:@"0"]) {
            [menu setMenuItems:[NSArray arrayWithObjects:reciverMenu,speakerMenu,convertMenu,removeMenu, nil]];
        }else {
            [menu setMenuItems:[NSArray arrayWithObjects:reciverMenu,speakerMenu,removeMenu, nil]];
        }
        [menu setTargetRect:self.chatBackgroundView.frame inView:self];
        [menu setMenuVisible:true animated:true];
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if ([window isKeyWindow] == NO) {
            [window becomeKeyWindow];
            [window makeKeyAndVisible];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(reciverMenu:) || action == @selector(speakerMenu:) || action == @selector(removeMenu:) || action == @selector(convertMenu:)) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)reciverMenu:(id)sendr {
    //听筒
    NSError *error = nil;
    if ([[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
    }
}

- (void)speakerMenu:(id)sender {
    // 扬声器
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
}

- (void)convertMenu:(id)sender {
    //设置消息为已读
    [QMConnect changeAudioMessageStatus:self.message._id];
    // 转文字
    [QMConnect sendMsgAudioToText:self.message successBlock:^{
        //刷新cell高度
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CUSTOMSRV_VOICETEXT object:@[self.message._id, @""]];
        });
    } failBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMRemind showMessage:NSLocalizedString(@"title.autonText_fail", nil)];
        });
    }];
}

- (void)removeMenu:(id)sender {
    // 删除语音(只能删除本地数据库消息)
    // 删除文本消息
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.prompt", nil) message:NSLocalizedString(@"title.statement", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [QMConnect removeDataFromDataBase:self.message._id];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)tapRecognizerAction {
    QMLog(@"点击语音消息");
//    [_badgeView setHidden:YES];
    [QMConnect changeAudioMessageStatus:self.message._id];
    
    [[QMAudioAnimation sharedInstance] stopAudioAnimation:nil];
    [[QMAudioAnimation sharedInstance] startAudioAnimation:self.voicePlayImageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.message.recordSeconds).intValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[QMAudioAnimation sharedInstance] stopAudioAnimation:self.voicePlayImageView];
    });
    
    NSString *fileName;
    if ([self existFile:self.message.message]) {
        fileName = self.message.message;
    }else if ([self existFile:[NSString stringWithFormat:@"%@", self.message._id]]) {
        fileName = self.message._id;
    }else {
        NSString *playUrl = [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"Documents", [NSString stringWithFormat:@"%@", self.message._id]];
        fileName = self.message._id;
        NSURL *fileUrl = [NSURL URLWithString:self.message.remoteFilePath];
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        
        [data writeToFile:playUrl atomically:YES];
    }
    
    // 目前只能发送语音消息 不能接收
    [[QMAudioPlayer sharedInstance] startAudioPlayer:fileName withDelegate:self];
}

- (BOOL)existFile: (NSString *)name {
    NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), @"Documents", name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }else {
        return NO;
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
