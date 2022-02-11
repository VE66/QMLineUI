//
//  QMChatRoomViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/9/28.
//

#import "QMChatRoomViewController.h"
#import "QMChatGuestBookViewController.h"
#import "QMFileManagerController.h"
#import "QMQuestionViewController.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QMChatUI.h"

#import "QMChatShowRichTextController.h"
#import "QMChatRoomViewController+TableView.h"
#import "QMChatRoomViewController+ChatMessage.h"

//view
#import "QMChatTitleView.h"
#import "QMChatInputView.h"
#import "QMChatMoreView.h"
#import "QMChatFaceView.h"
#import "QMRecordIndicatorView.h"
#import "QMChatBottomListView.h"
#import "QMChatAssociationInputView.h"
#import "QMChatEvaluationView.h"
#import "QMChatFormView.h"
#import "QMLogistsMoreView.h"

@interface QMChatRoomViewController () < UITextViewDelegate, inputeViewDelegate, faceViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, QMAudioRecorderDelegate> {
    
    NSArray * _dataArray;

    CGFloat _navHeight;
    NSString *_titleViewText;
    CGRect keyBoardFrame; // 键盘位置
    NSTimer *breakTimer;
    NSTimer *breakTipTimer;
    NSTimer *backStatus;
    NSString *_intelligentRobot; //智能机器人id
    NSArray *_questions; //xbot联想问题
    NSArray *_cateIdArr; //xbot机器人cateId
    NSString *evaluateOperation; //评价携带字段
    NSString *_beginChatID; //beginNewChat返回的chatID
    long dateTime;
    int _dataNum;
    BOOL isRemark;
    BOOL isBottomShow; //xbot底部推荐
    BOOL keyboardIsShow; //键盘是否展示
    BOOL isShowAssociatsInput; //是否开启联想输入
    BOOL isShowEvaluate; //满意度评价按钮
    BOOL alreadEvaluate; //是否已经评价过(机器人和人工共用一个)
    BOOL isShowEvaluateView; //满意度view 是否展示
    BOOL isShowEvaluateBtn; //人工之后的满意度按钮是否展示
    BOOL isFinish; //是否结束会话
    BOOL isOpenRead; //是否开启消息已读未读
    BOOL isClaim; //会话是否被人工客服领取
    BOOL isShowAssociatsWithAgent; //人工状态下是否开启联想输入
}
/**访客无响应断开时长*/
@property (nonatomic, assign) NSInteger breakDuration;
/**断开前提示时长*/
@property (nonatomic, assign) NSInteger breakTipsDuration;
/**标题*/
@property (nonatomic, strong) QMChatTitleView *titleView;
/**转人工*/
@property (nonatomic, strong) UIButton *manualButotn;
/**注销*/
@property (nonatomic, strong) UIButton *logoutButton;
/**日程管理*/
@property (nonatomic, copy) NSDictionary *scheduleDic;
/**满意度*/
@property (nonatomic, strong) QMEvaluation *evaluation;
/**人工满意度评价*/
@property (nonatomic, strong) QMChatEvaluationView *evaluationView;
/**xbot底部推荐*/
@property (nonatomic, strong) QMChatBottomListView *bottomView;
/**未开启留言提示*/
@property (nonatomic, copy) NSString *msg;
/**遮罩*/
@property (nonatomic, strong) UIView *tapCoverView;
/**当前坐席*/
@property (nonatomic, strong) QMAgent *currentAgent;
/**线程锁*/
@property (nonatomic, strong) NSRecursiveLock *dataLock;

@end

@implementation QMChatRoomViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewReload:) name:CHATMSG_RELOAD object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(robotAction) name:ROBOT_SERVICE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customOnline) name:CUSTOMSRV_ONLINE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customOffline) name:CUSTOMSRV_OFFLINE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customClaim) name:CUSTOMSRV_CLAIM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customFinish:) name:CUSTOMSRV_FINISH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customQueue:) name:CUSTOMSRV_QUEUENUM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customAgentMessage:) name:CUSTOMSRV_AGENT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customInvestigate:) name:CUSTOMSRV_INVESTIGATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVIP) name:CUSTOMSRV_VIP object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customLeavemsg:) name:CUSTOMSRV_LEAVEMSG object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCustomStatus) name:CUSTOMSRV_IMPORTING object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cbangeDrowMessageStatus:) name:CUSTOMSRV_DRAWMESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customSatisfaction:) name:CUSTOMSRV_SATISFACTION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customAssociatsInput:) name:CUSTOMSRV_ASSOCIATSINPUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVoiceMessage:) name:CUSTOMSRV_VOICETEXT object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    
    NSArray *array = [QMConnect sdkGetAgentMessageWithIsRead];
    [QMConnect sdkDealImMsgWithMessageID:array];
    
    [self changeUserInfaceStyle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isPush == NO) {
        [self beginNewChat:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVideoInvite:) name:CUSTOMSRV_VIDEO_INVITE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customVideoCancel:) name:CUSTOMSRV_VIDEO_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadImageAction:) name:@"qm_downImageCompleted" object:nil];

    [self OpenDarkStyle:self.darkStyle];
    
    keyBoardFrame = CGRectZero;

    [QMActivityView startAnimating];
    
    [QMPushManager share].isOpenRead = [QMConnect sdkWhetherToOpenReadAndUnread];

    [self createUI];
    
    [self createCoverView];
    
    [self insertCardInfoMessage];
    
    [self insertNewCardInfoMessage];
    
    [self getInvestigateData];
    
    if (_dataNum == 0) {
        _dataNum = 10;
    }
    dateTime = 0;
    [QMConnect changeVoiceTextShowoOrNot:@"0" message:@"all"];

    [self getData];
    
    [self scrollToEnd];
    
    [self createNSTimer];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.peerId];
    
    [self questionBtnStatus];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.chatInputView.inputView isFirstResponder]) {
        [self.chatInputView.inputView resignFirstResponder];
        self.chatInputView.inputView.inputView = nil;
        [self.chatInputView showMoreView:NO];
    }
}

- (void)dealloc {
    [QMConnect changeAllCardMessageHidden];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.peerId];
}

 - (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = [UITraitCollection currentTraitCollection].userInterfaceStyle;
        [QMPushManager share].isStyle = style == UIUserInterfaceStyleDark;
        [self OpenDarkStyle:self.darkStyle];
    }
}

- (void)OpenDarkStyle:(QMDarkStyle)style {

    if (style == QMDarkStyleOpen) {
        [QMPushManager share].isStyle = YES;
    } else if (style == QMDarkStyleClose) {
        [QMPushManager share].isStyle = NO;
    } else {
        [self changeUserInfaceStyle];
    }
}

- (void)changeUserInfaceStyle {
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom];
    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    self.chatTableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    UIColor *commonColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
    self.chatInputView.backgroundColor = commonColor;
    self.addView.backgroundColor = commonColor;
    self.faceView.backgroundColor = commonColor;
    
    [self.titleView setDarkModeColor];
    [self.chatInputView setDarkModeColor];
    [self.bottomView setDarkModeColor];
    [self.chatTableView reloadData];
}

