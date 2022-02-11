//
//  AnswerView.m
//  segment
//
//  Created by lishuijiao on 2020/12/11.
//

#import "AnswerView.h"
#import "AnswerCell.h"
#import "Masonry.h"

@interface AnswerView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic) CGFloat contentOffsetXWhenBeginDragging;

@property (nonatomic) CGFloat answerWidth;

@property (nonatomic) CGFloat answerHeight;

@end

@implementation AnswerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    [self addSubview:self.collectionView];
//    self.collectionView.layer.borderColor = UIColor.blueColor.CGColor;
//    self.collectionView.layer.borderWidth = 4;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self);
        make.edges.equalTo(self);
//        make.height.mas_equalTo(self->_answerHeight);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _answerWidth = self.frame.size.width;
    _answerHeight = self.frame.size.height;
    _layout.itemSize = CGSizeMake(_answerWidth, _answerHeight);
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(self->_answerHeight);
    }];
    
//    [self.collectionView layoutIfNeeded];
//    [self.collectionView updateConstraintsIfNeeded];

//    [self.collectionView reloadData];
    
//    NSLog(@"layoutSubviews高度===%f", self.frame.size.height);
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self);
//        make.height.mas_equalTo(self->_answerHeight);
//    }];
//    [self setupSubViews];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.minimumInteritemSpacing = 0;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(100, 200);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[AnswerCell class] forCellWithReuseIdentifier:NSStringFromClass([AnswerCell class])];
    }
    return _collectionView;
}

#pragma mark - Public Methods
- (void)setSelectedPage:(NSInteger)selectedPage animated:(BOOL)animated {
    _selectedPage = [self getRightPage:selectedPage];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectedPage inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [self.collectionView scrollToItemAtIndexPath:indexPath
        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                animated:animated];
    } else {
        [self.collectionView setContentOffset:CGPointMake(self.frame.size.width * selectedPage, 0) animated:false];
    }
    
    [self.collectionView reloadData];

}

#pragma mark - Private Methods
- (NSInteger)getRightPage:(NSInteger)page {
    if (page <= 0) {
        return 0;
    } else if (page >= self.lists.count) {
        return self.lists.count - 1;
    } else {
        return page;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (self.lists.count) {
//        CGFloat height = self.lists.count * 45;
//        return CGSizeMake(_answerWidth, height);
//    }else {
//        return CGSizeMake(_answerWidth, _answerHeight);
//    }
//}

//定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//定义整个CollectionViewCell与整个View的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnswerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AnswerCell class]) forIndexPath:indexPath];
//    NSLog(@"indexPath.item====%ld", (long)indexPath.item);
    cell.lists = self.lists[indexPath.item];
    cell.selectAction = ^(NSString * _Nonnull text) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(pagesViewSelectedText:)]) {
                [self.delegate pagesViewSelectedText:text];
            }
        });
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(AnswerCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagesViewWillTransitionToPage:)]) {
        [self.delegate pagesViewWillTransitionToPage:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.contentOffsetXWhenBeginDragging = scrollView.contentOffset.x;
    if ([self.delegate respondsToSelector:@selector(pagesViewWillBeginDragging)]) {
        [self.delegate pagesViewWillBeginDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(pagesViewDidEndDragging)]) {
        [self.delegate pagesViewDidEndDragging];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pagesViewScrollingToTargetPage:sourcePage:percent:)]) {
        
        CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
        NSInteger leftPage = floor(scale);
        NSInteger rightPage = ceil(scale);
        
        if (scrollView.contentOffset.x > self.contentOffsetXWhenBeginDragging) { // 向右切换
            if (leftPage == rightPage) {
                leftPage = rightPage - 1;
            }
//            if (rightPage < self.titles.count) {
            if (rightPage < self.lists.count) {
                [self.delegate pagesViewScrollingToTargetPage:rightPage sourcePage:leftPage percent:scale - leftPage];
            }
        } else { // 向左切换
            if (leftPage == rightPage) {
                rightPage = leftPage + 1;
            }
//            if (rightPage < self.titles.count) {
            if (rightPage < self.lists.count) {
                [self.delegate pagesViewScrollingToTargetPage:leftPage sourcePage:rightPage percent:1 - (scale - leftPage)];
            }
        }
    }
    
    // 防止连续快速滑动
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrollingAnimation:) object:nil];
    
    if ([self.collectionView indexPathsForVisibleItems].count == 1) {
        _selectedPage = [[self.collectionView indexPathsForVisibleItems] firstObject].item;
        if ([self.delegate respondsToSelector:@selector(pagesViewDidTransitionToPage:)]) {
            [self.delegate pagesViewDidTransitionToPage: self.selectedPage];
        }
    }
}


//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    // 如果targetCell不存在，在scrollToItemAtIndexPath动画结束后updateVernierLocation
//    if (self.needDelayUpdateVernierLocation) {
//        self.needDelayUpdateVernierLocation = NO;
//        [self updateVernierLocation];
//    }
//}

#pragma mark ---

//- (void)pagesViewControllerScrollingToTargetPage:(NSInteger)targetPage sourcePage:(NSInteger)sourcePage percent:(CGFloat)percent {
//    if (!self.isDragging) {
//        return;
//    }
//    [self.categoryView scrollToTargetIndex:targetPage sourceIndex:sourcePage percent:percent];
//}

//- (void)updataCollectionViewHeight:(CGFloat)height {
//    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(height);
//    }];
//}

@end
