//
//  QMFormBaseCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import "QMFormBaseCell.h"
#import "QMChatUI.h"
//@interface QMFormBaseCell ()
//
//
//@end

@implementation QMFormBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.flagLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(20);
            make.left.equalTo(self.contentView).offset(15);
            make.height.mas_equalTo(15);
        }];
        
        [self.flagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(20);
            make.left.equalTo(self.titleLabel.mas_right).offset(8);
            make.height.mas_equalTo(15);
        }];

    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = QMFont_Medium(15);
        _titleLabel.textColor = [UIColor colorWithHexString:QMColor_151515_text];
    }
    return _titleLabel;
}

- (UILabel *)flagLabel {
    if (!_flagLabel) {
        _flagLabel = [[UILabel alloc] init];
//        _flagLabel.text = @"*";
        _flagLabel.font = QMFont_Medium(15);
        _flagLabel.textColor = [UIColor colorWithHexString:@"#F5222D"];
    }
    return _flagLabel;
}

- (void)setModel:(NSDictionary *)model {
    int flag = [model[@"flag"] intValue];
//    BOOL flag = [dic[@"flag"] boolValue];

    _flagLabel.text = flag ? @"*" : @"";
    _titleLabel.text = model[@"name"];
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