#pragma mark -------- setupMainUI ----------
- (void)createUI {
    if (@available(iOS 11.0, *)){
        [self.chatTableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect NavRect = self.navigationController.navigationBar.frame;
    _navHeight = StatusRect.size.height + NavRect.size.height;
        
    // 坐席信息提示
    _titleView = [[QMChatTitleView alloc] initWithFrame: CGRectMake(0, 0, 150, 40)];
    _titleView.nameLabel.text = NSLocalizedString(@"title.people", nil);
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.connection", nil);
    _titleView.intrinsicContentSize = CGSizeMake(150, 40);
    self.navigationItem.titleView = _titleView;
    
    // 消息列表
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kInputViewHeight-_navHeight) style:UITableViewStylePlain];
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    self.chatTableView.estimatedRowHeight = 80;
    [self.view addSubview:self.chatTableView];
    
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.chatTableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;

    //输入工具条
    self.chatInputView = [[QMChatInputView alloc] initWithFrame:CGRectMake(0, QM_kScreenHeight-kInputViewHeight-_navHeight, QM_kScreenWidth, kInputViewHeight)];
    self.chatInputView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.chatInputView.coverView addGestureRecognizer:tapGesture];
    [self.chatInputView.coverView setHidden:YES];
    [QMPushManager share].isFinish = NO;
    self.chatInputView.inputView.delegate = self;
    [self.view addSubview:self.chatInputView];
    
    // 表情面板
    self.faceView = [[QMChatFaceView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, QM_kScreenWidth, QM_IS_iPHONEX ? 250 : 216)];
    self.faceView.delegate = self;

    CGFloat addViewHeight = QM_IS_iPHONEX ? 144 : 110;
    
    addViewHeight = [QMConnect sdkVideoRights] ? (addViewHeight + 96) : addViewHeight;
    // 扩展面板
    self.addView = [[QMChatMoreView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, QM_kScreenWidth, addViewHeight)];
    [self.addView.takePicBtn addTarget:self action:@selector(takePicBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.addView.evaluateBtn addTarget:self action:@selector(evaluateBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.addView.takeFileBtn addTarget:self action:@selector(takeFileBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.addView.videoBtn addTarget:self action:@selector(takeVideoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.addView.evaluateBtn.hidden = YES;
    [self.addView.questionBtn addTarget:self action:@selector(openQuestionView) forControlEvents:UIControlEventTouchUpInside];

    //xbot底部推荐
    self.bottomView = [[QMChatBottomListView alloc] initWithFrame:CGRectMake(0, QM_kScreenHeight-kInputViewHeight-_navHeight - 52, QM_kScreenWidth, 52)];
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];

    //录音动画面板
    self.recordeView = [[QMRecordIndicatorView alloc] init];
    self.recordeView.frame = CGRectMake((QM_kScreenWidth-150)/2, (QM_kScreenHeight-150-_navHeight-50)/2, 150, 150);
    
    __weak QMChatRoomViewController * myChatView = self;
    MJRefreshNormalHeader *mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [myChatView refresh];
    }];
    [mj_header.lastUpdatedTimeLabel setHidden:true];
    self.chatTableView.mj_header = mj_header;

    // 转人工
    self.manualButotn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.manualButotn.frame = CGRectMake(0, 0, 60, 30);
    self.manualButotn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [self.manualButotn setTitle: NSLocalizedString(@"button.topeople", nil) forState:UIControlStateNormal];
    [self.manualButotn addTarget:self action:@selector(customClick:) forControlEvents:UIControlEventTouchUpInside];
    self.manualButotn.hidden = YES;
    if (self.isOpenSchedule) {
        self.isRobot = true;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.manualButotn];
    }else {
        if ([QMConnect allowRobot]) {
            self.isRobot = true;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.manualButotn];
        }else {
            self.isRobot = false;
        }
    }
    
    // 注销
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logoutButton.frame = CGRectMake(0, 0, 50, 30);
    self.logoutButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    [self.logoutButton setTitle:NSLocalizedString(@"button.logout", nil) forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.logoutButton];
}

- (void)createCoverView {
    self.coverView = [[UIView alloc] init];
    self.coverView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight);
    self.coverView.backgroundColor = [UIColor colorWithHexString:QMColor_151515_text alpha:0.3];
    [self.view addSubview:self.coverView];
}

#pragma mark ----- 获取数据(数据模型已存储本地) -----
// 获取消息数据
- (void)getData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.dataArray = [QMConnect getDataFromDatabase:self->_dataNum];
        [self.chatTableView reloadData];
        
    });
}

// 下拉刷新
- (void)refresh {
    if (_dataNum>self.dataArray.count) {
        [self.chatTableView.mj_header endRefreshing];
        return;
    }
    _dataNum = _dataNum+10;
    
    [self getData];
    
    [self.chatTableView.mj_header endRefreshing];
}

// 刷新TableView
-(void)reloadTableView {
    
    if (_titleViewText != nil) {
        _titleView.stateInfoLabel.text = _titleViewText;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatTableView reloadData];
        [self scrollToEnd];
    });
}

// 滑动到底部
- (void)scrollToEnd {
    if (self.dataArray.count>0) {
        NSInteger count = [self.chatTableView numberOfRowsInSection:0];
        if (count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
            [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    }
}

// 获取后台配置信息 、 满意度调查 、回复超时时间
- (void)getInvestigateData {
    [QMConnect newSDKGetInvestigate:^(QMEvaluation * _Nonnull evaluation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.evaluation = evaluation;
        });
    } failureBlock:^{
      
    }];
}

- (void)loadImageAction:(NSNotification *)notif {
    NSString *messageId = (NSString *)notif.object;
    if (self.dataArray.count > 0) {
        [self.dataArray enumerateObjectsUsingBlock:^(CustomMessage *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj._id isEqualToString:messageId]) {
                *stop = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    [self.chatTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
        }];
    }
}

- (void)questionBtnStatus {
    self.addView.questionBtn.hidden = YES;
    [QMConnect sdkGetCommonQuestion:^(NSArray *dataArr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dataArr.count > 0) {
                self.addView.questionBtn.hidden = NO;
            }
        });
    } failure:^(NSString *error) {
        
    }];

}

#pragma mark ------- 创建会话 --------
- (void)beginNewChat:(BOOL)otherAgent {
    self.isPush = true;

    __weak QMChatRoomViewController * myChatView = self;

    NSDictionary *param = @{@"customField":@{@"扩展信息key":@"扩展信息value",@"user_labels":@{@"vip":@"true",@"city":@"beijing"}},@"agent":@"0000"};
    
    if (self.isOpenSchedule) {
        [QMConnect sdkBeginNewChatSessionSchedule:self.scheduleId processId:self.processId currentNodeId:self.currentNodeId entranceId:self.entranceId params:param successBlock:^(BOOL remark, NSString *chatID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_beginChatID = chatID;
                if (otherAgent) {
                    [myChatView acceptOtherAgentChatStatus:remark];
                }else {
                    [myChatView changeChatStatus:remark];
                }
            });
        } failBlock:^(NSString *failure) {
            [self popVC];
            QMLog(@"开始会话失败");
        }];
    }else {
        [QMConnect sdkBeginNewChatSession:self.peerId params:param successBlock:^(BOOL remark, NSString *chatID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_beginChatID = chatID;
                if (otherAgent) {
                    [myChatView acceptOtherAgentChatStatus:remark];
                }else {
                    [myChatView changeChatStatus:remark];
                }
            });
        } failBlock:^(NSString *failure) {
            [self popVC];
            QMLog(@"开始会话失败");
        }];
    }
}

- (void)changeChatStatus:(BOOL)remark {
    isRemark = remark;
    // 是否启动了评价功能
    if (self.isRobot) {
        if ([QMConnect manualButtonStatus]) {
            self.manualButotn.hidden = NO;
        } else {
            self.manualButotn.hidden = YES;
        }
        if (_isSpeak && isShowEvaluate && _isRobot && !alreadEvaluate) {
            self.addView.evaluateBtn.hidden = NO;
        }
    }else{
        self.manualButotn.hidden = YES;
    }
    
    [QMActivityView stopAnimating];
    [self.coverView removeFromSuperview];
    isFinish = NO;

    NSArray *bottomArr = [QMConnect xbotBottomList:@""];

    if (bottomArr.count > 0) {
        isBottomShow = YES;
        self.bottomView.hidden = NO;
        self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kInputViewHeight-_navHeight - 52);
        self.bottomView.frame = CGRectMake(0, QM_kScreenHeight-kInputViewHeight-_navHeight - 52, QM_kScreenWidth, 52);
        [self.bottomView showData:bottomArr];
        __weak QMChatRoomViewController *weakSelf = self;
        self.bottomView.tapSendText = ^(NSString * text) {
            [weakSelf sendText:text];
        };
    }else{
        isBottomShow = NO;
        self.bottomView.hidden = YES;
        self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kInputViewHeight-_navHeight);
    }
    
    if ([QMConnect sdkVideoRights]) {
        self.addView.videoBtn.hidden = NO;
    }else {
        self.addView.videoBtn.hidden = YES;
    }
}

