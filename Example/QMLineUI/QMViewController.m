//
//  QMViewController.m
//  QMLineDemo
//
//  Created by VE66 on 02/10/2022.
//  Copyright (c) 2022 VE66. All rights reserved.
//

#import "QMViewController.h"
#import <QMLineUI/QMChatUI.h>
static NSString *kf_appkey = @"ccdb6800-ff6d-11e9-8018-cbe6b3476ac1";
static NSString *kf_name = @"AD";
static NSString *kf_userId = @"1qa2we4rf";

@interface QMViewController ()

//指示器
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
//按钮连点控制
@property (nonatomic, assign) BOOL isConnecting;

@property (nonatomic, assign) BOOL isPushed;

//注册成功返回值
@property (nonatomic, copy) NSDictionary *dictionary;
@end

@implementation QMViewController

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerSuccess:) name:CUSTOM_LOGIN_SUCCEED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerFailure:) name:CUSTOM_LOGIN_ERROR_USER object:nil];
    [self createUI];
}

- (void)createUI {
    //图片
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(QM_kScreenWidth - 190, QM_kStatusBarHeight + 44, 177, 170);
    imageView.image = [UIImage imageNamed:@"QM_Login_Welcome"];
    [self.view addSubview:imageView];
    
    //文字
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(25, QM_kStatusBarHeight + 129.5, 230, 66);
    titleLabel.text = @"容联七陌\n轻松开始客服工作";
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [UIColor colorWithHexString:@"#02071D"];
    titleLabel.font = [UIFont fontWithName:QM_PingFangTC_Sem size:28];
    [titleLabel sizeToFit];
    [self.view addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.frame = CGRectMake(25, CGRectGetMaxY(titleLabel.frame) + 14, 230, 14.5);
    subtitleLabel.text = @"视频 语言 文字 表情 图片 文件";
    subtitleLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    subtitleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [subtitleLabel sizeToFit];
    [self.view addSubview:subtitleLabel];

    //图片
    CGFloat spaceX = 20;
    CGFloat spaceY = 25;
    CGFloat imageWidth = (QM_kScreenWidth - spaceX *2 - 50)/3;
    
    NSArray *imageArray = @[@"Video", @"Voice", @"Text", @"Expression", @"Picture", @"File"];
    
    for (int i = 0; i < 6; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"QM_Login_%@",imageArray[i]]];
        imageView.frame = CGRectMake(25 + i%3*(imageWidth + spaceX), QM_kStatusBarHeight + 263.5 + i/3*(imageWidth + spaceY), imageWidth, imageWidth);
        [self.view addSubview:imageView];
    }
    
    //按钮
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(25, QM_kScreenHeight - 100, QM_kScreenWidth - 50, 50);
    button.backgroundColor = [UIColor colorWithHexString:@"#0081FF"];
    [button setTitle:@"联系客服" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Med size:18];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //指示器
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.layer.cornerRadius = 5;
    self.indicatorView.layer.masksToBounds = YES;
    self.indicatorView.frame = CGRectMake((QM_kScreenWidth-100)/2, (QM_kScreenHeight-100)/2-64, 100, 100);
    self.indicatorView.backgroundColor = [UIColor blackColor];
    self.indicatorView.color = [UIColor whiteColor];
    self.indicatorView.alpha = 0.7;
    [self.view addSubview:self.indicatorView];

    
}

- (void)buttonAction:(UIButton *)button {
    [self.indicatorView startAnimating];
    
    // 按钮连点控制
    if (self.isConnecting) {
        return;
    }
    self.isConnecting = YES;
    
    /**
     accessId:  接入客服系统的密钥， 登录web客服系统（渠道设置->移动APP客服里获取）
     userName:  用户名， 区分用户， 用户名可直接在后台会话列表显示
     userId:    用户ID， 区分用户（只能使用  数字 字母(包括大小写) 下划线 短横线）
     以上3个都是必填项
     */
    
    
//    [QMConnect setServerToCocoapods]; // 腾讯云使用
    [QMConnect registerSDKWithAppKey:kf_appkey userName:kf_name userId:kf_userId];


}

