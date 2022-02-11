//
//  QMAudioAnimation.m
//  IMSDK-OC
//
//  Created by haochongfeng on 2017/5/18.
//  Copyright © 2017年 HCF. All rights reserved.
//

#import "QMAudioAnimation.h"

@interface QMAudioAnimation() {
    UIImageView *_animationView;
}

@end

@implementation QMAudioAnimation

static QMAudioAnimation * instance = nil;

+ (QMAudioAnimation *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (void)setAudioAnimationPlay:(BOOL)sender and:(UIImageView *)imageView {
    NSArray *images;
    if (sender) {
        images = [NSArray arrayWithObjects:[UIImage imageNamed:@"qm_chat_sendVoicePlaying001"],[UIImage imageNamed:@"qm_chat_sendVoicePlaying002"],[UIImage imageNamed:@"qm_chat_sendVoicePlaying003"], nil];
        imageView.image = [UIImage imageNamed:@"qm_chat_sendVoicePlaying"];
    }else {
        images = [NSArray arrayWithObjects:[UIImage imageNamed:@"qm_chat_receiveVoicePlaying001"],[UIImage imageNamed:@"qm_chat_receiveVoicePlaying002"],[UIImage imageNamed:@"qm_chat_receiveVoicePlaying003"], nil];
        imageView.image = [UIImage imageNamed:@"qm_chat_receiveVoicePlaying"];
    }
    imageView.animationImages = images;
}

- (void)stopAudioAnimation {
    if (_animationView) {
        [_animationView stopAnimating];
    }
}

- (void)startAudioAnimation:(UIImageView *)imageView {
    _animationView = imageView;
    imageView.isAnimating ? [imageView stopAnimating] : [imageView startAnimating];
}

- (void)stopAudioAnimation:(UIImageView *)imageView {
    if (imageView) {
        [imageView stopAnimating];
    }else {
        [_animationView stopAnimating];
    }
}

@end