- (void)acceptOtherAgentChatStatus:(BOOL)remark {
    if (remark == NO) {
        self.addView.evaluateBtn.hidden = YES;
    }else {
        self.addView.evaluateBtn.hidden = NO;
    }
    [self changeBottomViewFrame];
}

#pragma mark -------- 音视频 -------
- (void)customVideoCancel:(NSNotification *)notification {
//    [self stopPlaying];
//    [self.answerView removeFromSuperview];
}

// 发起视频
- (void)takeVideoBtnAction:(UIButton *)sender {
    //    [self endEditChatInput];
    if (!isClaim) {
        [QMRemind showMessage:@"请先转人工后，再发起视频"];
    } else {
        
        BOOL audioEnabled = NO;
        AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (audioAuthStatus == AVAuthorizationStatusAuthorized || audioAuthStatus == AVAuthorizationStatusNotDetermined) {
            audioEnabled = YES;
        }

        
        
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *video = [UIAlertAction actionWithTitle:@"视频通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showMeetView:@"video_Invite" roomId:@"" password:@""];
    

        }];

        UIAlertAction *voice = [UIAlertAction actionWithTitle:@"语音通话" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showMeetView:@"voice_Invite" roomId:@"" password:@""];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [sheet addAction:video];
        [sheet addAction:voice];
        [sheet addAction:cancel];
        [self presentViewController:sheet animated:YES completion:nil];
                
    }
}

- (void)showMeetView:(NSString *)type roomId:(NSString *)roomId password:(NSString *)password {
    __weak typeof(self)wSelf = self;
    void(^closeAction)(void) = ^ {
        NSLog(@"ssssssssssss");
        [wSelf createNSTimer];
    };
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.currentAgent.name forKey:@"name"];
    [param setValue:self.currentAgent.icon_url forKey:@"icon_url"];
    [param setValue:type forKey:@"type"];
    if (roomId.length > 0) {
        [param setValue:roomId forKey:@"roomId"];
    }
    if (password.length > 0) {
        [param setValue:password forKey:@"password"];
    }
    
    
    Class callClass = NSClassFromString(@"QMCallingManager");
    SEL selecter = NSSelectorFromString(@"getCallWaitViewControllerInfo:close:");
    if ([callClass respondsToSelector:selecter]) {
        IMP imp = [callClass methodForSelector:selecter];
        UIViewController *(*func)(id, SEL, NSDictionary *, void(^)(void)) = (void *)imp;

        UIViewController *waitVC = func(callClass, selecter, param, closeAction);
        if ([waitVC isKindOfClass:[UIViewController class]]) {
            [self removeTimer];
            waitVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:waitVC animated:YES completion:nil];
        }

    }
}

// 视频被邀请
- (void)customVideoInvite:(NSNotification *)nofification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideKeyboard];
        NSString *nofi = (NSString *)nofification.object;
        NSArray *arr = [nofi componentsSeparatedByString:@"@"];
        
        if (arr.count > 3) {
            NSString *roomId = arr[1];
            NSString *pwd = arr[2];
            NSString *type = arr.lastObject;
            NSString *room_type = @"voice";
            if ([type containsString:@"video"]) {
                room_type = @"video";
            }
            [self showMeetView:room_type roomId:roomId password:pwd];

        }
    });

}

#pragma mark --------- 转人工事件 ---------
// 转人工客服
- (void)customClick:(UIButton *)button {
    [QMConnect sdkConvertManual:^{
        QMLog(@"转人工客服成功");
        [self changeBottomViewFrame];
    } failBlock:^{
        QMLog(@"转人工客服失败");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isOpenSchedule == NO) {
                [self showGuestBookViewController];
            }
        });
    }];
    
    button.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.enabled = YES;
    });
}

// 更改xbot底部推荐的状态
- (void)changeBottomViewFrame {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->isShowAssociatsInput = NO;
        self->isBottomShow = NO;
        self.bottomView.hidden = YES;
        if (!self.chatInputView.inputView.isFirstResponder) {
            self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-kInputViewHeight-self->_navHeight);
        } else {
            self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, self.view.frame.size.height - self->keyBoardFrame.size.height - kInputViewHeight);
        }
    });
}

#pragma mark ------- logoutAction 注销事件 --------
- (void)logoutAction {
    Class callClass = NSClassFromString(@"QMCallingManager");
    SEL shared = NSSelectorFromString(@"shared");
    id class = ((id(*)(id, SEL))objc_msgSend)(callClass, shared);
    SEL getisCalling = NSSelectorFromString(@"isCalling");
    BOOL isCalling = ((BOOL(*)(id, SEL))objc_msgSend)(class, getisCalling);
    
    if (isCalling) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"正在通话中，离开此页面会挂断通话，您确定要离开吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SEL selecter = NSSelectorFromString(@"closeCallAction");
            if ([class respondsToSelector:selecter]) {
                IMP imp = [class methodForSelector:selecter];
                void (*func)(id, SEL) = (void *)imp;
                func(class, selecter);
            }
//            [QMCallingManager.shared closeCallAction];
            [self logout];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sure];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self logout];
    }
}

- (void)logout {
    if (isRemark && !_isRobot && isShowEvaluateBtn && !self.evaluation.CSRCustomerLeavePush) {
        [self createEvaluationView:YES andGetServerTime:NO andEvaluatId:_beginChatID andFrom:@"in"];
    }else{
        [self popVC];
    }
}

#pragma mark - hideKeyboard
- (void)hideKeyboard {
    self.chatInputView.addButton.tag = 3;
    [self.chatInputView.inputView resignFirstResponder];
    self.chatInputView.inputView.inputView = nil;
    [self.chatInputView showMoreView:NO];
}

#pragma mark ------ NSNotification --------
- (void)getNewReload:(NSNotification *)sender {
    [self getData];
    [self reloadTableView];
    
    if (backStatus.isValid) {
        [backStatus invalidate];
    }
    
    NSArray *array = [QMConnect sdkGetAgentMessageWithIsRead];
    [QMConnect sdkDealImMsgWithMessageID:array];
    
    if (_isSpeak && isShowEvaluate && _isRobot && !alreadEvaluate) {
        self.addView.evaluateBtn.hidden = NO;
    }
    
    if ([QMConnect customerAccessAfterMessage]) {
        if (_isSpeak) {
            if (!_isRobot && !alreadEvaluate) {
                [QMConnect customerServiceIsSpeek:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->isShowEvaluateBtn = YES;
                        [self isShowEvaluateBtn:YES];
                    });
                } failBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self->isShowEvaluateBtn = NO;
                        [self isShowEvaluateBtn:NO];
                    });
                }];
            }
        }
    }else {
        if (!_isRobot && !alreadEvaluate) {
            [QMConnect customerServiceIsSpeek:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->isShowEvaluateBtn = YES;
                    [self isShowEvaluateBtn:YES];
                });
            } failBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->isShowEvaluateBtn = NO;
                    [self isShowEvaluateBtn:NO];
                });
            }];
        }
    }
}

//机器人客服
- (void)robotAction {
    QMLog(@"机器人客服");
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.now_robit", nil);
    if ([QMConnect manualButtonStatus]) {
        self.manualButotn.hidden = NO;
    } else {
        self.manualButotn.hidden = YES;
    }
    self.isRobot = YES;
    alreadEvaluate = NO;
    _isSpeak = NO;
    if (_isSpeak && isShowEvaluate && _isRobot && !alreadEvaluate) {
        self.addView.evaluateBtn.hidden = NO;
    }else{
        self.addView.evaluateBtn.hidden = YES;
    }
    
    [self changeTitleView];
}

