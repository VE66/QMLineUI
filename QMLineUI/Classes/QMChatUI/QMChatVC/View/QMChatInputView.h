//
//  QMChatInputView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol inputeViewDelegate <NSObject>

- (void)inputButtonAction:(UIButton *)button index:(int)index;

@end

@interface QMChatInputView : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<inputeViewDelegate> delegate;
@property (nonatomic ,strong)UITextView *inputView; // 输入栏
@property (nonatomic ,strong)UIButton * voiceButton; // 声音按钮
@property (nonatomic ,strong)UIButton * RecordBtn; // 录音按钮
@property (nonatomic ,strong)UIButton * faceButton; // 表情按钮
@property (nonatomic ,strong)UIButton * addButton; // 扩展按钮
@property (nonatomic ,strong)UIView *coverView; // 限制出入蒙版
@property (nonatomic ,strong)UIView *backView; //输入栏和表情底部view

- (void)setDarkModeColor;

/**
 录音按钮显示切换
 */
- (void)showRecordButton: (BOOL)show;

/**
 表情面板显示切换
 */
- (void)showEmotionView: (BOOL)show;


/**
 扩展面板显示切换
 */
- (void)showMoreView: (BOOL)show;

@end

NS_ASSUME_NONNULL_END
