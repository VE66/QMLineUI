//
//  QMChatShowRichTextController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/21.
//

#import "QMChatShowRichTextController.h"
#import <WebKit/WebKit.h>
#import <AVKit/AVKit.h>
#import "QMChatUI.h"
@interface QMChatShowRichTextController () <UIScrollViewDelegate> {
    WKWebView *_webView;
    UIView *_topView;
    UIButton *_backButton;
    UILabel *_titleLabel;
}

@end

@implementation QMChatShowRichTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Nav_Bg_Dark : QMColor_Nav_Bg_Light];
    
    [self createUI];
    [self createWebView];
}

- (void)createUI {
    _topView = [[UIView alloc] init];
    _topView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kStatusBarAndNavHeight);
    [self.view addSubview:_topView];
    
    _backButton = [[UIButton alloc] init];
    _backButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, QM_kStatusBarHeight + 5, 40, 35);
    [_backButton setTitle:NSLocalizedString(@"button.back", nil) forState:UIControlStateNormal];
    [_backButton setTitleColor:isDarkStyle ? [UIColor whiteColor] : [UIColor colorWithRed:13/255.0 green:139/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(60, QM_kStatusBarHeight + 5, [UIScreen mainScreen].bounds.size.width - 120, 35);
    _titleLabel.textColor = isDarkStyle ? [UIColor whiteColor] : [UIColor colorWithRed:13/255.0 green:139/255.0 blue:249/255.0 alpha:1];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = self.title;
    [_topView addSubview:_titleLabel];
}

- (void)createWebView {
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavHeight, QM_kScreenWidth, [UIScreen mainScreen].bounds.size.height - kStatusBarAndNavHeight) configuration:[[WKWebViewConfiguration alloc] init]];
    if ([self.urlStr hasPrefix:@"http"] || self.isForm) {
        self.urlStr = [self.urlStr stringByRemovingPercentEncoding];
        NSString * url = [self.urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [_webView loadRequest:request];
        [self.view addSubview:_webView];
    }
    else {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",self.urlStr];
        
        if ([self.urlStr containsString:@"png"] ||
            [self.urlStr containsString:@"heic"]) {
            [self.view addSubview:_webView];
            NSURL *url = [NSURL fileURLWithPath:filePath];
            [_webView loadFileURL:url allowingReadAccessToURL:url];
        }
        else {
            AVPlayerViewController *vc = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
            vc.player = ({
                AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
                player;
            });
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
            [vc.player play];
            vc.view.frame = self.view.frame;
        }
    }

}

- (void)backAction:(UIButton *)button {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
