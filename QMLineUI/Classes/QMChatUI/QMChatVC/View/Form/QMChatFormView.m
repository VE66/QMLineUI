//
//  QMChatFormView.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import "QMChatFormView.h"
#import "QMChatUI.h"
#import "QMFormNoteCell.h"
#import "QMFormSingleLineCell.h"
#import "QMFormMultiLineCell.h"
#import "QMFormSingleChoiceCell.h"
#import "QMFormSingleChoiceView.h"
#import "QMFormMultiChoiceCell.h"
#import "QMFormDocumentCell.h"
#import "QMFormCityCell.h"
#import "QMFormDateCell.h"

@interface QMChatFormView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *formInfo;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL isReload;

@end

@implementation QMChatFormView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.formInfo = [[NSArray alloc] init];
        self.dataArray = [[NSMutableArray alloc] init];
        
        self.tag = 88;
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.titleLabel];
        [self.bottomView addSubview:self.backButton];
        [self.bottomView addSubview:self.tableView];
        [self.bottomView addSubview:self.submitButton];
        
        UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapPressGesture.delegate = self;
        [self addGestureRecognizer:tapPressGesture];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.bottomView);
            make.height.mas_equalTo(40);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel).offset(14);
            make.right.equalTo(self.titleLabel.mas_right).offset(-28);
            make.width.height.mas_equalTo(12);
        }];
        
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView).offset(40);
            make.left.right.equalTo(self.bottomView);
            make.height.mas_lessThanOrEqualTo(200);
            make.bottom.equalTo(self.bottomView).offset(-90 - kStatusBarAndNavHeight);
        }];
        
        [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView.mas_bottom).offset(-65 - kStatusBarAndNavHeight);
            make.left.equalTo(self.bottomView).offset(25);
//            make.right.equalTo(self.bottomView.mas_right).offset(-25);
            make.width.mas_equalTo(QM_kScreenWidth - 50);
            make.height.mas_equalTo(45);
//            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20);
        }];

    }
    return self;
}

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        _dataDic = [[NSDictionary alloc] init];
    }
    return _dataDic;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = UIColor.whiteColor;
    }
    return _bottomView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:QMColor_333333_text];
        _titleLabel.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"qm_common_cancel"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [UIView new];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[QMFormNoteCell class] forCellReuseIdentifier:NSStringFromClass([QMFormNoteCell class])];
        [_tableView registerClass:[QMFormSingleLineCell class] forCellReuseIdentifier:NSStringFromClass([QMFormSingleLineCell class])];
        [_tableView registerClass:[QMFormMultiLineCell class] forCellReuseIdentifier:NSStringFromClass([QMFormMultiLineCell class])];
        [_tableView registerClass:[QMFormSingleChoiceCell class] forCellReuseIdentifier:NSStringFromClass([QMFormSingleChoiceCell class])];
        [_tableView registerClass:[QMFormMultiChoiceCell class] forCellReuseIdentifier:NSStringFromClass([QMFormMultiChoiceCell class])];
        [_tableView registerClass:[QMFormDocumentCell class] forCellReuseIdentifier:NSStringFromClass([QMFormDocumentCell class])];
        [_tableView registerClass:[QMFormCityCell class] forCellReuseIdentifier:NSStringFromClass([QMFormCityCell class])];
        [_tableView registerClass:[QMFormDateCell class] forCellReuseIdentifier:NSStringFromClass([QMFormDateCell class])];
    }
    return _tableView;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] init];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_submitButton setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
        [_submitButton setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (void)setFormInfoArr:(NSArray *)formInfo {
    if (!formInfo.count) {
        return;
    }
    
    if (self.note.length) {
        NSMutableArray *array = formInfo.mutableCopy;
        [array insertObject:@{@"title":self.note, @"type":@"note"} atIndex:0];
        _formInfo = array;
    }else {
        _formInfo = formInfo;
    }
    
    self.dataArray = _formInfo.mutableCopy;
                
    self.titleLabel.text = self.title;
    CGFloat viewHeight = [self calculationHeight:formInfo] > 600 ? 600 : [self calculationHeight:formInfo];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(QM_kScreenHeight - viewHeight);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(viewHeight);
//        make.height.mas_equalTo(45*formInfo.count+40+90).priority(800);
//        make.height.mas_lessThanOrEqualTo(500).priority(900);
    }];
    
    [_tableView reloadData];
}

