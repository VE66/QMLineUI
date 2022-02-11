//
//  QMFormCityCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/12.
//

#import "QMFormCityCell.h"
#import "QMFormCityView.h"
#import "QMChatUI.h"
@interface QMFormCityCell ()

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *arrowImage;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) QMFormCityView *cityView;

@end

@implementation QMFormCityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.dataDic = [[NSDictionary alloc] init];
        
        [self.contentView addSubview:self.selectButton];
        [self.selectButton addSubview:self.contentLabel];
        [self.selectButton addSubview:self.arrowImage];
        
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(11);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView).offset(0);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.selectButton).offset(10);
            make.left.equalTo(self.selectButton).offset(20);
            make.right.equalTo(self.selectButton).offset(-40);
            make.height.mas_equalTo(20);
        }];
        
        [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.selectButton).offset(17);
            make.left.equalTo(self.selectButton.mas_right).offset(-31);
            make.width.mas_equalTo(11);
            make.height.mas_equalTo(6);
        }];

    }
    return self;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.layer.masksToBounds = YES;
        _selectButton.layer.cornerRadius = 8;
        _selectButton.layer.borderWidth = 0.5;
        _selectButton.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;
        [_selectButton addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _contentLabel.textColor = [UIColor colorWithHexString:QMColor_151515_text];
    }
    return _contentLabel;
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [UIImage imageNamed:@"QMForm_arrow"];
    }
    return _arrowImage;
}

- (void)setModel:(NSDictionary *)model {
    [super setModel:model];
    
    self.dataDic = model;
    NSString *remark = model[@"remarks"];
    NSString *value = model[@"value"];
    if (value.length) {
        _contentLabel.text = value;
        _contentLabel.textColor = [UIColor colorWithHexString:QMColor_151515_text];
    }else {
        _contentLabel.text = remark.length ? remark : @"请选择";
        _contentLabel.textColor = remark.length ? [UIColor colorWithHexString:QMColor_151515_text] : [UIColor colorWithHexString:QMColor_999999_text];
    }
}

- (void)selectAction {

    _cityView = [[QMFormCityView alloc] init];
    _cityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _cityView.model = self.dataDic;
    [[UIApplication sharedApplication].keyWindow addSubview:_cityView];
    [_cityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    @weakify(self)
    _cityView.selectValue = ^(NSDictionary * _Nonnull dic) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setModel:dic];
            self.baseSelectValue(dic);
        });
    };
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
