//
//  AnswerView.h
//  segment
//
//  Created by lishuijiao on 2020/12/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AnswerViewDelegate <NSObject>
@optional
- (void)pagesViewWillBeginDragging;
- (void)pagesViewDidEndDragging;
- (void)pagesViewScrollingToTargetPage:(NSInteger)targetPage sourcePage:(NSInteger)sourcePage percent:(CGFloat)percent;
- (void)pagesViewWillTransitionToPage:(NSInteger)page;
- (void)pagesViewDidTransitionToPage:(NSInteger)page;
- (void)pagesViewSelectedText:(NSString *)text;
@end


@interface AnswerView : UIView

@property (nonatomic, weak) id<AnswerViewDelegate>delegate;

@property (nonatomic, copy) NSArray *lists;

@property (nonatomic, readonly) NSInteger selectedPage;

- (void)setSelectedPage:(NSInteger)selectedPage animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
