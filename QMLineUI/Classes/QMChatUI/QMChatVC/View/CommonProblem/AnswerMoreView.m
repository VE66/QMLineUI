//
//  AnswerMoreView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/12/17.
//

#import "AnswerMoreView.h"
#import "QMChatUI.h"
@interface AnswerMoreView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backButton;
@end

@implementation AnswerMoreView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dataSource = [[NSArray alloc] init];

        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.titleLabel];
        [self.bottomView addSubview:self.backButton];
        [self.bottomView addSubview:self.tableView];

        [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapPressGesture.delegate = self;
        [self addGestureRecognizer:tapPressGesture];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.bottomView);
            make.height.mas_equalTo(40);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel.mas_right).offset(-28);
            make.width.height.mas_equalTo(20);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView).offset(40);
            make.left.right.equalTo(self.bottomView);
            make.bottom.equalTo(self.bottomView.mas_bottom);
        }];

    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];

}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    }
    return _bottomView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#959595" : QMColor_333333_text];
//        _titleLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : @"#F5F5F5"];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"close_btn"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[AnswerMoreCell class] forCellReuseIdentifier:NSStringFromClass([AnswerMoreCell class])];
    }
    return _tableView;
}

- (void)setModel:(NSArray *)array andTitle:(NSString *)title {
    _dataSource = array;

    if (!array.count) {
        return;
    }
    
    self.titleLabel.text = title.length > 0 ? title : @"";
    
    CGFloat viewHeight = (array.count > 9 ? 9 : array.count) * 60 + 40;
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(QM_kScreenHeight - viewHeight);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [_tableView reloadData];
}

#pragma mark - tapPressGesture
- (void)tapAction {
    [self removeFromSuperview];
}

#pragma mark - buttonAction
- (void)backAction {
    [self removeFromSuperview];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnswerMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerMoreCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tapTableView(self.dataSource[indexPath.row]);
    [self tapAction];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end


@implementation AnswerMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLabel];
//        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.contentView);
//        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(60);
        }];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_bottom).offset(-0.5);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
        _titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_Main_Bg_Light];
    }
    return _lineView;
}

@end
