//
//  QMRecordIndicatorView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    QMIndicatorStatusShort = 1,
    QMIndicatorStatusLong,
    QMIndicatorStatusNormal,
    QMIndicatorStatusCancel
}QMIndicatorStatus;

@interface QMRecordIndicatorView : UIView

@property (nonatomic, assign) int count;

@property (nonatomic, assign) BOOL isCount;

-(void)updateImageWithPower: (float)power;

- (void)changeViewStatus:(QMIndicatorStatus)status;

@end

NS_ASSUME_NONNULL_END
