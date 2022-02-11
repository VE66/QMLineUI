//
//  QMChatEvaluationView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/27.
//

#import "QMChatEvaluationView.h"
#import "QMChatUI.h"
@interface QMChatEvaluationView () <UITextViewDelegate>

@property (nonatomic, copy) NSArray *radioValue;

@property (nonatomic, copy) NSString *optionName;

@property (nonatomic, copy) NSString *optionValue;

@property (nonatomic, assign) CGFloat optionHeight;

@property (nonatomic, strong) UIView *textBackView;

@property (nonatomic, strong) QMEvaluats *currentEvaluate;


@end

@implementation QMChatEvaluationView

- (void)dealloc {
    NSLog(@"____%s____",__func__);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (id subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self createUI];
}

- (void)createUI {
    
    self.coverView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.coverView.backgroundColor = [UIColor colorWithHexString:QMColor_151515_text alpha:0.3];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.coverView addGestureRecognizer:tapGesture];

    if ((QM_kScreenWidth - QM_kScreenHeight) > 0) {
        self.backView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 20, QM_kScreenWidth - 60, QM_kScreenHeight - 120)];
    }else {
        self.backView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 65, QM_kScreenWidth - 60, QMFixWidth(376))];
    }
    self.backView.QMCornerRadius = 4;
    self.backView.showsVerticalScrollIndicator = false;
    self.backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    UITapGestureRecognizer *backTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.coverView addGestureRecognizer:backTapGesture];
    [self.coverView addSubview:self.backView];
    
    self.titleLabel = [[UILabel alloc] init];
    NSString *str = self.evaluation.title ?: NSLocalizedString(@"button.chat_title", nil);
    self.titleLabel.text = str;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_000000_text];
    CGFloat titleHeight = [QMLabelText calculateTextHeight:str fontName:QM_PingFangSC_Med fontSize:14 maxWidth:[UIScreen mainScreen].bounds.size.width - 180];
    self.titleLabel.frame = CGRectMake(25, 25, self.backView.frame.size.width - 50., titleHeight);

    [self.backView addSubview:self.titleLabel];

    CGFloat originX = 15;
    CGFloat originY = CGRectGetMaxY(self.titleLabel.frame)+27;
    CGFloat maxWidth = QM_kScreenWidth - 110;
    CGFloat titleMargin = 20; //圆圈宽度
    CGFloat buttonMargin = 15;//button间距
    CGFloat buttonHeight = 21;//button高度
    
    for (int i = 0; i < self.evaluation.evaluats.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:[NSString stringWithFormat:@" %@", self.evaluation.evaluats[i].name] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"qm_evaluat_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"qm_evaluat_sel"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = 100+i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                
        button.titleLabel.lineBreakMode = 0;
        CGSize size = [QMLabelText calculateText:self.evaluation.evaluats[i].name fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:maxWidth-10 maxHeight:100];
        CGFloat btnHeight = size.height > 21 ? size.height : 21;
        button.frame = CGRectMake(originX + 10, originY, size.width + titleMargin + 5, btnHeight);
        originY += btnHeight + buttonMargin;
        [self.backView addSubview:button];
    }
    
    originY = originY - buttonMargin;
    self.optionHeight = originY;
    
    self.textBackView = [[UIView alloc] initWithFrame:CGRectMake(25, originY + buttonHeight + 20, self.backView.frame.size.width - 50, 89)];
    self.textBackView.backgroundColor = [UIColor clearColor];
    self.textBackView.layer.borderWidth = 0.5;
    self.textBackView.layer.borderColor = [UIColor colorWithHexString:@"#B3B3B3"].CGColor;
    self.textBackView.layer.cornerRadius = 2;
    [self.backView addSubview:self.textBackView];
    
    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(0, 0, self.textBackView.frame.size.width, 75);
    self.textView.layer.masksToBounds = true;
    self.textView.delegate = self;
    self.textView.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_999999_text];
    self.textView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F8F8F8"];
    [self.textBackView addSubview:self.textView];
    UILabel *countLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.textBackView.frame) - 12, CGRectGetWidth(self.textView.frame) - 4, 12)];
    countLab.textAlignment = NSTextAlignmentRight;
    countLab.font = [UIFont systemFontOfSize:11];
    countLab.textColor = [UIColor colorWithHexString:QMColor_666666_text];
    countLab.text = @"120字";
    countLab.tag = 212;
    [self.textBackView addSubview:countLab];
    self.textBackView.backgroundColor = self.textView.backgroundColor;
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.backView.frame.size.width/2-117.5, CGRectGetMaxY(self.textBackView.frame)+25, 110, 40)];
    [self.sendButton setTitle:NSLocalizedString(@"button.submit.review", nil) forState:UIControlStateNormal];
    self.sendButton.QMCornerRadius = 4;
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendButton setTitleColor:[UIColor colorWithHexString:@"#FEFEFE"] forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom];
    [self.sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.sendButton];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.backView.frame.size.width/2+7.5, CGRectGetMaxY(self.textBackView.frame)+25, 110, 40)];
    [self.cancelButton setTitle:NSLocalizedString(@"button.cancel", nil) forState:UIControlStateNormal];
    self.cancelButton.QMCornerRadius = 4;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:QMColor_666666_text] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#E4E4E4"];
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.cancelButton];
    
    self.backView.contentSize = CGSizeMake(self.backView.frame.size.width, CGRectGetMaxY(self.cancelButton.frame) + 25);
    [self addSubview:self.coverView];
}

