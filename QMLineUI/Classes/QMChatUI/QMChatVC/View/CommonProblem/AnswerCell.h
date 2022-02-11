//
//  AnswerCell.h
//  segment
//
//  Created by lishuijiao on 2020/12/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnswerCell : UICollectionViewCell

@property (nonatomic, copy) void(^selectAction)(NSString *);

@property (nonatomic, copy) NSArray *lists;

@end

@interface AnswerTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *lineView;

@end

NS_ASSUME_NONNULL_END
