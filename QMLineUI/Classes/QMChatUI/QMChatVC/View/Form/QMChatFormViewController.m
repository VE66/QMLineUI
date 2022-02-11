//
//  QMChatFormViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/13.
//

#import "QMChatFormViewController.h"

#import "QMFormSingleLineCell.h"
#import "QMFormMultiLineCell.h"
#import "QMFormSingleChoiceCell.h"
#import "QMFormSingleChoiceView.h"
#import "QMFormMultiChoiceCell.h"
#import "QMFormDocumentCell.h"
#import "QMFormCityCell.h"
#import "QMFormDateCell.h"

#import "QMFileManagerController.h"
#import "QMChatUI.h"

@interface QMChatFormViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *formInfo;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation QMChatFormViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.formInfo = [[NSArray alloc] init];
        self.dataArray = [[NSMutableArray alloc] init];
        
        [self.view addSubview:self.bottomView];
        [self.bottomView addSubview:self.titleLabel];
        [self.bottomView addSubview:self.backButton];
        [self.bottomView addSubview:self.tableView];
        [self.bottomView addSubview:self.submitButton];
        
        UITapGestureRecognizer * tapPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        tapPressGesture.delegate = self;
        [self.view addGestureRecognizer:tapPressGesture];

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
            make.bottom.equalTo(self.bottomView).offset(-90);
        }];
        
        [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomView.mas_bottom).offset(-65);
            make.left.equalTo(self.bottomView).offset(25);
//            make.right.equalTo(self.bottomView.mas_right).offset(-25);
            make.width.mas_equalTo(QM_kScreenWidth - 50);
            make.height.mas_equalTo(45);
//            make.bottom.equalTo(self.bottomView.mas_bottom).offset(-20);
        }];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        QMFileManagerController *fileVC = [[QMFileManagerController alloc] init];
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fileVC];
//        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
//        UIWindow *window=[[UIApplication sharedApplication] keyWindow];
//        UINavigationController *nav0=(UINavigationController *)window.rootViewController;
//        UIViewController *viewController = [nav0.viewControllers objectAtIndex:1];
//        [viewController.navigationController pushViewController:fileVC animated:YES];

        
        QMFileManagerController *fileViewController = [[QMFileManagerController alloc] init];
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc pushViewController:fileViewController animated:true];
        } else {
            [vc.navigationController pushViewController:fileViewController animated:true];
        }

    });
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
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [UIView new];
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


- (void)setFormInfo:(NSArray *)formInfo {
    if (!formInfo.count) {
        return;
    }
    
    _formInfo = formInfo;
    self.dataArray = _formInfo.mutableCopy;
        
    CGFloat viewHeight = [self calculationHeight:formInfo] > 500 ? 500 : [self calculationHeight:formInfo];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(QM_kScreenHeight - viewHeight);
        make.left.right.equalTo(self.view);
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
        if ([type isEqualToString:@"singleline"]) {
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
//    [self removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - buttonAction
- (void)backAction {
//    [self removeFromSuperview];
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - buttonAction
- (void)submitAction {
    NSLog(@"点击提交按钮");
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"touch.view=====%@====%ld",[touch.view class], (long)touch.view.tag);
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
    }
    return YES;
}

    
#pragma mark -- tableViewDelegata
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _formInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _formInfo[indexPath.row];
    @weakify(self)
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"singleline"]) {
        QMFormSingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormSingleLineCell class]) forIndexPath:indexPath];
        cell.model = dic;
        return cell;
    }else if ([type isEqualToString:@"multiline"]) {
        QMFormMultiLineCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormMultiLineCell class]) forIndexPath:indexPath];
        cell.model = dic;
        return cell;
    }else if ([type isEqualToString:@"singlechoice"]) {
        QMFormSingleChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QMFormSingleChoiceCell class]) forIndexPath:indexPath];
        cell.model = dic;
        
        cell.baseSelectValue = ^(NSDictionary * _Nonnull dic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.dataArray replaceObjectAtIndex:indexPath.row withObject:dic];
//                NSLog(@"self.dataArray=====%@",self.dataArray);
//                self.formInfo = self.dataArray;
//                [self.tableView reloadData];
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
                [self updateDataSource:dic withNumber:indexPath.row];
            });
        };
        return cell;
    }
    
    return UITableViewCell.new;
}

- (void)updateDataSource:(NSDictionary *)dic withNumber:(NSInteger)number {
    [self.dataArray replaceObjectAtIndex:number withObject:dic];
    NSLog(@"self.dataArray=====%@",self.dataArray);
    self.formInfo = self.dataArray;
    [self.tableView reloadData];

}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
}
@end
