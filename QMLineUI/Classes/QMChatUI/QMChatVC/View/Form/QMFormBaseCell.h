//
//  QMFormBaseCell.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMFormBaseCell : UITableViewCell

@property (nonatomic, strong) void(^baseSelectValue)(NSDictionary *dic);

@property (nonatomic, strong) void(^baseSelectArray)(NSArray *array);

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *flagLabel;

- (void)setModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
