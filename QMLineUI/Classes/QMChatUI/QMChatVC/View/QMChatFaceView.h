//
//  QMChatFaceView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "TCFaceView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol faceViewDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele;

- (void)sendFaceAction;

@end

@interface QMChatFaceView : UIView <UIScrollViewDelegate, TCFaceViewDelegate>

@property (nonatomic,weak)id<faceViewDelegate>delegate;

@property (nonatomic, strong)UIButton * sendButton;

@end


NS_ASSUME_NONNULL_END
