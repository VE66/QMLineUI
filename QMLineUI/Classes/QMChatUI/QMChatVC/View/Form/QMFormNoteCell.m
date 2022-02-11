//
//  QMFormNoteCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/19.
//

#import "QMFormNoteCell.h"
#import "QMChatUI.h"
@implementation QMFormNoteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.noteLabel];
        [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            make.left.equalTo (self.contentView).offset(15);
            make.right.equalTo (self.contentView.mas_right).offset(-15);
        }];
    }
    return self;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
        _noteLabel.textColor = [UIColor colorWithHexString:QMColor_151515_text];
        _noteLabel.textAlignment = NSTextAlignmentLeft;
        _noteLabel.numberOfLines = 0;
    }
    return _noteLabel;
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
