//
//  QMChatTitleView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatTitleView : UIView

@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UILabel *stateInfoLabel;

@property (nonatomic, assign)CGSize intrinsicContentSize;

@property (nonatomic, strong)UILabel *headerLabel;

- (void)showHeaderStatus:(BOOL)status;

- (void)setDarkModeColor;

@end

NS_ASSUME_NONNULL_END