//在线客服
- (void)customOnline {
    QMLog(@"客服在线");
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.people_now", nil);
    self.manualButotn.hidden = YES;
    self.isRobot = NO;
    isClaim = YES;
    alreadEvaluate = NO;
    [self createNSTimer];
    [self changeBottomViewFrame];
    self.addView.evaluateBtn.hidden = YES;
    [self changeTitleView];
}

// 客服离线
- (void)customOffline {
    QMLog(@"客服离线");
    self.manualButotn.hidden = NO;
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.people_isline", nil);
    if (!_isOpenSchedule) {
        [self showGuestBookViewController];
    }
    
    [self changeTitleView];
}

// 会话领取
- (void)customClaim {
    QMLog(@"会话被坐席领取");
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.people_now", nil);
    self.manualButotn.hidden = YES;
    self.isRobot = NO;
    isClaim = YES;
    alreadEvaluate = NO;
    [self changeBottomViewFrame];
    self.addView.evaluateBtn.hidden = YES;
    [self changeTitleView];
}

// 离线推送 （坐席在后台结束会话，返回上一界面）
- (void)customFinish:(NSNotification *)notification {
    QMLog(@"客服结束会话");
    [self.chatInputView.inputView endEditing:YES];
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.people_isleave", nil);
    
    [self.chatInputView.coverView setHidden:NO];
    [QMPushManager share].isFinish = YES;
    
    alreadEvaluate = NO;
    _isSpeak = NO;
    isShowEvaluateBtn = NO;
    self.isRobot = NO;
    
    if ([notification.object isEqualToString:@"tapAction"]) {
        [self tapAction];
    }
    self.associationView.hidden = YES ;
    [self changeTitleView];
}

// 排队人数
- (void)customQueue:(NSNotification *)notification {
    QMLog(@"排队人数 %@", notification.object);
    
    NSArray *array =  [QMConnect sdkQueueMessage];
    if (array.count == 2) {
        NSString *title = array[0];
        NSString *alp = array[1];
        NSString *replacedStr = [title stringByReplacingOccurrencesOfString:alp withString:[NSString stringWithFormat:@"%@",notification.object]];
        _titleView.stateInfoLabel.text = replacedStr;
    } else if (array.count == 1) {
        NSString *title = array[0];
        if ([title isEqualToString:@""]) {
            _titleView.stateInfoLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"title.line_up", nil), notification.object];
        }else{
            _titleView.stateInfoLabel.text = title;
        }
    }else {
        _titleView.stateInfoLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"title.line_up", nil), notification.object];
    }
    
    self.manualButotn.hidden = YES;
    self.addView.evaluateBtn.hidden = YES;
    [self changeTitleView];
}

// 坐席信息 (坐席工号、坐席名称、坐席头像) 可能为空字符串需要判断
- (void)customAgentMessage:(NSNotification *)notification {
    QMAgent *agent = notification.object;
    NSString *string;
    if ([agent.type isEqualToString:@"robot"]) {
        string = [NSString stringWithFormat:@"%@", agent.name];
    }else if ([agent.type isEqualToString:@"activeClaim"]){
        string = [NSString stringWithFormat:@"%@(%@)", agent.name, agent.exten];
        [self customOnline];
    }else {
        string = [NSString stringWithFormat:@"%@(%@)", agent.name, agent.exten];
    }
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _titleView.nameLabel.text = [NSString stringWithFormat:@"%@",string];
    [self changeTitleView];
    self.currentAgent = agent;
}

// 满意度推送
- (void)customInvestigate:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString *evaluateChatId = @"";
    if (array.count > 1) {
        evaluateOperation = array[0];
        evaluateChatId = array[1];
    }else if (array.count == 1) {
        evaluateOperation = array[0];
    }
    QMLog(@"满意度通知");
    [self createEvaluationView:NO andGetServerTime:YES andEvaluatId:evaluateChatId andFrom:@"out"];
}

// 专属坐席不在线通知 调用接受其他坐席服务接口成功后调用 beginSession
- (void)customVIP {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.schedule_notonline", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * resolvedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.transferAgent", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak QMChatRoomViewController * myChatView = self;
            [QMConnect sdkAcceptOtherAgentWithPeer:self.peerId successBlock:^{
                
                [myChatView beginNewChat:YES];
            } failBlock:^{
                
                [QMRemind showMessage:NSLocalizedString(@"title.schedule_faile", nil)];
            }];
        });
        
    }];
    [alertController addAction:resolvedAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 日程管理的留言
- (void)customLeavemsg: (NSNotification*)notification {
    NSArray *array = notification.object;
    NSString *str = array[0];
    [QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSDictionary*dic in scheduleDic[@"leavemsgNodes"]) {
                if ([str isEqualToString:dic[@"_id"]]){
                    NSMutableArray *fieldArray = [NSMutableArray array];
                    for (id field in dic[@"leavemsgFields"]) {
                        if ([field[@"enable"] boolValue] == YES) {
                            [fieldArray addObject:field];
                        }
                    }
                    QMChatGuestBookViewController *guestBookVC = [[QMChatGuestBookViewController alloc] init];
                    guestBookVC.peerId = array[1];
                    guestBookVC.contactFields = fieldArray;
                    guestBookVC.headerTitle = dic[@"title"];
                    guestBookVC.leaveMsg = dic[@"contentTip"];
                    guestBookVC.isScheduleLeave = true;
                    if (self->breakTipTimer) {
                        [self->breakTipTimer invalidate];
                        self->breakTipTimer = nil;
                    }
                    if (self->breakTimer) {
                        [self->breakTimer invalidate];
                        self->breakTimer = nil;
                    }
                    [self.navigationController pushViewController:guestBookVC animated:YES];
                }
            }
        });
    } failBlock:^{
        QMLog(@"日程管理进入留言失败");
    }];
}

// 坐席正在输入
- (void)changeCustomStatus {
    if (![_titleView.stateInfoLabel.text isEqual: NSLocalizedString(@"title.other_writing", nil)]) {
        NSString *str = _titleView.stateInfoLabel.text;
        _titleViewText = str;
    }
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.other_writing", nil);
    
    backStatus = nil;
    backStatus = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(backCustomStatus:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:backStatus forMode:NSRunLoopCommonModes];
}

- (void)backCustomStatus:(NSTimer *)time {
    _titleView.stateInfoLabel.text = _titleViewText;
    [backStatus invalidate];
}

// 撤回消息
- (void)cbangeDrowMessageStatus: (NSNotification*)notification {
    NSString *messageId = notification.object;
    [QMConnect changeDrawMessageStatus:messageId];
    [self getData];
    [self reloadTableView];
}

// 小陌机器人是否开启满意度评价
- (void)customSatisfaction:(NSNotification *)notification {
    NSArray *arr = notification.object;
    
    if (arr[1]) {
        _intelligentRobot = arr[1];
    }
    
    if ([arr[0] isEqualToString:@"true"]) {
        isShowEvaluate = true;
        if (_isSpeak) {
            self.addView.evaluateBtn.hidden = NO;
        }
    }
}

// xbot机器人开启联想输入
- (void)customAssociatsInput:(NSNotification *)notification {
    NSArray *arr = notification.object;
    NSString *channel = arr[4];
    if ([channel isEqualToString:@"agent"]) {
        isShowAssociatsWithAgent = YES;
    }
    _cateIdArr = arr[1];
    isShowAssociatsInput = arr[0];
    _intelligentRobot = arr[2];
}

