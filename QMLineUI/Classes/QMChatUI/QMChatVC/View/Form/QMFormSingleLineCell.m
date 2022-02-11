//
//  QMFormSingleLineCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import "QMFormSingleLineCell.h"
#import "QMChatUI.h"
@interface QMFormSingleLineCell ()<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation QMFormSingleLineCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dataDic = [[NSDictionary alloc] init];
        
        [self.contentView addSubview:self.textField];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(11);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView).offset(0);
        }];

    }
    return self;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor colorWithHexString:QMColor_151515_text];
        _textField.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _textField.delegate = self;
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = 8;
        _textField.layer.borderWidth = 0.5;
        _textField.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;
        _textField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _textField;
}

- (void)setModel:(NSDictionary *)model {
    [super setModel:model];
    
    self.dataDic = model;
    NSString *remark = model[@"remarks"];
    
    _textField.placeholder = remark.length ? remark : @"";
    
    NSString *value = model[@"value"];
    if (value.length) {
        _textField.text = value;
    }
}

#pragma mark -- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textField==%@",textField);
    NSString *value = textField.text.length ? textField.text : @"";
    
    NSMutableDictionary *newDic = self.dataDic.mutableCopy;
    [newDic setValue:value forKey:@"value"];

    self.dataDic = newDic;
    self.baseSelectValue(newDic);

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
