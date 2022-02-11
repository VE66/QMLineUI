//
//  QMChatFormCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/8.
//

#import "QMChatFormCell.h"
#import "QMChatFormView.h"
#import "QMChatRoomViewController.h"
#import "QMChatUI.h"
@implementation QMChatFormCell {
    UILabel *_promptLabel;
    
    UIButton *_nameButton;
    
    QMChatFormView *_formView;
    
    NSArray *_formInfoArr;
    
    NSDictionary *_dataDic;
    
    NSString *_title;
    
    NSString *_note;
}

- (void)createUI {
    [super createUI];
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    _promptLabel.numberOfLines = 0;
    [self.chatBackgroundView addSubview:_promptLabel];
    
    _nameButton = [[UIButton alloc] init];
    _nameButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [_nameButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom] forState:UIControlStateNormal];
    [_nameButton addTarget:self action:@selector(nameAction) forControlEvents:UIControlEventTouchUpInside];
    [self.chatBackgroundView addSubview:_nameButton];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    [super setData:message avater:avater];
    
    _promptLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    
    if ([message.fromType isEqualToString:@"1"]) {
        NSData *jsonData = [message.xbotForm dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            return;
        }
        
        _formInfoArr = [[NSArray alloc] init];
        if (dic.count) {
            _dataDic = dic;
            NSString *formPrompt = dic[@"formPrompt"];
            NSString *formName = dic[@"formName"];
            NSString *formNotes = dic[@"formNotes"];
            _title = formName;
            _note = formNotes;
            _formInfoArr = dic[@"formInfo"];
            CGSize promptSize = [QMLabelText calculateText:formPrompt fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 67*2 - 30 maxHeight:2000];
            CGSize nameSize = [QMLabelText calculateText:formName fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 67*2 - 30 maxHeight:2000];
            
            _promptLabel.text = formPrompt;
            [_nameButton setTitle:formName forState:UIControlStateNormal];
            if ([message.xbotFirst isEqualToString:@"2"]) {
                _promptLabel.frame = CGRectMake(15, 15, promptSize.width, promptSize.height);
                _nameButton.frame = CGRectZero;
                self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame) + 25, promptSize.width + 30 , promptSize.height + 30);
            }else {
                _promptLabel.frame = CGRectMake(15, 15, promptSize.width, promptSize.height);
                _nameButton.frame = CGRectMake(15, 15+promptSize.height+20, nameSize.width, nameSize.height);
                self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame) + 25, (promptSize.width - nameSize.width) > 0 ? promptSize.width + 30 : nameSize.width + 30, promptSize.height + 20 + nameSize.height + 30);
            }
            
            if ([message.xbotFirst isEqualToString:@"1"]) {
                if (self.didBtnAction) {
                    self.didBtnAction(YES);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self nameAction];
                    [QMConnect sdkUpdateFormStatus:@"0" withMessageID:message._id];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
                    
                });
            }
        }
    }
}


- (void)nameAction {
    
    if (_formView) {
        [_formView removeFromSuperview];
    }
//    eg1
    _formView = [[QMChatFormView alloc] init];
    _formView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[QMChatRoomViewController class]]) {
//            NSLog(@"hahha");
            QMChatRoomViewController *roomVC = (QMChatRoomViewController *)nextResponder;
            [roomVC.view addSubview:_formView];
            [_formView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(roomVC.view);
            }];
        }
    }
    _formView.dataDic = _dataDic;
    _formView.title = _title;
    _formView.note = _note;
    _formView.messageId = self.message._id;
    [_formView setFormInfoArr:_formInfoArr];

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