- (void)buttonAction:(UIButton *)button {
    
    [self.textView resignFirstResponder];
    
    if (button == self.selectedButton) {

    }else{
        self.selectedButton.selected = NO;
        button.selected = YES;
        self.selectedButton = button;
        [self.radioView removeFromSuperview];
        [self createReason:button.tag - 100];
        self.radioValue = @[];
    }
    
    self.currentEvaluate = self.evaluation.evaluats[button.tag - 100];
    self.optionValue = self.currentEvaluate.value;
    self.optionName = self.currentEvaluate.name;
}

- (void)createReason:(NSInteger)number {
    __weak typeof(self) weakSelf = self;
    self.optionValue = @"";
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.evaluation.evaluats.count; i++) {
        [array addObject:self.evaluation.evaluats[i].name];
    }
    
    self.radioView = [[RadioContentView alloc] initWithFrame:CGRectZero];

    [self.radioView loadData:self.evaluation.evaluats[number].reason];
    CGRect frm = self.radioView.frame;
    frm.origin.x = 25;
    frm.origin.y = self.optionHeight + 20;
    self.radioView.frame = frm;
    
    self.radioView.selectRadio = ^(NSArray * arr) {
        __strong typeof(weakSelf)sSelf = weakSelf;
        sSelf.radioValue = arr;
        [sSelf.textView resignFirstResponder];
    };
    
    [self.backView addSubview:self.radioView];
    if (self.radioView.frame.size.height == 0) {
        CGRect supFrame = self.textBackView.frame;
        supFrame.origin.y = CGRectGetMaxY(self.radioView.frame) + 5;
        self.textBackView.frame = supFrame;
    }else {
        CGRect supFrame = self.textBackView.frame;
        supFrame.origin.y = CGRectGetMaxY(self.radioView.frame) + 10;

        self.textBackView.frame = supFrame;
    }
    self.sendButton.frame = CGRectMake(self.backView.frame.size.width/2-117.5, CGRectGetMaxY(self.textBackView.frame)+25, 110, 40);
    self.cancelButton.frame = CGRectMake(self.backView.frame.size.width/2+7.5, CGRectGetMaxY(self.textBackView.frame)+25, 110, 40);
    self.backView.contentSize = CGSizeMake(self.backView.frame.size.width,  CGRectGetMaxY(self.cancelButton.frame) + 25);
}

