//
//  QMChatImageCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/30.
//

#import "QMChatImageCell.h"
#import "QMChatShowImageViewController.h"
#import "SDImageCache.h"

@implementation QMChatImageCell

- (void)createUI {
    [super createUI];
    
    [self.chatBackgroundView addSubview:self.showImageView];
    [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.chatBackgroundView);
        make.width.height.mas_equalTo(200).priorityHigh();
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.showImageView addGestureRecognizer:longPress];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater
{
    [super setData:message avater:avater];
    self.chatBackgroundView.backgroundColor = [UIColor clearColor];
    
    NSString *urlString = message.message;
    if ([urlString.stringByRemovingPercentEncoding isEqualToString:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    }
    NSURL *url = [NSURL URLWithString:urlString ? : @"" ];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",NSHomeDirectory(),@"Documents",urlString.lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.showImageView.image = [UIImage imageNamed:filePath];
        [self upShowImageViewFrame:self.showImageView.image.size needUpdateCell:NO];
    }else {
        [self setNetImageWithURL:url];
    }
}

- (void)setNetImageWithURL:(NSURL *)url {
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:url.absoluteString];

    if (image) {
        self.showImageView.image = image;
        [self upShowImageViewFrame:image.size needUpdateCell:NO];
    }
    else {
        [self.showImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chat_image_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self upShowImageViewFrame:image.size needUpdateCell:YES];
        }];
    }
}

- (void)upShowImageViewFrame:(CGSize)imageSize needUpdateCell:(BOOL)update {
    if (imageSize.height == 0 || imageSize.width == 0) {
        return;
    }
    
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    if (imageSize.width > imageSize.height) {
        width = imageSize.width > 200 ? 200 : imageSize.width;
        height = width*imageSize.height/imageSize.width;
    } else {
        height = imageSize.height > 200 ? 200 : imageSize.height;
        width = height*imageSize.width/imageSize.height;
    }
    
    [self.showImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height).priorityHigh();
        make.width.mas_equalTo(width).priorityHigh();
    }];
    
    if (update && self.needReloadCell) {
        self.needReloadCell(self.message);
    }

}

- (void)tapRecognizerAction {
    QMChatShowImageViewController * showPicVC = [[QMChatShowImageViewController alloc] init];
    showPicVC.imageUrl = self.message.message;
    showPicVC.image = self.showImageView.image;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
}

- (SDAnimatedImageView *)showImageView {
    if (!_showImageView) {
        _showImageView = [[SDAnimatedImageView alloc] init];
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.userInteractionEnabled = YES;
    }
    return  _showImageView;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)press {
    if (press.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *removeMenu = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(removeMenu:)];
        [menu setMenuItems:[NSArray arrayWithObjects:removeMenu, nil]];
        [menu setTargetRect:self.showImageView.frame inView:self.showImageView];
        [menu setMenuVisible:YES animated:YES];
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if ([window isKeyWindow] == NO) {
            [window becomeKeyWindow];
            [window makeKeyAndVisible];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(removeMenu:)) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)removeMenu:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"title.prompt", nil) message:NSLocalizedString(@"title.statement", nil) preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [QMConnect removeDataFromDataBase:self.message._id];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHATMSG_RELOAD object:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


@end
