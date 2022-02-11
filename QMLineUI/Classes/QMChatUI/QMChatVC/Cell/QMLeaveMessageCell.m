//
//  QMLeaveMessageCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/30.
//

#import "QMLeaveMessageCell.h"
#import "QMChatUI.h"
@implementation QMLeaveMessageCell {
    UITextField *_textField;
    UIView *_backView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _backView = [[UIView alloc] init];
    _backView.frame = CGRectMake(15, 0, QM_kScreenWidth - 30, 55);
    _backView.backgroundColor = [UIColor colorWithHexString:QMColor_FFFFFF_text];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 8;
    [self.contentView addSubview:_backView];
    
    _textField = [[UITextField alloc] init];
    _textField.frame = CGRectMake(20, 0, CGRectGetWidth(_backView.frame) - 40, 55);
    _textField.layer.masksToBounds = YES;
    _textField.layer.cornerRadius = 8;
    _textField.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    _textField.textColor = [UIColor colorWithHexString:@"#151515"];
    _textField.backgroundColor = [UIColor clearColor];
    [_backView addSubview:_textField];
    [_textField addTarget:self action:@selector(change:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setModel:(NSDictionary *)model {
    NSString *value = model[@"value"];
    if (value.length > 0) {
        _textField.text = model[@"value"];
    }
    NSString *name = model[@"name"];
    _textField.placeholder = name.length > 0 ? name : @"";
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    _backView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    _textField.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    _textField.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text];
}

- (void)change: (UITextField *)textField {
    self.backValue(textField.text);
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