- (CGFloat)calculationHeight:(NSArray *)array {
    //初始高度是顶部和底部高度
    CGFloat height = 40 + 90;
    for (id item in array) {
        NSString *type = item[@"type"];
        if ([type isEqualToString:@"note"]) {
            CGFloat noteHeight = [QMLabelText calculateTextHeight:item[@"note"] fontName:QM_PingFangSC_Reg fontSize:15 maxWidth:QM_kScreenWidth - 30];
            height += noteHeight > 30 ? noteHeight : 30;
        }else if ([type isEqualToString:@"singleline"]) {
            height += 40 + 46;
        }else if ([type isEqualToString:@"multiline"]) {
            height += 40 + 46;
        }else if ([type isEqualToString:@"singlechoice"]) {
            height += 40 + 46;
        }else if ([type isEqualToString:@"multichoice"]) {
            NSArray *selectArray = item[@"select"];
            height += selectArray.count * (40 + 6) - 6 + 40;
        }else if ([type isEqualToString:@"document"]) {
            NSArray *fileList = item[@"filelist"];
            height += fileList.count ? fileList.count * 50 + 40 : 40;
        }else if ([type isEqualToString:@"city"]) {
            height += 40 + 46;
        }else if ([type isEqualToString:@"date"]) {
            height += 40 + 46;
        }
    }
    return height;
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
    QMLog(@"点击提交按钮");
    
    for (NSDictionary *dic in self.formInfo) {
        BOOL flag = [dic[@"flag"] boolValue];
        NSString *value = dic[@"value"];
        if (flag) {
            if (!value.length) {
                [QMRemind showMessage:[NSString stringWithFormat:@"%@,为必填项", dic[@"name"]]];
                return;
            }
        }
    }
    
    NSMutableDictionary *dic = self.dataDic.mutableCopy;
    
    //删除自己添加的type类型为note的数据
    NSMutableArray *array = _formInfo.mutableCopy;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"type"] isEqualToString:@"note"]) {
            [array removeObject:obj];
        }
    }];
    
    [dic setValue:array forKey:@"formInfo"];
    [dic setValue:@"提交成功!" forKey:@"text"];
    [QMConnect sdkUpdateFormStatus:@"2" withMessageID:self.messageId];
    
    [QMConnect sdkSubmitFormMessage:dic];
    
    [self tapAction];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    QMFormSingleChoiceView *singleView = (QMFormSingleChoiceView *)[[UIApplication sharedApplication].keyWindow viewWithTag:101];
    if (singleView) {
        [singleView removeFromSuperview];
    }
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
        return NO;
    }else if (touch.view.tag == 301) {
        return NO;
    }else if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITextView"]) {
        return NO;
    }
    return YES;
}

    
#pragma mark -- tableViewDelegata
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _formInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _formInfo[indexPath.row];
    
    NSString *type = dic[@"type"];
    @weakify(self)
    if ([type isEqualToString:@"note"]) {
        QMFormNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormNoteCell class]) forIndexPath:indexPath];
        cell.noteLabel.text = dic[@"title"];
        return cell;
    }else if ([type isEqualToString:@"singleline"]) {
        QMFormSingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormSingleLineCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = YES;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"multiline"]) {
        QMFormMultiLineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormMultiLineCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = YES;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"singlechoice"]) {
        QMFormSingleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormSingleChoiceCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = NO;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"multichoice"]) {
        QMFormMultiChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormMultiChoiceCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = NO;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"document"]) {
        QMFormDocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormDocumentCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = NO;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"city"]) {
        QMFormCityCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormCityCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = YES;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }else if ([type isEqualToString:@"date"]) {
        QMFormDateCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormDateCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isReload = YES;
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }
    
    return UITableViewCell.new;
}

- (void)updateDataSource:(NSDictionary *)dic withNumber:(NSInteger)number {
    [self.dataArray replaceObjectAtIndex:number withObject:dic];
    self.formInfo = self.dataArray;
    if (!self.isReload) {
        [self.tableView reloadData];
    }
}


@end
