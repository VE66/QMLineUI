//
//  QMChatFormViewController.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatFormViewController : UIViewController

@property (nonatomic, copy) NSArray *formInfoArray;
- (void)setFormInfo:(NSArray *)formInfo;

- (void)show;
@end

NS_ASSUME_NONNULL_END
