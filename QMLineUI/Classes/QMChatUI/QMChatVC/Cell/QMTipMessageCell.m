//
//  QMTipMessageCell.m
//  IMSDK
//
//  Created by 焦林生 on 2022/1/6.
//

#import "QMTipMessageCell.h"

@interface QMTipMessageCell ()

@property (nonatomic, strong) UILabel *customMessageLab;

@end
@implementation QMTipMessageCell

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    
    self.customMessageLab.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_666666_text];
    self.customMessageLab.text = message.message;
}

- (void)createUI {
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    
    _customMessageLab = [[UILabel alloc] init];
    _customMessageLab.textAlignment = NSTextAlignmentCenter;
    _customMessageLab.font = [UIFont fontWithName:QM_PingFangSC_Reg size:12];
    [self.contentView addSubview:_customMessageLab];
    [_customMessageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(QMFixWidth(30));
        make.right.equalTo(self.contentView).offset(-QMFixWidth(30));
        make.top.equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(18);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
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
