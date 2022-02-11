//
//  AnswerMoreView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnswerMoreView : UIView

@property (nonatomic, strong) void(^tapTableView)(NSString *);

- (void)setModel:(NSArray *)array andTitle:(NSString *)title;

@end

@interface AnswerMoreCell : UITableViewCell

@property (nonatomic, copy) UILabel *titleLabel;

@property (nonatomic, strong) UIView *lineView;

@end


NS_ASSUME_NONNULL_END
