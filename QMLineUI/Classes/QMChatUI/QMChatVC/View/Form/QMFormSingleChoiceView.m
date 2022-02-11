//
//  QMFormSingleChoiceView.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import "QMFormSingleChoiceView.h"
#import "QMChatUI.h"
@interface QMFormSingleChoiceView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation QMFormSingleChoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.dataSource = [[NSArray alloc] init];
        self.dataDic = [[NSDictionary alloc] init];
            
        [self addSubview:self.coverView];
        [self.coverView addSubview:self.tableView];
        
        UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapPressGesture.delegate = self;
        [self addGestureRecognizer:tapPressGesture];

        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.coverView);
        }];
        
    }
    return self;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
    }
    return _coverView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[FormSingleChoiceCell class] forCellReuseIdentifier:NSStringFromClass([FormSingleChoiceCell class])];
    }
    return _tableView;
}

- (void)setModel:(NSDictionary *)model {
    if (!model.count) {
        return;
    }
    self.dataDic = model;
    self.dataSource = model[@"select"];
    
    CGFloat viewHeight = self.dataSource.count * 45;
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.tableView reloadData];
}

#pragma mark - tapPressGesture
- (void)tapAction {
    [self removeFromSuperview];
}

#pragma mark - buttonAction
- (void)backAction {
    [self removeFromSuperview];
}

#pragma mark - buttonAction
- (void)submitAction {
    NSLog(@"点击提交按钮");
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}


#pragma mark -- tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.dataSource[indexPath.row];
    FormSingleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FormSingleChoiceCell class]) forIndexPath:indexPath];
    NSString *value = self.dataDic[@"value"];
    [cell setTitle:title isSelect:[title isEqualToString:value]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tapAction];
    NSString *value = self.dataSource[indexPath.row];
    NSMutableDictionary *newDict = self.dataDic.mutableCopy;
    [newDict setValue:value forKey:@"value"];
    if (self.selectValue) {
        self.selectValue(newDict);
    }
}

@end


@implementation FormSingleChoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.selectLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-50);
            make.height.mas_equalTo(45);
        }];
        
        [self.selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView.mas_right).offset(-40);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(25);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = QMFont_Medium(15);
    }
    return _titleLabel;
}

- (UILabel *)selectLabel {
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] init];
        _selectLabel.text = @"✓";
        _selectLabel.font = QMFont_Medium(15);
        _selectLabel.textColor = [UIColor colorWithHexString:QMColor_News_Custom];
    }
    return _selectLabel;
}

- (void)setTitle:(NSString *)title isSelect:(BOOL )isSelect {
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor colorWithHexString:isSelect ? QMColor_News_Custom : QMColor_999999_text];
    self.selectLabel.hidden = !isSelect;
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
