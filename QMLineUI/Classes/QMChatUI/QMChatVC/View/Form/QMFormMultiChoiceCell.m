//
//  QMFormMultiChoiceCell.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/12.
//

#import "QMFormMultiChoiceCell.h"
#import "QMChatUI.h"
@interface QMFormMultiChoiceCell ()

@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) NSMutableArray *finalArray;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSArray *selectArray;

@end

@implementation QMFormMultiChoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.finalArray = [[NSMutableArray alloc] init];
        self.dataDic = [[NSDictionary alloc] init];
        self.selectArray = [[NSArray alloc] init];

        [self.contentView addSubview:self.coverView];
    }
    return self;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor whiteColor];
        _coverView.tag = 301;
    }
    return _coverView;
}

- (void)setModel:(NSDictionary *)model {
    [super setModel:model];
    
    self.dataDic = model;
    NSString *value = model[@"value"];
    if (value.length) {
        self.selectArray = [value componentsSeparatedByString:@","];
    }else {
        self.selectArray = @[];
    }
    NSArray *selectArray = model[@"select"];

    CGFloat viewHeight = selectArray.count * (40 + 6) - 6;
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(11);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(viewHeight);
        make.bottom.equalTo(self.contentView).offset(0);
    }];
    
    for (id item in self.coverView.subviews) {
        if ([item isKindOfClass:[UIButton class]]) {
            [item removeFromSuperview];
        }
    }
        
    [self createButton:selectArray];
}

- (void)createButton:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = 200 + i;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 8;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor colorWithHexString:@"#CACACA"].CGColor;
        button.backgroundColor = UIColor.whiteColor;
        button.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [button setImage:[UIImage imageNamed:@"QMForm_select_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"QMForm_select_sel"] forState:UIControlStateSelected];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:QMColor_999999_text] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(senderAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.selectArray containsObject:array[i]]) {
            button.selected = YES;
            button.layer.borderColor = [UIColor colorWithHexString:button.selected ? QMColor_News_Custom : QMColor_999999_text].CGColor;
            button.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom alpha:0.1];
        }

        [self.coverView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.coverView).offset(46*i);
            make.left.right.equalTo(self.coverView);
            make.height.mas_equalTo(40);
        }];
    }
}

- (void)senderAction:(UIButton *)button {
    if (button.selected) {
        if ([self.finalArray containsObject:button.titleLabel.text]) {
            [self.finalArray removeObject:button.titleLabel.text];
        }
        button.backgroundColor = UIColor.whiteColor;
    }else{
        if (![self.finalArray containsObject:button.titleLabel.text]) {
            [self.finalArray addObject:button.titleLabel.text];
        }
        button.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom alpha:0.1];
    }
    button.selected = !button.selected;
    button.layer.borderColor = [UIColor colorWithHexString:button.selected ? QMColor_News_Custom : QMColor_999999_text].CGColor;
        
    NSString *value = [self.finalArray componentsJoinedByString:@","];
    
    NSMutableDictionary *dic = self.dataDic.mutableCopy;
    [dic setValue:value forKey:@"value"];
    if (self.baseSelectValue) {
        self.baseSelectValue(dic);
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
