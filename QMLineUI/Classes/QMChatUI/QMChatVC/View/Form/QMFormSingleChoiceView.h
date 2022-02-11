//
//  QMFormSingleChoiceView.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMFormSingleChoiceView : UIView

@property (nonatomic, copy) void(^selectValue)(NSDictionary *dic);

- (void)setModel:(NSDictionary *)model;

@end

@interface FormSingleChoiceCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *selectLabel;

- (void)setTitle:(NSString *)title isSelect:(BOOL )isSelect;

@end

NS_ASSUME_NONNULL_END