//更新已读未读状态
- (void)refreshVoiceMessage:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString *messageId = array[0];
    NSString *attText = array[1];
    
    if (attText.length > 0) {
        [QMRemind showMessage:attText showTime:5 andPosition:QM_kScreenHeight/2 - 20];
    }
    
    NSInteger row = 0;
    NSArray *messageModel = [QMConnect getOneDataFromDatabase:messageId];
    CustomMessage *oneModel = [[CustomMessage alloc] init];
    if (messageModel.count == 1) {
        oneModel = messageModel[0];
    }
    for (CustomMessage *item in self.dataArray) {
        if ([messageId isEqualToString:item._id]) {
            row = [self.dataArray indexOfObject:item];
            if (oneModel.fileName.length > 0) {
                item.fileName = oneModel.fileName;
            }
        }
    }
    row = self.dataArray.count - row - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];

    [self.chatTableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -------键盘监听-------
- (void)keyboardFrameChange:(NSNotification *)notification {
    
    QMChatFormView *formView = (QMChatFormView *)[[UIApplication sharedApplication].keyWindow viewWithTag:88];
    if (formView) {
        QMLog(@"QMChatFormView - QMChatFormView - QMChatFormView");
        return;
    }
    
    NSDictionary * userInfo =  notification.userInfo;
    NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect newFrame = [value CGRectValue];
    keyBoardFrame = newFrame;

    if (ceil(newFrame.origin.y) == [UIScreen mainScreen].bounds.size.height) {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatInputView.frame = CGRectMake(0, QM_kScreenHeight-kInputViewHeight-self->_navHeight, QM_kScreenWidth, kInputViewHeight);
            if (self->isBottomShow) {
                self.bottomView.hidden = NO;
                self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-self->_navHeight-kInputViewHeight-52);
                self.bottomView.frame = CGRectMake(0, QM_kScreenHeight-kInputViewHeight-self->_navHeight-52, QM_kScreenWidth, 52);
            }else{
                self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-self->_navHeight-kInputViewHeight);
                self.bottomView.hidden = YES;
            }
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            if (!self->keyboardIsShow) {
                self.chatInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-kInputViewHeight-newFrame.size.height-self->_navHeight, QM_kScreenWidth, kInputViewHeight);
                if (self->isBottomShow) {
                    self.bottomView.hidden = NO;
                    self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height-self->_navHeight-kInputViewHeight-newFrame.size.height-52);
                    self.bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-kInputViewHeight-newFrame.size.height-self->_navHeight-52, QM_kScreenWidth, 52);
                }else{
                    self.bottomView.hidden = YES;
                    self.chatTableView.frame = CGRectMake(0, 0, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height-self->_navHeight-kInputViewHeight-newFrame.size.height);
                }
                [self scrollToEnd];
            }
        }];
    }
    self.associationView.frame = CGRectMake(0, CGRectGetMinY(self.chatInputView.frame)-_questions.count*50, QM_kScreenWidth, _questions.count*50);
}

#pragma mark ------ 留言提示 -------
- (void)showGuestBookViewController {
        
    if ([QMConnect allowedLeaveMessage]) {
        self.msg = [QMConnect leaveMessageTitle];
        if ([self.msg isEqualToString:@""]) {
            self.msg = NSLocalizedString(@"title.messageprompts", nil);
        }
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message: self.msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.leaveMessage", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            QMChatGuestBookViewController *guestBookVC = [[QMChatGuestBookViewController alloc] init];
            guestBookVC.peerId = self.peerId;
            if (self->breakTipTimer) {
                [self->breakTipTimer invalidate];
                self->breakTipTimer = nil;
            }
            if (self->breakTimer) {
                [self->breakTimer invalidate];
                self->breakTimer = nil;
            }
            [self.navigationController pushViewController:guestBookVC animated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.signOut", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self logoutAction];
        }];
        [alertView addAction:sureAction];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }else {
        self.msg = [QMConnect leaveMessageAlert];
        if ([self.msg isEqualToString:@""]) {
            self.msg = NSLocalizedString(@"title.messageprompts", nil);
        }
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message: self.msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.iknow", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:cancel];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

- (void)isShowEvaluateBtn:(BOOL)speek {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (speek && !self.evaluation.CSRCustomerPush) {
            self.addView.evaluateBtn.hidden = NO;
        }else {
            self.addView.evaluateBtn.hidden = YES;
        }
    });
}

#pragma mark ------ 满意度评价 -------
// 满意度view from - 主动传 in --- 坐席推送的评价传out
- (void)createEvaluationView:(BOOL)isPop andGetServerTime:(BOOL)GetSer andEvaluatId:(NSString *)evaluatId andFrom:(NSString *)from {
    if (isShowEvaluateView) {
        return;
    }
    
    if (self.evaluation.evaluats.count == 0) {
        [QMRemind showMessage:NSLocalizedString(@"title.evaluation_remind", nil)];
        if (isPop) {
            [self popVC];
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [self.chatInputView showMoreView:NO];
    self.chatInputView.inputView.inputView = nil;
    [self.chatInputView.inputView endEditing:YES];
    keyboardIsShow = true;
    isShowEvaluateView = true;
    
    self.evaluationView = [[QMChatEvaluationView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.evaluationView.evaluation = self.evaluation;
    [self.evaluationView createUI];
    [self.view addSubview:self.evaluationView];

    @weakify(self)
    self.evaluationView.cancelSelect = ^{
        @strongify(self)
        [self.evaluationView removeFromSuperview];
        self->keyboardIsShow = false;
        self->isShowEvaluateView = NO;
        self->isShowEvaluateBtn = YES;
        self->evaluateOperation = @"";
        
        if (GetSer) {
            /// 获取时效参数
            [QMConnect sdkGetServerTime:^(NSString *timestamp) {
                QMLog(@"timestamp %@",timestamp);
                [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:weakSelf.peerId];
            } failureBlock:nil];
        }

        NSMutableDictionary *dic = @{@"text"    : @"",
                                     @"id"      : evaluatId,
                                     @"status"  : @"0",
                                     @"timeout" : self.evaluation.timeout
        }.mutableCopy;
        if (self.evaluation.CSRAging) {//是否开启满意度超时
            [QMConnect sdkGetServerTime:^(NSString *timestamp) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    QMLog(@"timestamp %@",timestamp);
                    if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                        [dic setValue:timestamp forKey:@"timestamp"];
                        [self sendEvaluateMessage:dic];
                    }
                });
            } failureBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dic setValue:@"" forKey:@"timestamp"];
                    if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                        [self sendEvaluateMessage:dic];
                    }
                });
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [dic setValue:@"" forKey:@"timestamp"];
                if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                    [self sendEvaluateMessage:dic];
                }
            });
        }

        if (isPop) {
            [self popVC];
        }
    };
    
    isShowEvaluateBtn = false;
    if ([from isEqualToString:@"send"]) {
        from = @"out";
    }
    self.evaluationView.sendSelect = ^(NSString *optionName, NSString *optionValue, NSArray *radioValue, NSString *textViewValue) {
        @strongify(self)
        __strong typeof(weakSelf)sSelf = weakSelf;
        [QMConnect sdkNewSubmitInvestigate:optionName value:optionValue radioValue:radioValue remark:textViewValue way:from operation:self->evaluateOperation sessionId:evaluatId successBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMActivityView stopAnimating];
                [QMRemind showMessage:weakSelf.evaluation.thank ?: NSLocalizedString(@"button.chat_thank", nil)];
                self->alreadEvaluate = YES;
                [self isShowEvaluateBtn:NO];
                self->isShowEvaluateView = NO;
                NSString *nameStr = [@"用户已评价:" stringByAppendingFormat:@"%@ ",optionName];
                NSString *radioStr = @"";
                if (radioValue.count > 0) {
                    radioStr = [radioValue componentsJoinedByString:@","];
                    radioStr = [@"标签:" stringByAppendingFormat:@"%@ ", radioStr];
                }
                NSString *textViewStr = @"";
                if (textViewValue.length > 0) {
                    textViewStr = [@"详细信息:" stringByAppendingFormat:@"%@ ", textViewValue];
                }
                NSString *messageStr = [NSString stringWithFormat:@"%@%@%@",nameStr, radioStr, textViewStr];
                
                [QMConnect sdkUpdateEvaluateStatusWithEvaluateId:evaluatId.length > 0 ? evaluatId : @""];
                NSDictionary *dic = @{@"text"      : messageStr,
                                      @"id"        : @"",
                                      @"status"    : @"2",
                                      @"timestamp" : @"",
                                      @"timeout"   : @""
                };
                [self sendEvaluateMessage:dic];
            });
        } failBlock:^{
            QMLog(@"评价失败");
            [QMActivityView stopAnimating];
            sSelf->isShowEvaluateBtn = YES;
            sSelf->isShowEvaluateView = NO;
            [sSelf isShowEvaluateBtn:YES];
        }];
        [sSelf.evaluationView removeFromSuperview];
        sSelf->keyboardIsShow = false;
                
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dic = @{@"text"    : @"",
                                         @"id"      : evaluatId,
                                         @"status"  : @"0",
                                         @"timeout" : self.evaluation.timeout
            }.mutableCopy;
            [dic setValue:@"" forKey:@"timestamp"];
            if (evaluatId.length > 0 && ![from isEqualToString:@"send"]) {
                [self sendEvaluateMessage:dic];
            }
        });
        
        if (isPop) {
            [sSelf popVC];
        }
    };
}

