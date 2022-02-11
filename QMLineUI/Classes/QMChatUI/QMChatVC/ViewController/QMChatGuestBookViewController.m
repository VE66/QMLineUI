//
//  QMChatGuestBookViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/29.
//

#import "QMChatGuestBookViewController.h"
#import "QMLeaveMessageCell.h"
#import "QMChatUI.h"
@interface QMChatGuestBookViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic ,strong) UILabel *textLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *oldFields;

@property (nonatomic, copy) NSMutableDictionary *condition;

@property (nonatomic, copy) NSString *leaveMsgString;

@property (nonatomic, assign) BOOL isSucceed;

@end

@implementation QMChatGuestBookViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    self.title = NSLocalizedString(@"title.messageBoard", nil);
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.userInteractionEnabled = true;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:NSLocalizedString(@"button.back", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithHexString:QMColor_News_Custom] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToRootVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = buttonItem;

    [self createUI];
    [self changeUserInfaceStyle];
    [self setData];
}

- (void)dealloc {
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
   [super traitCollectionDidChange:previousTraitCollection];
   if (@available(iOS 13.0, *)) {
       UIUserInterfaceStyle style = [UITraitCollection currentTraitCollection].userInterfaceStyle;
       if (!isDarkStyle) {
           [QMPushManager share].isStyle = style == UIUserInterfaceStyleDark;
           [self changeUserInfaceStyle];
       }
   }
}

- (void)changeUserInfaceStyle {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG: QMColor_News_Custom];

    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    self.titleView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : @"#E4EDF6"];
    self.titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D4D4D4_text : QMColor_News_Custom];
    self.textView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    self.textLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_FFFFFF_text];
    self.tableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    [self.tableView reloadData];
}

- (void)createUI {
    
    if (!self.isScheduleLeave) {
        NSString *title = [QMConnect leaveMessageTitle];
        self.headerTitle = title.length > 0 ? title : NSLocalizedString(@"title.messageHeader", nil);
    }
    NSString *titleString = self.headerTitle;
    CGFloat titleHeight = [QMLabelText calculateTextHeight:titleString fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:QM_kScreenWidth - 70];
    CGFloat labelHeight = titleHeight > 25 ? titleHeight : 25;
    
    self.headerView = [[UIView alloc] init];
    self.headerView.frame = CGRectMake(0, 64, QM_kScreenWidth, 45+labelHeight+40+100);
    self.headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.headerView];

    self.titleView = [[UIView alloc] init];
    self.titleView.frame = CGRectMake(15, 15, QM_kScreenWidth - 30, labelHeight + 40);
    self.titleView.layer.masksToBounds = YES;
    self.titleView.layer.cornerRadius = 7;
    [self.headerView addSubview:self.titleView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake(20.5, 18, CGRectGetWidth(self.titleView.frame) - 41, labelHeight);
    self.titleLabel.text = titleString;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [self.titleView addSubview:self.titleLabel];
    
    self.textView = [[UITextView alloc] init];
    self.textView.frame = CGRectMake(15, CGRectGetMaxY(self.titleView.frame) + 15, QM_kScreenWidth - 30, 100);
    self.textView.delegate = self;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 8;
    self.textView.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [self.headerView addSubview:self.textView];
    
    self.textLabel = [[UILabel alloc] init];
    CGFloat textHeight = [QMLabelText calculateTextHeight:self.leaveMsg ?: NSLocalizedString(@"title.pleaseLeave", nil) fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:CGRectGetWidth(self.textView.frame) - 10];
    self.textLabel.frame = CGRectMake(10, -1, CGRectGetWidth(self.textView.frame) - 10, textHeight > 90 ? 90 : textHeight+10);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_666666_text : QMColor_999999_text];
    self.textLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    self.textLabel.numberOfLines = 0;
    [self.textView addSubview:self.textLabel];

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, 100)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    UIButton *submitBtn = [[UIButton alloc] init];
    submitBtn.frame = CGRectMake(20, 25, QM_kScreenWidth - 40, 50);
    submitBtn.titleLabel.font = QMFont_Medium(18);
    submitBtn.layer.masksToBounds = YES;
    submitBtn.layer.cornerRadius = 5;
    [submitBtn setTitle:NSLocalizedString(@"title.leaving", nil) forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [submitBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    [submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:submitBtn];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-64) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = bottomView;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[QMLeaveMessageCell self] forCellReuseIdentifier:NSStringFromClass(QMLeaveMessageCell.self)];
    [self.view addSubview:self.tableView];
}

