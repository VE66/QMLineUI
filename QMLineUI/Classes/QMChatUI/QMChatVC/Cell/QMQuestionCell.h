//
//  QMQuestionCell.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMQuestionCell : UITableViewCell

@property(nonatomic, copy) void(^cellSelect)(void);

- (void)setCellData:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
