//
//  QMChatShowImageViewController.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/19.
//

#import "QMChatShowImageViewController.h"
#import "QMChatUI.h"

@interface QMChatShowImageViewController () <UIAlertViewDelegate,UINavigationControllerDelegate>

@end

@implementation QMChatShowImageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (self.image) {
        self.bigImageView.image = self.image;
    } else if ([self.picType isEqualToString:@"0"]) {
        NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",self.imageUrl.lastPathComponent];
        self.bigImageView.image = [UIImage imageWithContentsOfFile:filePath];
    } else {
        [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:self.placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            self.image = image;
        }];
    }
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    UILongPressGestureRecognizer * pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.bigImageView addGestureRecognizer:pressGestureRecognizer];
    self.bigImageView.userInteractionEnabled = YES;
    [self.bigImageView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:self.bigImageView];
}

-(void)listenOrientationDidChange {
    self.bigImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

//长按保存图片
- (void)longPressAction:(UILongPressGestureRecognizer *)pressGestureRecognizer {
    if (pressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存图片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveImageAction];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertVC addAction:sureAction];
        [alertVC addAction:cancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)saveImageAction {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    } else if ([self.picType isEqualToString:@"0"]) {
        NSString * filePath = [NSString stringWithFormat:@"%@/%@/%@/%@",NSHomeDirectory(),@"Documents",@"SaveFile",self.imageUrl.lastPathComponent];
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:filePath], nil, nil, nil);
    }else {
        NSURL * url = [NSURL URLWithString:self.imageUrl];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
        }];

    }
}

- (UIImage *)placeholderImage {
    return _placeholderImage ? : [UIImage imageNamed:@"chat_card_placeholder"];
}

//返回
- (void)tapAction {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