- (void)sendAction:(UIButton *)button {
    
    if (self.optionName.length > 0) {
        if (self.currentEvaluate.labelRequired.boolValue && self.radioValue.count == 0) {
            [QMRemind showMessage:NSLocalizedString(@"title.evaluation_label", nil)];
            return;
        }
        
        if (self.currentEvaluate.proposalRequired.boolValue && self.textView.text.length == 0) {
            [QMRemind showMessage:NSLocalizedString(@"title.evaluation_reason", nil)];
            return;
        }
        [QMActivityView startAnimating];
        self.sendSelect(self.optionName, self.optionValue, self.radioValue, self.textView.text);
    }else{
        [QMRemind showMessage:NSLocalizedString(@"title.evaluation_select", nil)];
    }
}

- (void)cancelAction:(UIButton *)button {
    self.cancelSelect();
}

- (void)tapAction {
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.contentSize = CGSizeMake(self.backView.frame.size.width, CGRectGetMaxY(self.cancelButton.frame) + 25);

    }];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.contentSize = CGSizeMake(self.backView.frame.size.width, CGRectGetMaxY(self.cancelButton.frame) + 25);
    }];
    return true;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self tapAction];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 120 && text.length > 0) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *str = textView.text;
    if (str.length > 120) {
        str = [str substringToIndex:120];
    }
    UILabel *countLab = (UILabel *)[self.textBackView viewWithTag:212];
    if (countLab) {
        countLab.text = [NSString stringWithFormat:@"%ld字",(long)(120 - str.length)];
    }
}
@end


@interface RadioContentView() {
    CGFloat minWidth;
    CGFloat maxWidth;
    CGFloat buttonHeight;
    CGFloat buttonMargin;
    CGFloat titleMargin;
    int startTag;
    NSArray *_reason;
    CGFloat buttonFrameHeight;
}

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation RadioContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        minWidth = [QMLabelText calculateTextWidth:@"宽度" fontName:QM_PingFangSC_Med fontSize:14 maxHeight:0] + 2 * 10;
        maxWidth = QM_kScreenWidth - 110;
        buttonHeight = 24;
        buttonMargin = 12;
        titleMargin = 10;
        startTag = 700;
        buttonFrameHeight = 0;
    }
    return self;
}

- (void)loadData:(NSArray *)reason {
    _reason = reason;
    
    self.selectedArray = [[NSMutableArray alloc] init];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat height = 0;
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i < reason.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.layer.cornerRadius = 2;
        button.layer.masksToBounds = true;
        button.tag = startTag + i;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:reason[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F8F8F8"]];
        [button setTitleColor: [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_News_Custom] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        button.titleLabel.lineBreakMode = 0;
        CGSize size = [QMLabelText calculateText:reason[i] fontName:QM_PingFangSC_Med fontSize:14 maxWidth:QM_kScreenWidth - 120 maxHeight:100];
        buttonHeight = size.height > 24 ? size.height : 24;

        button.frame = CGRectMake(originX, originY, QM_kScreenWidth - 120, buttonHeight);
        originY += buttonHeight + buttonMargin;
        
        height = CGRectGetMaxY(button.frame);
    }
    CGRect frm = self.frame;
    frm.size.width = maxWidth;
    frm.size.height = height;
    self.frame = frm;
}

- (void)selectAction:(UIButton *)button {
    if (button.selected) {
        button.selected = NO;
        [button setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F8F8F8"]];
        if ([self.selectedArray containsObject:button.titleLabel.text]) {
            [self.selectedArray removeObject:button.titleLabel.text];
        }
    }else{
        button.selected = YES;
        [button setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? @"#0084FF" : @"#ECF6FF"]];
        if (![self.selectedArray containsObject:button.titleLabel.text]) {
            [self.selectedArray addObject:button.titleLabel.text];
        }
    }
        
    self.selectRadio(self.selectedArray);
}

@end
