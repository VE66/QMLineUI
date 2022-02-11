//
//  QMFormMultiLineCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import "QMFormMultiLineCell.h"
#import "QMChatUI.h"
@interface QMFormMultiLineCell ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation QMFormMultiLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.dataDic = [[NSDictionary alloc] init];

        [self.contentView addSubview:self.textView];
        
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(11);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView).offset(0);
        }];
    }
    return self;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.textColor = [UIColor colorWithHexString:QMColor_151515_text];
        _textView.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _textView.delegate = self;
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 8;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;

    }
    return _textView;
}

- (void)setModel:(NSDictionary *)model {
    [super setModel:model];
    
    self.dataDic = model;
    NSString *value = model[@"value"];
    NSString *remark = model[@"remarks"];
    if (value.length) {
        _textView.text = value;
    }else {
        _textView.text = remark.length ? remark : @"";
        _textView.textColor = [UIColor colorWithHexString:QMColor_999999_text];
    }

}

#pragma mark -- UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    _textView.textColor = [UIColor colorWithHexString:QMColor_151515_text];
    NSString *value = self.dataDic[@"value"];
    if (!value.length) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    NSString *value = textView.text.length ? textView.text : @"";
    NSMutableDictionary *newDic = self.dataDic.mutableCopy;
    [newDic setValue:value forKey:@"value"];
    self.dataDic = newDic;
    if (self.baseSelectValue) {
        self.baseSelectValue(newDic);
    }
    if (textView.text.length == 0) {
        NSString *remark = self.dataDic[@"remarks"];
        if (remark.length > 0) {
            self.textView.text = remark;
            _textView.textColor = [UIColor colorWithHexString:QMColor_999999_text];
        }
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
