//
//  QMChatBottomListView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatBottomListView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) void(^tapSendText)(NSString *);

@property (nonatomic, strong) NSArray *dataArr;

- (void)showData:(NSArray *)array;

- (void)setDarkModeColor;

@end

@interface QMChatBottomListCell: UICollectionViewCell

@property (nonatomic, copy) void(^tapBottomText)(NSString *);

@property (nonatomic, copy) NSDictionary *dic;

@property (nonatomic, strong) UIButton *button;

- (void)showLabelText:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