- (void)sendEvaluateMessage:(NSDictionary *)dic {
    
    [QMConnect sdkSendEvaluateMessage:dic];
}

- (void)pushSatisfaction:(NSString *)faction robotId:(NSString *)robotId {
    NSString *robotType = [QMConnect sdkRobotType];
    if ([robotType isEqualToString:@"xbot"]) {
        [QMConnect sdkSubmitXbotRobotSatisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_ok", nil)];
                self->alreadEvaluate = YES;
                self.addView.evaluateBtn.hidden = YES;
            });
        } failBlock:^{
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_fail", nil)];
            });
        }];
    }else if ([robotType isEqualToString:@"7mbot_ai"]) {
        [QMConnect sdkSubmitIntelligentRobotSatisfaction:robotId satisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_ok", nil)];
                self->alreadEvaluate = YES;
                self.addView.evaluateBtn.hidden = YES;
            });
        } failBlock:^{
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_fail", nil)];
            });
        }];
    }else {
        [QMConnect sdkSubmitXbotRobotSatisfaction:faction successBlock:^{
            QMLog(@"评价成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_ok", nil)];
                self->alreadEvaluate = YES;
                self.addView.evaluateBtn.hidden = YES;
            });
        } failBlock:^{
            QMLog(@"评价失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMRemind showMessage:NSLocalizedString(@"title.robot_evaluation_fail", nil)];
            });
        }];
    }
}

- (void)popVC {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self remeveAllfunc];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)remeveAllfunc {
    _isSpeak = NO;
    alreadEvaluate = NO;
    [[QMAudioPlayer sharedInstance] stopAudioPlayer];
    [QMConnect logout];
    [self removeTimer];
}

#pragma mark ------ 开启访客无响应 定时断开会话 ------
- (void)createNSTimer{
//    QMLog(@"开启无响应定时器");
    [self removeTimer];
    self.breakDuration = [QMConnect breakSessionDuration];
    self.breakTipsDuration = [QMConnect breakSessionAlertDuration];
    if (self.breakDuration && self.breakTipsDuration && [QMConnect allowedBreakSession]) {
        breakTipTimer = [NSTimer scheduledTimerWithTimeInterval:self.breakTipsDuration * 60 target:self selector:@selector(breakTipTimerAction:) userInfo:nil repeats:NO];
        breakTimer = [NSTimer scheduledTimerWithTimeInterval:self.breakDuration * 60 target:self selector:@selector(breakTimerAction:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:breakTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop mainRunLoop] addTimer:breakTipTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeTimer {
    if (breakTipTimer) {
        [breakTipTimer invalidate];
        breakTipTimer = nil;
    }
    if (breakTimer) {
        [breakTimer invalidate];
        breakTimer = nil;
    }
}

- (void)breakTimerAction:(NSTimer *)time{
    [self.chatInputView.inputView endEditing:YES];
    [self.manualButotn setHidden:true];
    self.chatInputView.coverView.hidden = NO;
    _titleView.stateInfoLabel.text = NSLocalizedString(@"title.people_isleave", nil);
    [QMConnect sdkClientChatClose:_beginChatID];
}

- (void)breakTipTimerAction:(NSTimer *)timer{
    [QMConnect sdkSendBreakTipMessage];
    [breakTipTimer invalidate];
}

#pragma mark ------- 继续咨询 ------
- (void)tapAction {
    self.tapCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tapCoverView.backgroundColor = [UIColor colorWithHexString:QMColor_000000_text alpha:0.3];
    [self.view addSubview:self.tapCoverView];

    UIView *tapView = [[UIView alloc] init];
    tapView.frame = CGRectMake(0, QM_kScreenHeight - kStatusBarAndNavHeight - 190, QM_kScreenWidth, 190);
    tapView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    [self.tapCoverView addSubview:tapView];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, 40)];
    headerLabel.text = @"提示";
    headerLabel.font = QMFont_Medium(14);
    headerLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? @"#959595" : QMColor_333333_text];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : @"#F5F5F5"];
    [tapView addSubview:headerLabel];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, QM_kScreenWidth, 17)];
    titleLabel.text = NSLocalizedString(@"title.chatFinish_reopen", nil);
    titleLabel.font = QMFont_Medium(14);
    titleLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [tapView addSubview:titleLabel];

    UIButton *beginBtn = [[UIButton alloc] init];
    beginBtn.frame = CGRectMake((QM_kScreenWidth - 235)/2, 115, 110, 40);
    beginBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [beginBtn setTitle:NSLocalizedString(@"title.chatBegin", nil) forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor colorWithHexString:QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [beginBtn setBackgroundColor:[UIColor colorWithHexString:QMColor_News_Custom]];
    beginBtn.layer.masksToBounds = YES;
    beginBtn.layer.cornerRadius = 5;
    [beginBtn addTarget:self action:@selector(beginAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:beginBtn];

    UIButton *outBtn = [[UIButton alloc] init];
    outBtn.frame = CGRectMake(QM_kScreenWidth/2 + 7.5, 115, 110, 40);
    outBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [outBtn setTitle:NSLocalizedString(@"button.signOut", nil) forState:UIControlStateNormal];
    [outBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_FFFFFF_text] forState:UIControlStateNormal];
    [outBtn setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : QMColor_News_Custom]];
    outBtn.layer.masksToBounds = YES;
    outBtn.layer.cornerRadius = 5;
    [outBtn addTarget:self action:@selector(outAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:outBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(QM_kScreenWidth - 26, 15, 10, 10);
    cancelBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:15];
    [cancelBtn setTitle:@"X" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_666666_text] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [tapView addSubview:cancelBtn];
}

- (void)beginAction {
    [QMActivityView startAnimating];
    [self createCoverView];
    [self.tapCoverView removeFromSuperview];
    [self.chatInputView.coverView setHidden:YES];
    [QMPushManager share].isFinish = NO;
    [self getConfig];
}

- (void)outAction {
    [self.tapCoverView removeFromSuperview];
    [self.chatInputView.coverView setHidden:YES];
    [QMPushManager share].isFinish = NO;
    [self logoutAction];
}

- (void)cancelAction {
    [self.tapCoverView removeFromSuperview];
}

- (void)getConfig {
    QMLog(@"进入config");
    [QMConnect sdkGetWebchatScheduleConfig:^(NSDictionary * _Nonnull scheduleDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scheduleDic = scheduleDic;
            if ([self.scheduleDic[@"scheduleEnable"] intValue] == 1) {
                QMLog(@"日程管理");
                [self starSchedule];
            }else{
                QMLog(@"技能组");
                [self getPeers];
            }
        });
    } failBlock:^{
        [self getPeers];
    }];
}

