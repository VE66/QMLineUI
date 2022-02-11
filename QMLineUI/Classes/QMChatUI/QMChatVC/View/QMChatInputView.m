//
//  QMChatInputView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "QMChatInputView.h"
#import "QMHeader.h"
@implementation QMChatInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
        [self createView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backView.frame = CGRectMake(54, 15, QM_kScreenWidth - 54 * 2, 45);
    self.voiceButton.frame = CGRectMake(12, 22.5, 30, 30);
    self.inputView.frame = CGRectMake(13, 0, CGRectGetWidth(self.backView.frame)-30-15-20, 45);
    self.RecordBtn.frame = CGRectMake(54, 15, QM_kScreenWidth-54*2, 45);
    self.faceButton.frame = CGRectMake(CGRectGetWidth(self.backView.frame) - 30 - 7.5, 7.5, 30, 30);
    self.addButton.frame = CGRectMake(QM_kScreenWidth-30-12, 22.5, 30, 30);
    self.coverView.frame = CGRectMake(0, 0, QM_kScreenWidth, kInputViewHeight);
    //    self.inputView.frame = CGRectMake(54, 15, QM_kScreenWidth-30*2-12-19-7.5-54, 45);
    //    self.faceButton.frame = CGRectMake(QM_kScreenWidth-30*2-12-19, 22.5, 30, 30);
}

- (void)setDarkModeColor {
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
    self.backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? @"#2A2A2A" : @"#FEFEFE"];
    self.RecordBtn.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? @"#2A2A2A" : @"#FEFEFE"];
    self.inputView.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : @"#000000"];
}

- (void)createView {
    //切换语音按钮
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton.frame = CGRectMake(12, 22.5, 30, 30);
    [self.voiceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Voice"] forState:UIControlStateNormal];
    [self.voiceButton addTarget:self action:@selector(voiceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.voiceButton];

    self.backView = [[UIView alloc] init];
    self.backView.frame = CGRectMake(54, 15, QM_kScreenWidth - 54 * 2, 45);
    self.backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? @"#2A2A2A" : @"#FEFEFE"];
    self.backView.layer.cornerRadius = 45/2;
    self.backView.layer.masksToBounds = YES;
    [self addSubview:self.backView];
    
    //输入框
//    self.inputView = [[UITextView alloc] initWithFrame:CGRectMake(54, 15, QM_kScreenWidth-30*2-12-19-7.5-54, 45)];
    self.inputView = [[UITextView alloc] initWithFrame:CGRectMake(13, 0, CGRectGetWidth(self.backView.frame)-30-15-20, 45)];
    self.inputView.returnKeyType = UIReturnKeySend;
    self.inputView.delegate = self;
    self.inputView.font = [UIFont systemFontOfSize:18];
    self.inputView.backgroundColor = [UIColor clearColor];
//    self.inputView.backgroundColor = [UIColor whiteColor];
//    self.inputView.layer.cornerRadius = 45/2;
//    self.inputView.layer.masksToBounds = YES;
//    self.inputView.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.inputView.layer.borderWidth = 0.5;
    [self.backView addSubview:self.inputView];
    
    //录音按钮
    self.RecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.RecordBtn.frame = CGRectMake(54, 15, QM_kScreenWidth-54*2, 45);
    self.RecordBtn.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? @"#2A2A2A" : @"#FEFEFE"];
    self.RecordBtn.hidden = YES;
    self.RecordBtn.layer.cornerRadius = 45/2;
    self.RecordBtn.layer.masksToBounds = YES;
//    self.RecordBtn.layer.borderColor = [[UIColor grayColor] CGColor];
//    self.RecordBtn.layer.borderWidth = 0.5;
    [self.RecordBtn setTitle:NSLocalizedString(@"button.recorder_normal", nil) forState:UIControlStateNormal];
    [self.RecordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.RecordBtn setTitleColor:[UIColor colorWithRed:50/255.0f green:167/255.0f blue:255/255.0f alpha:1.0] forState:UIControlStateSelected];
    [self.RecordBtn addTarget:self action:@selector(RecordBtnCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [self.RecordBtn addTarget:self action:@selector(RecordBtnBegin:) forControlEvents:UIControlEventTouchDown];
    [self.RecordBtn addTarget:self action:@selector(RecordBtnEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.RecordBtn addTarget:self action:@selector(RecordBtnExit:) forControlEvents:UIControlEventTouchDragExit];
    [self.RecordBtn addTarget:self action:@selector(RecordBtnEnter:) forControlEvents:UIControlEventTouchDragEnter];

    self.RecordBtn.hidden = YES;
    [self addSubview:self.RecordBtn];

    //表情按钮
    self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.faceButton.frame = CGRectMake(QM_kScreenWidth-30*2-12-19, 22.5, 30, 30);
    self.faceButton.frame = CGRectMake(CGRectGetWidth(self.backView.frame) - 30 - 7.5, 7.5, 30, 30);
    self.faceButton.tag = 1;
    [self.faceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Emotion"] forState:UIControlStateNormal];
    [self.faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview: self.faceButton];
    
    //扩展功能按钮
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.frame = CGRectMake(QM_kScreenWidth-30-12, 22.5, 30, 30);
    self.addButton.tag = 3;
    [self.addButton setImage:[UIImage imageNamed:@"QM_ToolBar_Add"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.addButton];

    self.coverView = [[UIView alloc] init];
    self.coverView.frame = CGRectMake(0, 0, QM_kScreenWidth, kInputViewHeight);
    self.coverView.backgroundColor = UIColor.clearColor;
    [self.coverView setHidden:YES];
    [self addSubview:self.coverView];
}

//切换
- (void)voiceButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:100];
    }
}

//取消录音
- (void)RecordBtnCancel:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:101];
    }
}