- (void)setData {
    if (!self.isScheduleLeave) {
        self.leaveMsg = [QMConnect leaveMessagePlaceholder];
        self.contactFields = [QMConnect leaveMessageContactInformation].mutableCopy;
    }
    if (self.leaveMsg.length > 0) {
        self.textLabel.text = self.leaveMsg;
    } else {
        self.textLabel.text = NSLocalizedString(@"title.pleaseLeave", nil);
    }
    self.oldFields = self.contactFields;

    [self.tableView reloadData];
}

- (void)backToRootVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tapAction {
    [self.textView resignFirstResponder];
}

- (void)submitAction:(UIButton *)button {
    if (_isSucceed) {
        [QMRemind showMessage:NSLocalizedString(@"title.isBeginLeave", nil)];
        return;
    }
    
    
    if ([self verifyRequired] && self.textView.text.length) {
        _isSucceed = YES;
        NSString *leaveString = [NSString stringWithFormat:@"留言\n%@ : %@\n%@",@"内容",self.textView.text, _leaveMsgString];
        
        __weak QMChatGuestBookViewController *weakSelf = self;
        [QMConnect sdkSubmitLeaveMessageWithInformation:self.peerId information:_condition leavemsgFields:self.oldFields message:self.textView.text successBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMConnect insertLeaveMsg:leaveString];
                [QMRemind showMessage:NSLocalizedString(@"title.messageSuccess", nil)];
                weakSelf.isSucceed = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf backToRootVC];
                });
            });
        } failBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.messageFailure", nil)];
                weakSelf.isSucceed = NO;
            });
        }];
    }
//    else {
//        [QMRemind showMessage:NSLocalizedString(@"title.messageContent", nil)];

//    }
}

- (BOOL)verifyRequired {
    _condition = [NSMutableDictionary dictionary];
    NSString *leaveString = @"";
    for (NSDictionary *dic in self.contactFields) {
        BOOL required = [[dic objectForKey:@"required"] boolValue];
        NSString *name = dic[@"name"];
        NSString *value = dic[@"value"];
        leaveString = [leaveString stringByAppendingFormat:@"%@ : %@\n", name, value];
        if (required) {
            if (value.length) {
                [_condition setValue:value forKey:dic[@"_id"]];
            }else {
                NSString *msg = [name stringByAppendingString:@"为必填项"];
                [QMRemind showMessage:msg];
                return NO;
            }
        }else {
            if (value.length) {
                [_condition setValue:value forKey:dic[@"_id"]];
            }
        }
    }
    _leaveMsgString = leaveString;
    return YES;
}

#pragma mark - Push Notification
// 键盘通知
- (void)keyboardFrameChange: (NSNotification *)notification {
    NSDictionary * userInfo =  notification.userInfo;
    NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect newFrame = [value CGRectValue];
    if (ceil(newFrame.origin.y) == [UIScreen mainScreen].bounds.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-64);
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height-64-newFrame.size.height);
        }];
    }
}

#pragma mark - textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.textLabel.text = @"";
    self.textLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.textLabel.text = (self.leaveMsg.length>0) ?self.leaveMsg: NSLocalizedString(@"title.pleaseLeave", nil);
        self.textLabel.hidden = NO;
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactFields.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMLeaveMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMLeaveMessageCell.self) forIndexPath:indexPath];
    NSMutableDictionary *dic = self.contactFields[indexPath.section];
    cell.model = dic;
    __weak typeof(self) weakSelf = self;
    cell.backValue = ^(NSString * _Nonnull value) {
        [dic setValue:value forKey:@"value"];
        [weakSelf.contactFields.mutableCopy replaceObjectAtIndex:indexPath.section withObject:dic];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_F6F6F6_BG];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

@end
