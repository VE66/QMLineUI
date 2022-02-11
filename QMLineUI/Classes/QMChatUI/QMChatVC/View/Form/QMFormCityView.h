//
//  QMFormCityView.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMFormCityView : UIView

//@property (nonatomic, strong) void(^selectedItemBlock)(NSArray *addressArr);

@property (nonatomic, copy) void(^selectValue)(NSDictionary *dic);

- (void)setModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