//开始录音
- (void)RecordBtnBegin:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:102];
    }
}

//结束录音
- (void)RecordBtnEnd:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:103];
    }
}

- (void)RecordBtnExit:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:104];
    }
}

- (void)RecordBtnEnter:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:105];
    }
}

//表情
- (void)faceButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:106];
    }
}

//加号
- (void)addButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputButtonAction:index:)]) {
        [self.delegate inputButtonAction:button index:107];
    }
}

// 显示录音按钮
- (void)showRecordButton: (BOOL)show {
    if (show) {
        self.inputView.hidden = YES;
        self.RecordBtn.hidden = NO;
        [self.RecordBtn setTitle:NSLocalizedString(@"button.recorder_normal", nil) forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Keyboard"] forState:UIControlStateNormal];
        [self showEmotionView:NO];
        [self showMoreView:NO];
    }else {
        self.inputView.hidden = NO;
        self.RecordBtn.hidden = YES;
        self.inputView.inputView = nil;
        [self.voiceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Voice"] forState:UIControlStateNormal];
    }
}

// 显示表情面板
- (void)showEmotionView:(BOOL)show {
    if (show) {
        self.faceButton.tag = 2;
        [self.faceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Keyboard"] forState:UIControlStateNormal];
        [self showRecordButton:NO];
        [self showMoreView:NO];
    }else {
        self.faceButton.tag = 1;
        [self.faceButton setImage:[UIImage imageNamed:@"QM_ToolBar_Emotion"] forState:UIControlStateNormal];
    }
}

// 显示扩展面板
- (void)showMoreView:(BOOL)show {
    if (show) {
        self.addButton.tag = 4;
        [self.addButton setImage:[UIImage imageNamed:@"QM_ToolBar_Close"] forState:UIControlStateNormal];
        [self showEmotionView:NO];
        [self showRecordButton:NO];
    }else {
        self.addButton.tag = 3;
        [self.addButton setImage:[UIImage imageNamed:@"QM_ToolBar_Add"] forState:UIControlStateNormal];
        self.inputView.inputView = nil;
    }
}

@end
