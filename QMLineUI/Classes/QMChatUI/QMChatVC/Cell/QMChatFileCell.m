//
//  QMChatFileCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/21.
//

#import "QMChatFileCell.h"
#import "QMChatShowRichTextController.h"
#import "PieView.h"

@interface QMChatFileCell ()

@property (nonatomic, strong) UIImageView *fileImageView;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *fileSize;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) PieView *pieView;

@end
@implementation QMChatFileCell

- (void)createUI {
    [super createUI];
    
    _fileImageView = [[UIImageView alloc] init];
    _fileImageView.clipsToBounds = YES;
    [self.chatBackgroundView addSubview:_fileImageView];
    
    _fileName = [[UILabel alloc] init];
    _fileName.font = QMFont_Medium(16);
    _fileName.numberOfLines = 2;
    [self.chatBackgroundView addSubview:_fileName];
    
    _fileSize = [[UILabel alloc] init];
    _fileSize.font = QMFONT(11);
    [self.chatBackgroundView addSubview:_fileSize];
    
    _progressView = [UIProgressView new];
    _progressView.progressTintColor = UIColor.redColor;
    _progressView.tintColor = UIColor.grayColor;
    _progressView.hidden = YES;
    [self.chatBackgroundView addSubview:_progressView];
    
    [self.fileImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.chatBackgroundView).offset(-15);
        make.top.equalTo(self.chatBackgroundView).offset(15);
        make.width.mas_equalTo(QMFixWidth(45)).priority(999);
        make.height.mas_equalTo(60).priority(999);
        make.bottom.equalTo(self.chatBackgroundView).offset(-15);
    }];
    
    [self.fileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chatBackgroundView).offset(14);
        make.top.equalTo(self.fileImageView);
        make.right.lessThanOrEqualTo(self.fileImageView.mas_left).offset(-15);
        make.width.mas_equalTo(QMFixWidth(170)).priorityHigh();
    }];
    
    [self.fileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileName);
        make.top.equalTo(self.fileName.mas_bottom).offset(6);
        make.right.lessThanOrEqualTo(self.chatBackgroundView).offset(-100);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fileName);
        make.right.equalTo(self.chatBackgroundView).offset(-10);
        make.bottom.equalTo(self.chatBackgroundView).offset(-4);
        make.height.mas_equalTo(2);
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    self.message = message;
    
    self.chatBackgroundView.backgroundColor = UIColor.whiteColor;
    self.fileName.text = message.fileName ? : @"";
    
    if ([message.fromType isEqualToString:@"1"]) {
        [self updateDownStatus];
    }
    else {
        [self updateSendStatues];
    }

    NSString *imageName = [self matchImageWithFileNameExtension: message.fileName.pathExtension.lowercaseString];
    self.fileImageView.image = [UIImage imageNamed:imageName];
    
}

- (void)tapRecognizerAction {
    
    if (self.message.localFilePath == nil) {
        NSString *localPath = [[QMProfileManager sharedInstance] checkFileExtension: self.message.fileName];
        __weak QMChatFileCell *weakSelf = self;
        [QMConnect downloadFileWithMessage:self.message localFilePath:localPath progressHander:^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setProgress:progress];
            });
        } successBlock:^{
            // 图片或视频存储至相册
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf setProgress:1];
            });
        } failBlock:^(NSString * _Nonnull error) {
            [weakSelf setProgress:1];
        }];
    }else {
        // 打开本地文件
        QMChatShowRichTextController *showFile = [[QMChatShowRichTextController alloc] init];
        showFile.modalPresentationStyle = UIModalPresentationFullScreen;
        showFile.urlStr = self.message.localFilePath;
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [vc presentViewController:showFile animated:YES completion:nil];
    }
}

- (void)updateSendStatues {
    NSString *status = @"";
    if ([self.message.status isEqualToString:@"0"]) {
        status = @"发送成功";
    } else if ([self.message.status isEqualToString:@"1"]) {
        status = @"发送失败";
    } else {
        status = @"发送中";
    }
    NSString *fileSize = [self.message.fileSize ? [self.message.fileSize stringByAppendingString:@" / "] : @"" stringByAppendingString:status];
    
    self.fileSize.text = fileSize;

}

- (void)updateDownStatus {
    
    NSString *status = @"";

    if ([self.message.downloadState isEqualToString:@"0"]) {
        status = @"已下载";
    } else if ([self.message.downloadState isEqualToString:@"1"]) {
        status = @"下载失败";
    } else {
        status = @"未下载";
    }
    NSString *fileSize = [self.message.fileSize ? [self.message.fileSize stringByAppendingString:@" / "] : @"" stringByAppendingString:status];
    
    self.fileSize.text = fileSize;

}

- (NSString *)matchImageWithFileNameExtension:(NSString *)fileName {
    NSString * str;
    if ([fileName isEqualToString:@"doc"]||[fileName isEqualToString:@"docx"]) {
        str = @"doc";
    }else if ([fileName isEqualToString:@"xlsx"]||[fileName isEqualToString:@"xls"]) {
        str = @"xls";
    }else if ([fileName isEqualToString:@"ppt"]||[fileName isEqualToString:@"pptx"]) {
        str = @"pptx";
    }else if ([fileName isEqualToString:@"pdf"]) {
        str = @"pdf";
    }else if ([fileName isEqualToString:@"mp3"]) {
        str = @"mp3";
    }else if ([fileName isEqualToString:@"mov"]||[fileName isEqualToString:@"mp4"]) {
        str = @"mov";
    }else if ([fileName isEqualToString:@"png"]||[fileName isEqualToString:@"jpg"]||[fileName isEqualToString:@"bmp"]||[fileName isEqualToString:@"jpeg"]) {
        str = @"png";
    }else {
        str = @"other";
    }
    return [NSString stringWithFormat:@"qm_file_%@", str];
}

- (void)setProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pieView removeFromSuperview];
        self.pieView = [[PieView alloc] initWithFrame:CGRectMake(-45/2, -15, 90, 90) dataItems:@[@(progress),@(1-progress)] colorItems:@[[UIColor clearColor], QM_RGBA(0, 0, 0, 0.2)]];
        self.pieView.backgroundColor = [UIColor clearColor];
        [self.fileImageView addSubview:self.pieView];
        [self.pieView stroke];
        if (progress >= 1) {
            if ([self.message.fromType isEqualToString:@"0"]) {
                self.message.status = @"0";
                [self updateSendStatues];
            }
        }
    });
}

@end
