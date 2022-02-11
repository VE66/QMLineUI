//
//  AnswerCell.m
//  segment
//
//  Created by lishuijiao on 2020/12/11.
//

#import "AnswerCell.h"
#import "QMChatUI.h"
@interface AnswerCell () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataSource;
@end

@implementation AnswerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.tableView];
//        self.tableView.layer.borderColor = UIColor.blackColor.CGColor;
//        self.tableView.layer.borderWidth = 3;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.contentView);
            make.edges.equalTo(self.contentView);
//            make.top.left.right.equalTo(self);
//            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView);
//    }];

//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self);
//        make.height.mas_equalTo(self.frame.size.height);
//    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[AnswerTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AnswerTableViewCell class])];
    }
    return _tableView;
}

- (void)setLists:(NSArray *)lists {
    self.dataSource = lists;
    
    
    CGRect rt = self.frame;
    rt.origin.y = 0;
    self.frame = rt;
    
    [_tableView reloadData];
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AnswerTableViewCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = self.dataSource[indexPath.row];
    cell.titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    [UIView drawDashLine:cell.lineView lineLength:4 lineSpacing:2 lineColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_151515_text]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectAction(self.dataSource[indexPath.row]);
}

@end


@implementation AnswerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(self.contentView.frame.size.height);
        }];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_bottom).offset(-0.5);
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(0.5);
        }];
    }
    return  self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:QMColor_151515_text];
    }
    return _lineView;
}

@end
