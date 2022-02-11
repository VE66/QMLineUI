//
//  QMQuestionViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/29.
//

#import "QMQuestionViewController.h"
#import "QMQuestionSubViewController.h"
#import "QMQuestionCell.h"
#import "QMChatUI.h"

@interface QMQuestionViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *rootView;

@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) NSMutableDictionary *dataDict;
/// 当前选择的位置
@property (nonatomic, assign) NSUInteger selectSection;

@end

@implementation QMQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"button.chat_question", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    CGRect frm = self.view.bounds;
    frm.size.height = QM_kScreenHeight - kStatusBarAndNavHeight;
    self.rootView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    self.rootView.tableFooterView = [UIView new];
    self.rootView.rowHeight = 56;
    self.rootView.dataSource = self;
    self.rootView.delegate = self;
    [self.view addSubview:self.rootView];
    [self getExampleQuestionData];
    self.selectSection = 3000;
    self.dataDict = [NSMutableDictionary dictionary];
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
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ?QMColor_ECECEC_BG : QMColor_News_Custom];

    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    self.rootView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    
    [self.rootView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_id"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_id"];
    }
    
    NSDictionary *dict = self.dataArr[indexPath.row];
    QMQuestionModel *model = [[QMQuestionModel alloc] initWithDictionary:dict error:nil];

    cell.textLabel.text = model.name;
    cell.textLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    cell.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    NSDictionary *dict = self.dataArr[indexPath.row];
    QMQuestionModel *model = [[QMQuestionModel alloc] initWithDictionary:dict error:nil];

    QMQuestionSubViewController *vc = [QMQuestionSubViewController new];
    vc.backQuestion = self.backQuestion;
    vc.groupModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openMoreQuestion:(UIControl *)sender {
    UIButton *btn = (UIButton *)[sender viewWithTag:120];
    sender.selected = !sender.selected;
    btn.selected = sender.selected;
    NSInteger curTag = sender.superview.tag;
    if (curTag != self.selectSection) {
        UITableViewHeaderFooterView *lastHeader = [self.rootView headerViewForSection:self.selectSection];
        if (lastHeader) {
            UIControl *lastControl = (UIControl *)[lastHeader.contentView viewWithTag:200];
            lastControl.selected = NO;
            UIButton *lastbtn = (UIButton *)[lastControl viewWithTag:120];
            lastbtn.selected = lastControl.selected;
        }
    }
    
    if (sender.selected == YES) {
        self.selectSection = curTag;
        
        NSDictionary *dict = self.dataArr[curTag];
        NSString *cid = dict[@"_id"];
        NSArray *subArr = self.dataDict[cid];
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:curTag];
        
        if (subArr.count == 0) {
            [self getSubCommonQuestion:cid andIndexPath:index];
        } else {
            [self rootViewReloadDataAndScrollToIndexPath:index];
        }
    } else {
        self.selectSection = 3000;
        [self.rootView reloadData];
    }
    
}

- (void)rootViewReloadDataAndScrollToIndexPath:(NSIndexPath *)index {
    [self.rootView reloadData];
    [self.rootView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)senderMsg:(QMQuestionModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"sdkPullQAMsg" forKey:@"Action"];
    [dict setValue:@"getKmDetailInf" forKey:@"qaType"];
    [dict setValue:@"text" forKey:@"contentType"];
    [dict setValue:model._id forKey:@"qaItemInfoId"];
    [dict setValue:model.name forKey:@"content"];

    [QMConnect sdkGetCommonDataWithParams:dict completion:^(NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.backQuestion) {
                self.backQuestion(model);
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failure:^(NSError *error) {
        [QMRemind showMessage:NSLocalizedString(@"title.chat_question_fail", nil)];
    }];
}

- (void)getExampleQuestionData {
    [QMConnect sdkGetCommonQuestion:^(NSArray *dataArr) {
        
        self.dataArr = [dataArr copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootView reloadData];
        });
    } failure:^(NSString *error) {
        
    }];
}

- (void)getSubCommonQuestion:(NSString *)cid andIndexPath:(NSIndexPath *)index {
    
    [QMActivityView startAnimating];
    [QMConnect sdkGetSubCommonQuestionWithcid:cid completion:^(NSArray *subArr) {
        
        if (subArr.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataDict setObject:subArr forKey:cid];
                [self.rootView reloadData];
                [self.rootView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];

            });
        }
        [QMActivityView stopAnimating];
    } failure:^(NSString *error) {
        [QMActivityView stopAnimating];
    }];
}

@end
