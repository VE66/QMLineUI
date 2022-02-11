//
//  QMChatMoreView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatMoreView : UIView

@property (nonatomic, strong) UIButton *takePicBtn; //取图片
@property (nonatomic, strong) UIButton *takeFileBtn; //取文件
@property (nonatomic, strong) UIButton *evaluateBtn; //评价
@property (nonatomic, strong) UIButton *questionBtn; //常见问题
@property (nonatomic, strong) UIButton *videoBtn; //视频

@end

@interface BottomTitleBtn : UIButton

@end

NS_ASSUME_NONNULL_END
