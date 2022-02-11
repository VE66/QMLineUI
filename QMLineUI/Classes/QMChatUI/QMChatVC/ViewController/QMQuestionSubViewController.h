//
//  QMQuestionSubViewController.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import "QMQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMQuestionSubViewController : UIViewController

@property(nonatomic, strong) QMQuestionModel *groupModel;

@property(nonatomic, copy) void(^backQuestion)(QMQuestionModel *);

@end

NS_ASSUME_NONNULL_END
