//
//  QMRemind.m
//  QMLineDemo
//
//  Created by lishuijiao on 2020/5/20.
//  Copyright © 2020 Lisj. All rights reserved.
//

#import "QMRemind.h"
#import "QMChatUI.h"

@implementation QMRemind

+ (UIWindow *)mainWindow {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)]) {
        return [app.delegate window];
    }
    else{
        return [app keyWindow];
    }
}

+ (UIView *)showView {
    UIWindow * window = [self mainWindow];
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.alpha = 0.8;
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    return showview;
}

+ (UILabel *)showLabel {
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectZero;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    return label;
}

+ (void)showMessage:(NSString *)message {
    [self showMessage:message showTime:5];
}

+ (void)showMessage:(NSString *)message showTime:(NSInteger)time {
    __block NSInteger times = time;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *showview = [self showView];
        UILabel *label = [self showLabel];
        [showview addSubview:label];
        label.text = message;
        CGSize LabelSize = [QMLabelText calculateText:message fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:QM_kScreenWidth - 100 maxHeight:0];
        label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
        showview.frame = CGRectMake((QM_kScreenWidth - LabelSize.width - 20)/2, QM_kScreenHeight - label.frame.size.height - 180, LabelSize.width + 20, LabelSize.height + 10);
        times = times <= 0 ? 3 : times;
        [UIView animateWithDuration:times animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    });
}

+ (void)showMessage:(NSString *)message showTime:(NSInteger)time andPosition:(CGFloat)position {
    __block NSInteger times = time;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *showview = [self showView];
        UILabel *label = [self showLabel];
        [showview addSubview:label];
        label.text = message;
        CGSize LabelSize = [QMLabelText calculateText:message fontName:QM_PingFangSC_Reg fontSize:14 maxWidth:QM_kScreenWidth - 100 maxHeight:0];
        label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
        showview.frame = CGRectMake((QM_kScreenWidth - LabelSize.width - 20)/2, position, LabelSize.width + 20, LabelSize.height + 10);
        times = times <= 0 ? 3 : times;
        [UIView animateWithDuration:times animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    });

}
    
@end
