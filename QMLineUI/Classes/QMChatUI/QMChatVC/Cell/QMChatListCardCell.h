//
//  QMChatListCardCell.h
//  IMSDK
//
//  Created by lishuijiao on 2021/7/27.
//

#import "QMChatBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMChatListCardCell : QMChatBaseCell

@end

@interface QMChatListCardCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary *configureDic;

@end

NS_ASSUME_NONNULL_END
