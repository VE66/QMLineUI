//
//  QMCustomLayout.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMCustomLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;

@property (nonatomic) CGFloat minimumInteritemSpacing;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic, assign) BOOL isVertical;

@end

NS_ASSUME_NONNULL_END
