//
//  QMChatFlowView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatFlowView : UIView

@property (nonatomic, copy) void(^selectAction)(NSDictionary *);

@property (nonatomic, copy) void(^tapFlowNumberAction)(NSString *);

@property (nonatomic, copy) void(^tapFlowUrlAction)(NSString *);

//多选时点击item
@property (nonatomic, copy) void(^tapSelectAction)(NSArray *);

@property (nonatomic, copy) NSString *flowList;

@property (nonatomic, copy) NSString *flowTip;

@property (nonatomic, copy) NSString *flowType;

@property (nonatomic, assign) BOOL flowSelset;

@property (nonatomic, assign) BOOL flowSend;

@property (nonatomic, assign) BOOL isVertical;

@property (nonatomic, copy) NSString *robotFlowTip;

- (void)setDate;

- (void)setDarkModeColor;

@end

@interface QMChatRobotFlowCollectionCell : UICollectionViewCell

- (void)showData:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
