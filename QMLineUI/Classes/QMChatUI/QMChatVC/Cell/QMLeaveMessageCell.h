//
//  QMLeaveMessageCell.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMLeaveMessageCell : UITableViewCell

@property (nonatomic, copy) void(^backValue)(NSString *);

- (void)setModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
