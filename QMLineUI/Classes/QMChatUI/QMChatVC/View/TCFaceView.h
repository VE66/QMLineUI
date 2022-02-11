//
//  TCFaceView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCFaceViewDelegate <NSObject>
@optional

/*
 * 点击表情代理
 * @param faceName 表情对应的名称
 * @param del      是否点击删除
 *
 */
- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del;

@end

@interface TCFaceView : UIView

@property (nonatomic,weak) id<TCFaceViewDelegate>delegate;

/*
 * 初始化表情页面
 * @param frame     大小
 * @param indexPath 创建第几个
 *
 */
- (id)initWithFrame:(CGRect)frame forIndexPath:(int)index;


@end

NS_ASSUME_NONNULL_END