#pragma mark - notification
- (void)registerSuccess:(NSNotification *)sender {
    NSLog(@"注册成功");

    if ([QMPushManager share].selectedPush) {
        [self showChatRoomViewController:@"" processType:@"" entranceId:@""]; //
    }else{

       //  页面跳转控制
        if (self.isPushed) {
            return;
        }

        [QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dictionary = scheduleDic;
                if ([self.dictionary[@"scheduleEnable"] intValue] == 1) {
                    NSLog(@"日程管理");
                    [self starSchedule];
                }else{
                    NSLog(@"技能组");
                    [self getPeers];
                }
            });
        } failBlock:^{
            [self getPeers];
        }];
    }

    [QMPushManager share].selectedPush = NO;
}

- (void)registerFailure:(NSNotification *)sender {
    NSLog(@"注册失败::%@", sender.object);
    QMLineError *err = sender.object;
    if (err.errorDesc.length > 0) {
        [QMRemind showMessage:err.errorDesc];
    }
    self.isConnecting = NO;
    [self.indicatorView stopAnimating];
}

#pragma mark - 技能组选择
- (void)getPeers {
    [QMConnect sdkGetPeers:^(NSArray * _Nonnull peerArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *peers = peerArray;
            self.isConnecting = NO;
            [self.indicatorView stopAnimating];
            if (peers.count == 1 && peers.count != 0) {
                [self showChatRoomViewController:[peers.firstObject objectForKey:@"id"] processType:@"" entranceId:@""];
            }else {
                [self showPeersWithAlert:peers messageStr:NSLocalizedString(@"title.type", nil)];
            }
        });
    } failureBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            self.isConnecting = NO;
        });
    }];
}

#pragma mark - 日程管理
- (void)starSchedule {
    self.isConnecting = NO;
    [_indicatorView stopAnimating];
    if ([self.dictionary[@"scheduleId"] isEqual: @""] || [self.dictionary[@"processId"] isEqual: @""] || [self.dictionary objectForKey:@"entranceNode"] == nil || [self.dictionary objectForKey:@"leavemsgNodes"] == nil) {
        [QMRemind showMessage:NSLocalizedString(@"title.sorryconfigurationiswrong", nil)];
    }else{
        NSDictionary *entranceNode = self.dictionary[@"entranceNode"];
        NSArray *entrances = entranceNode[@"entrances"];
        if (entrances.count == 1 && entrances.count != 0) {
            [self showChatRoomViewController:[entrances.firstObject objectForKey:@"processTo"] processType:[entrances.firstObject objectForKey:@"processType"] entranceId:[entrances.firstObject objectForKey:@"_id"]];
        }else{
            [self showPeersWithAlert:entrances messageStr:NSLocalizedString(@"title.schedule_type", nil)];
        }
    }
}

- (void)showPeersWithAlert: (NSArray *)peers messageStr: (NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"title.type", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.isConnecting = NO;
    }];
    [alertController addAction:cancelAction];
    for (NSDictionary *index in peers) {
        UIAlertAction *surelAction = [UIAlertAction actionWithTitle:[index objectForKey:@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self.dictionary[@"scheduleEnable"] integerValue] == 1) {
                [self showChatRoomViewController:[index objectForKey:@"processTo"] processType:[index objectForKey:@"processType"] entranceId:[index objectForKey:@"_id"]];
            }else{
                [self showChatRoomViewController:[index objectForKey:@"id"] processType:@"" entranceId:@""];
            }
        }];
        [alertController addAction:surelAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 跳转聊天界面
- (void)showChatRoomViewController:(NSString *)peerId processType:(NSString *)processType entranceId:(NSString *)entranceId {
    if (!peerId.length) {
        [QMRemind showMessage:@"peerId不能为空"];
        return;
    }
    QMChatRoomViewController *chatRoomViewController = [[QMChatRoomViewController alloc] init];
    chatRoomViewController.peerId = peerId;
    chatRoomViewController.isPush = NO;
    chatRoomViewController.avaterStr = @"";
    if ([self.dictionary[@"scheduleEnable"] intValue] == 1) {
        if (!processType.length && !entranceId.length) {
            [QMRemind showMessage:@"processType和entranceId为必传参数"];
            return;
        }
        chatRoomViewController.isOpenSchedule = true;
        chatRoomViewController.scheduleId = self.dictionary[@"scheduleId"];
        chatRoomViewController.processId = self.dictionary[@"processId"];
        chatRoomViewController.currentNodeId = peerId;
        chatRoomViewController.processType = processType;
        chatRoomViewController.entranceId = entranceId;
    }else{
        chatRoomViewController.isOpenSchedule = false;
    }
    [self.navigationController pushViewController:chatRoomViewController animated:YES];
}

@end