- (void)getPeers {
    
    [QMConnect sdkGetPeers:^(NSArray * _Nonnull peerArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *peers = peerArray;
            if (peers.count == 1 && peers.count != 0) {
                [self setPropertyValue:[peers.firstObject objectForKey:@"id"] processType:@"" entranceId:@""];
            }else {
                [self showPeersWithAlert:peers messageStr:NSLocalizedString(@"title.type", nil)];
            }
        });
    } failureBlock:^{

    }];
}

- (void)starSchedule {
    
    if ([self.scheduleDic[@"scheduleId"] isEqual: @""] || [self.scheduleDic[@"processId"] isEqual: @""] || [self.scheduleDic objectForKey:@"entranceNode"] == nil || [self.scheduleDic objectForKey:@"leavemsgNodes"] == nil) {
        [QMRemind showMessage:NSLocalizedString(@"title.sorryconfigurationiswrong", nil)];
    }else{
        NSDictionary *entranceNode = self.scheduleDic[@"entranceNode"];
        NSArray *entrances = entranceNode[@"entrances"];
        if (entrances.count == 1 && entrances.count != 0) {
            [self setPropertyValue:[entrances.firstObject objectForKey:@"processTo"] processType:[entrances.firstObject objectForKey:@"processType"] entranceId:[entrances.firstObject objectForKey:@"_id"]];
        }else{
            [self showPeersWithAlert:entrances messageStr:NSLocalizedString(@"title.schedule_type", nil)];
        }
    }
}

- (void)showPeersWithAlert: (NSArray *)peers messageStr: (NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"title.type", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.chatInputView.coverView setHidden:NO];
        [QMPushManager share].isFinish = YES;
    }];
    [alertController addAction:cancelAction];
    for (NSDictionary *index in peers) {
        UIAlertAction *surelAction = [UIAlertAction actionWithTitle:[index objectForKey:@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self.scheduleDic[@"scheduleEnable"] integerValue] == 1) {
                [self setPropertyValue:[index objectForKey:@"processTo"] processType:[index objectForKey:@"processType"] entranceId:[index objectForKey:@"_id"]];
            }else{
                [self setPropertyValue:[index objectForKey:@"id"] processType:@"" entranceId:@""];
            }
        }];
        [alertController addAction:surelAction];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setPropertyValue:(NSString *)peerId processType:(NSString *)processType entranceId:(NSString *)entranceId {
    self.peerId = peerId;
    if ([self.scheduleDic[@"scheduleEnable"] intValue] == 1) {
        self.isOpenSchedule = true;
        self.scheduleId = self.scheduleDic[@"scheduleId"];
        self.processId = self.scheduleDic[@"processId"];
        self.currentNodeId = peerId;
        self.processType = processType;
        self.entranceId = entranceId;
    }else {
        self.isOpenSchedule = false;
    }
    
    CGFloat addViewHeight = QM_IS_iPHONEX ? 144 : 110;
    addViewHeight = [QMConnect sdkVideoRights] ? (addViewHeight + 96) : addViewHeight;
    // 扩展面板
    self.addView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, QM_kScreenWidth, addViewHeight);

    [self beginNewChat:NO];
}

#pragma mark ----- MoreView Action ------
//通过摄像头获取图片
- (void)photoBtnAction {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//从相册获取图片
- (void)takePicBtnAction {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

//相机代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 快速点的时候会回调多次
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [self sendImage:image];
        }
        else {
            
        }
    }];
}

// 获取文件
- (void)takeFileBtnAction {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    QMFileManagerController * fileViewController = [[QMFileManagerController alloc] init];
                    [self.navigationController pushViewController:fileViewController animated:true];
                }
                    break;
                case PHAuthorizationStatusDenied: {
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.prompt", nil) message: NSLocalizedString(@"title.photoAuthority", nil) preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.set", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (UIApplicationOpenSettingsURLString != NULL) {
                            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication] openURL:appSettings];
                        }
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    [alertController addAction:action];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusRestricted:
                    QMLog(@"相册访问受限!");
                    break;
                default:
                    break;
            }
        });
    }];
}

// 满意度评价
- (void)evaluateBtnAction {
    
    if (_isRobot) {
        
        if (alreadEvaluate) {
            return;
        }
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.robot_evaluation", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * resolvedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.solved_ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushSatisfaction:@"true" robotId:self->_intelligentRobot];
        }];
        [alertController addAction:resolvedAction];
        
        UIAlertAction * unsolvedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.solved_fail", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushSatisfaction:@"false" robotId:self->_intelligentRobot];
        }];
        [alertController addAction:unsolvedAction];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else {
        NSString *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:self.peerId];
        
        if (self.evaluation.CSRAging && timestamp.length > 0 && self.evaluation.timeout.length > 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:timestamp forKey:@"timestamp"];
            [params setValue:self.evaluation.timeout forKey:@"timeout"];
            [QMConnect sdkCheckImCsrTimeoutParams:params success:^{
                [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:@"" andFrom:@"in"];
            } failureBlock:^{
                [QMRemind showMessage:NSLocalizedString(@"title.evaluation_timeout", nil) showTime:5 andPosition:QM_kScreenHeight/2 - 10];
            }];
        } else {
            [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:@"" andFrom:@"in"];
        }
    }
}

// 常见问题
- (void)openQuestionView {
    QMQuestionViewController *vc = [QMQuestionViewController new];
    __weak typeof(self)wSelf = self;
    vc.backQuestion = ^(QMQuestionModel * model) {
        [wSelf insertModeltoIMDB:model];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)insertModeltoIMDB:(QMQuestionModel *)model {
    [QMConnect createAndInsertMessageToDBWithMessageType:@"Text" filePath:nil content:model.title metaData:nil];
}


#pragma mark - faceViewDelegate
// 表情代理及相关处理
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele {
    if (dele) {
        [_chatInputView.inputView deleteBackward];
    }else {
        [self insertEmoji:faceStr];
    }
}

- (void)insertEmoji: (NSString *)code {
    QMTextAttachment * emojiTextAttemt = [QMTextAttachment new];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"QMEmoticon" ofType:@"bundle"];
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"expressionImage" ofType:@"plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:fileName];
    
    if ([plistDict objectForKey:code] != nil) {
        emojiTextAttemt.emojiCode = code;
        emojiTextAttemt.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", bundlePath, [plistDict objectForKey:code]]];
        emojiTextAttemt.bounds = CGRectMake(0, 0, 18, 18);
        
        NSAttributedString * attributeString = [NSAttributedString attributedStringWithAttachment:emojiTextAttemt];
        NSRange range = [_chatInputView.inputView selectedRange];
        if (range.length > 0) {
            [_chatInputView.inputView.textStorage deleteCharactersInRange:range];
        }
        
        [_chatInputView.inputView.textStorage insertAttributedString:attributeString atIndex:[_chatInputView.inputView selectedRange].location];
        _chatInputView.inputView.selectedRange = NSMakeRange(_chatInputView.inputView.selectedRange.location+1, 0);
    }
    
    [self resetTextStyle];
}

