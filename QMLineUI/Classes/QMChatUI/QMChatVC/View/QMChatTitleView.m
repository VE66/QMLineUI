//
//  QMChatTitleView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "QMChatTitleView.h"
#import "QMChatUI.h"
@implementation QMChatTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.frame = CGRectMake(-20, 10, 20, 20);
    self.activityIndicatorView.backgroundColor = UIColor.clearColor;
    [self.activityIndicatorView hidesWhenStopped];
    [self addSubview:self.activityIndicatorView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.nameLabel];
    
    self.stateInfoLabel = [[UILabel alloc] init];
    self.stateInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.stateInfoLabel.textColor = [UIColor grayColor];
    self.stateInfoLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.stateInfoLabel];
    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor blackColor];
    self.headerLabel.font = [UIFont systemFontOfSize:18];
    self.headerLabel.hidden = YES;
    [self addSubview:self.headerLabel];
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:26]];
    
    self.stateInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stateInfoLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stateInfoLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stateInfoLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stateInfoLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:16]];
    
}

- (void)setDarkModeColor {
    self.nameLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_000000_text];
    self.stateInfoLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_999999_text : QMColor_666666_text];
    self.headerLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_000000_text];
}

- (void)showHeaderStatus:(BOOL)status {
    [self.headerLabel removeFromSuperview];
    if (status) {
        [self addSubview:self.headerLabel];
        self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.headerLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:26]];
        self.headerLabel.hidden = NO;
        self.nameLabel.hidden = YES;
        self.stateInfoLabel.hidden = YES;
        self.headerLabel.text = [NSString stringWithFormat:@"%@%@",self.nameLabel.text, self.stateInfoLabel.text];
    }else {
        self.nameLabel.hidden = NO;
        self.stateInfoLabel.hidden = NO;
    }
}


@end