- (void)resetTextStyle {
    NSRange wholeRange = NSMakeRange(0, _chatInputView.inputView.textStorage.length);
    [_chatInputView.inputView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [_chatInputView.inputView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:wholeRange];
    _chatInputView.inputView.font = [UIFont systemFontOfSize:18];
}

- (void)sendFaceAction {
    if (![_chatInputView.inputView.text isEqualToString:@""]) {
        NSString *text = [_chatInputView.inputView.textStorage getRichString];
        [self sendText:text];
        _chatInputView.inputView.text = @"";
    }
}

#pragma mark - UITextViewDelegate && xbot联想输入
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        if (![_chatInputView.inputView.text isEqualToString:@""]) {
            NSString *text = [_chatInputView.inputView.textStorage getRichString];
            [self sendText:text];
            _chatInputView.inputView.text = @"";
            self.associationView.hidden = YES;
            
            
            return NO;
        }
        return NO;
    }
    return  YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        if (!self.isRobot) {
            isShowAssociatsInput = isShowAssociatsWithAgent;
//            if ([QMConnect sdkGetIsInputMonitor]) {
//                
//                long nowTime = [NSString getTimeStamp:[NSDate date]];
//                if ((dateTime == 0) || (nowTime - dateTime > 1)) {
//                    dateTime = nowTime;
//                    [QMConnect sdkInputMonitor:textView.text successBlock:^{
//                    } failBlock:^{
//                    }];
//                }
//            }
        }
        if (isShowAssociatsInput) {
            NSString *robotType = [QMConnect sdkRobotType];
            robotType = [robotType isEqual: @""] ? @"xbot" : robotType;
            [QMConnect sdkSubmitXbotRobotAssociationInput:textView.text cateIds:_cateIdArr robotId:_intelligentRobot robotType:robotType successBlock:^(NSArray *questions){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (questions.count > 0 && textView.text.length > 0) {
                        self->_questions = questions;
                            [self createQuestionView:questions andInputText:textView.text];
                    }else {
                        self->_questions = @[];
                        self.associationView.hidden = YES;
                    }
                });
            } failBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.associationView.hidden = YES;
                });
            }];
        }else {
            self.associationView.hidden = YES;
        }
    }else {
        self.associationView.hidden = YES;
    }
}

//xbot联想输入view
- (void)createQuestionView:(NSArray *)questions andInputText:(NSString *)text {
    __weak typeof(self) weakSelf = self;

    if (!self.associationView) {
        self.associationView = [[QMChatAssociationInputView alloc] init];
        [self.view addSubview:self.associationView];
    }
    self.associationView.hidden = NO;
    self.associationView.frame = CGRectMake(0, CGRectGetMinY(self.chatInputView.frame)-questions.count*50, QM_kScreenWidth, questions.count*50);
    [self.associationView showData:questions andInputText:text];
    self.associationView.questionsSelect = ^(NSString *question) {
        [weakSelf sendText:question];
        weakSelf.chatInputView.inputView.text = @"";
        weakSelf.associationView.hidden = YES;
    };
}

#pragma mark - inputeViewDelegate
//输入工具栏delegate
- (void)inputButtonAction:(UIButton *)button index:(int)index {
    
    switch (index) {
        case 100:
            [self voiceBtnAction:button];
            break;
        case 101:
            [self cancelRecord:button];
            break;
        case 102:
            [self RecordBtnBegin:button];
            break;
        case 103:
            [self RecordBtnEnd:button];
            break;
        case 104:
            [self RecordBtnExit:button];
            break;
        case 105:
            [self RecordBtnEnter:button];
            break;
        case 106:
            [self faceBtnAction:button];
            break;
        case 107:
            [self addBtnAction:button];
        default:
            break;
    }
}

//切换录音按钮
- (void)voiceBtnAction:(UIButton *)button {
    if (self.chatInputView.RecordBtn.hidden == YES) {
        self.chatInputView.faceButton.hidden = YES;
        [self.chatInputView showRecordButton:YES];
        [self.chatInputView.inputView endEditing:YES];
    }else {
        self.chatInputView.faceButton.hidden = NO;
        [self.chatInputView showRecordButton:NO];
        self.chatInputView.inputView.inputView = nil;
        [self.chatInputView.inputView becomeFirstResponder];
        [self.chatInputView.inputView reloadInputViews];
    }
}

//表情按钮
- (void)faceBtnAction:(UIButton *)button {
    if (button.tag == 1) {
        [self.chatInputView showEmotionView:YES];
        self.chatInputView.inputView.inputView = self.faceView;
    }else {
        [self.chatInputView showEmotionView:NO];
        self.chatInputView.inputView.inputView = nil;
    }
    [self.chatInputView.inputView becomeFirstResponder];
    [self.chatInputView.inputView reloadInputViews];
}

//扩展功能按钮
- (void)addBtnAction:(UIButton *)button {
    if (button.tag == 3) {
        [self.chatInputView showMoreView:YES];
        self.chatInputView.inputView.inputView = self.addView;
        [self.chatInputView.inputView becomeFirstResponder];
        [self.chatInputView.inputView reloadInputViews];
    }else {
        [self.chatInputView showMoreView:NO];
        self.chatInputView.inputView.inputView = nil;
        [self.chatInputView.inputView endEditing:YES];
    }
}

// 开始录音
- (void)RecordBtnBegin:(UIButton *)button {
    NSString *fileName = [[NSUUID new] UUIDString];
    // 验证权限
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
            break;
        case AVAuthorizationStatusAuthorized:
            self.recordeView.isCount = false;
            [self.recordeView changeViewStatus:QMIndicatorStatusNormal];
            [self.view addSubview:self.recordeView];
            [self changeButtonStatus:YES];
            [[QMAudioRecorder sharedInstance] startAudioRecord:fileName maxDuration:60.0 delegate:self];
            break;
        case AVAuthorizationStatusRestricted:
            QMLog(@"麦克风访问受限!");
            break;
        case AVAuthorizationStatusDenied:
            QMLog(@"设置允许访问麦克风");
            break;
    }
}

// 结束录音
- (void)RecordBtnEnd:(UIButton *)button {
    [[QMAudioRecorder sharedInstance] stopAudioRecord];
}

// 取消录音
- (void)cancelRecord: (UIButton *)button {
    [[QMAudioRecorder sharedInstance] cancelAudioRecord];
    [self.recordeView removeFromSuperview];
    [self changeButtonStatus:NO];
}

- (void)RecordBtnExit: (UIButton *)button {
    [self.recordeView changeViewStatus:QMIndicatorStatusCancel];
}

- (void)RecordBtnEnter: (UIButton *)button {
    [self.recordeView changeViewStatus:QMIndicatorStatusNormal];
}

// 更改按钮状态
- (void)changeButtonStatus:(BOOL)down {
    if (down == YES) {
        [self.chatInputView.RecordBtn setTitle:NSLocalizedString(@"button.recorder_recording", nil) forState:UIControlStateNormal];
        UIColor *color = [UIColor colorWithRed:50/255.0f green:167/255.0f blue:255/255.0f alpha:1.0];
        [self.chatInputView.RecordBtn setTitleColor:color forState:UIControlStateNormal];
        self.chatInputView.RecordBtn.layer.borderColor = [color CGColor];
    }else {
        [self.chatInputView.RecordBtn setTitle:NSLocalizedString(@"button.recorder_normal", nil) forState:UIControlStateNormal];
        [self.chatInputView.RecordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.chatInputView.RecordBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

#pragma mark - QMAudioRecorderDelegate
- (void)audioRecorderStart {
    
}

- (void)audioRecorderCompletion:(NSString *)fileName duration:(NSString *)duration {
    NSString * path = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",fileName];
    [SJVoiceTransform stransformToMp3ByUrlWithUrl:path];
    [self sendAudio:fileName duration:duration];
    if (duration.intValue >= 60) {
        [self.recordeView changeViewStatus:QMIndicatorStatusLong];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.recordeView removeFromSuperview];
            [self changeButtonStatus:NO];
        });
    }else {
        [self.recordeView removeFromSuperview];
        [self changeButtonStatus:NO];
    }
}

- (void)audioRecorderChangeInTimer:(NSTimeInterval)power total:(int)count {
    [self.recordeView updateImageWithPower:power];
    self.recordeView.count = count;
}

- (void)audioRecorderCancel {
    [self.recordeView removeFromSuperview];
    [self changeButtonStatus:NO];
}

- (void)audioRecorderFail {
    [self.recordeView changeViewStatus:QMIndicatorStatusShort];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.recordeView removeFromSuperview];
        [self changeButtonStatus:NO];
    });
}

- (void)changeTitleView {
    if (self.navigationController.navigationBar.frame.size.height < 44) {
        [_titleView showHeaderStatus:YES];
    }else {
        [_titleView showHeaderStatus:NO];
    }
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

@end
