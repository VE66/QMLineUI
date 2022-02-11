//
//  SegmentView.m
//  segment
//
//  Created by lishuijiao on 2020/12/10.
//

#import "SegmentView.h"
#import "QMChatUI.h"


#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define ONE_PIXEL (1 / [UIScreen mainScreen].scale)


@interface SegmentCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIFont *titleNomalFont;
@property (nonatomic, strong) UIFont *titleSelectedFont;
@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic) CGFloat animateDuration;
@end

@implementation SegmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.titleLabel.textColor = selected ? self.titleSelectedColor : self.titleNormalColor;
    [UIView animateWithDuration:self.animateDuration animations:^{
        if (selected) {
            self.titleLabel.transform = CGAffineTransformMakeScale(self.fontPointSizeScale, self.fontPointSizeScale);
        } else {
            self.titleLabel.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        self.titleLabel.font = selected ? self.titleSelectedFont : self.titleNomalFont;
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (CGFloat)fontPointSizeScale {
    return self.titleSelectedFont.pointSize / self.titleNomalFont.pointSize;
}

@end



//------------------------------------------------------------------------------------------------------------------------





@interface SegmentView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *vernier;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
//@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) BOOL fixedVernierWidth;
@property (nonatomic) BOOL onceAgainUpdateVernierLocation;
@property (nonatomic) BOOL needDelayUpdateVernierLocation;
@property (nonatomic, strong) MASConstraint *vernierLeftConstraint;
@property (nonatomic, strong) MASConstraint *vernierWidthConstraint;
@property (nonatomic) BOOL needScrollToSelectedItem;

@end

@implementation SegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _selectedIndex = 0;
        _height = 41;
        _vernierHeight = 1.8;
        _itemSpacing = 15;
        _leftMargin = 10;
        _rightMargin = 10;
        _titleNomalFont = [UIFont systemFontOfSize:16];
        _titleSelectedFont = [UIFont systemFontOfSize:17];
        _titleNormalColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
        _titleSelectedColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_News_Custom];
        _animateDuration = 0.1;
        self.vernier.backgroundColor = self.titleSelectedColor;
        [self setupSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 解决self显示出来后vernierLocation没有更新的问题
    if (!self.onceAgainUpdateVernierLocation) {
        self.selectedIndex = self.originalIndex;
    }
}

- (void)changeSelected:(NSUInteger)selectedIndex {
    if (self.collectionView.visibleCells.count > self.selectedIndex && self.selectedIndex != selectedIndex) {
        NSIndexPath *oldIndex = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndex];
        cell.selected = NO;
    }
    self.selectedIndex = selectedIndex;
    if (self.collectionView.visibleCells.count > self.selectedIndex) {
        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:newIndex];
        cell.selected = YES;
    }

}

#pragma mark - Public Method
- (void)scrollToTargetIndex:(NSUInteger)targetIndex sourceIndex:(NSUInteger)sourceIndex percent:(CGFloat)percent {
    SegmentCell *sourceCell = [self getCell:sourceIndex];
    SegmentCell *targetCell = [self getCell:targetIndex];
    
    if (targetCell) {
        CGRect sourceVernierFrame = [self vernierFrameWithIndex:sourceIndex];
        CGRect targetVernierFrame = [self vernierFrameWithIndex:targetIndex];
        CGFloat tempVernierX = sourceVernierFrame.origin.x + (targetVernierFrame.origin.x - sourceVernierFrame.origin.x) * percent;
        CGFloat tempVernierWidth = sourceVernierFrame.size.width + (targetVernierFrame.size.width - sourceVernierFrame.size.width) * percent;
        
        [self.vernierLeftConstraint uninstall];
        [self.vernierWidthConstraint uninstall];
        [self.vernierWidthConstraint uninstall];
        [self.vernier mas_updateConstraints:^(MASConstraintMaker *make) {
            self.vernierLeftConstraint = make.left.mas_equalTo(tempVernierX);
            self.vernierWidthConstraint = make.width.mas_equalTo(tempVernierWidth);
            if (!self.fixedVernierWidth) {
                self->_vernierWidth = tempVernierWidth;
            }
        }];
    }
    
    if (percent > 0.5) {
        sourceCell.selected = NO;
        targetCell.selected = YES;
        
        _selectedIndex = targetIndex;
        
        if (percent == 1.0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            if (!targetCell) {
                self.needDelayUpdateVernierLocation = YES;
            }
        }
    }
}


#pragma mark - Private Method
- (void)setupSubViews {
    [self addSubview:self.topBorder];
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.vernier];
    [self addSubview:self.bottomBorder];
    
    [self.topBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(ONE_PIXEL);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBorder.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(self.height - ONE_PIXEL);
    }];
    [self.vernier mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat collectionViewHeight = self.height - ONE_PIXEL * 2;
        make.top.mas_equalTo(collectionViewHeight - self.vernierHeight);
        make.height.mas_equalTo(self.vernierHeight);
    }];
    [self.bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(ONE_PIXEL);
    }];
}

#pragma mark - Getters
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[SegmentCell class] forCellWithReuseIdentifier:NSStringFromClass([SegmentCell class])];
    }
    return _collectionView;
}

- (UIView *)vernier {
    if (!_vernier) {
        _vernier = [[UIView alloc] init];
    }
    return _vernier;
}

- (UIView *)topBorder {
    if (!_topBorder) {
        _topBorder = [[UIView alloc] init];
        _topBorder.backgroundColor = [UIColor lightGrayColor];
    }
    return _topBorder;
}

- (UIView *)bottomBorder {
    if (!_bottomBorder) {
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomBorder;
}


#pragma mark - Private Method
- (CGFloat)getWidthWithContent:(NSString *)content {
    CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height - ONE_PIXEL)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:self.titleSelectedFont}
                                        context:nil
                   ];
    return ceilf(rect.size.width);
}

- (SegmentCell *)getCell:(NSUInteger)index {
    return (SegmentCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)layoutAndScrollToSelectedItem {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:self.onceAgainUpdateVernierLocation];
    
    if (self.onceAgainUpdateVernierLocation) {
        SegmentCell *selectedCell = [self getCell:self.selectedIndex];
        if (selectedCell) {
            [self updateVernierLocation];
        } else { // 快速滑动
            self.needDelayUpdateVernierLocation = YES;
        }
    } else {
        [self updateVernierLocation];
    }
    
    if ([self.delegate respondsToSelector:@selector(SegmentViewDidSelectedItemAtIndex:)]) {
        [self.delegate SegmentViewDidSelectedItemAtIndex:self.selectedIndex];
    }
}

- (void)updateVernierLocation {
    
    [self.collectionView layoutIfNeeded];
    SegmentCell *cell = [self getCell:self.selectedIndex];
    if (cell) {
        [self.vernierLeftConstraint uninstall];
        [self.vernierWidthConstraint uninstall];
        [self.vernier mas_updateConstraints:^(MASConstraintMaker *make) {
            if (self.fixedVernierWidth) {
                self.vernierLeftConstraint = make.left.equalTo(cell.contentView.mas_centerX).offset(-self.vernierWidth / 2);
                self.vernierWidthConstraint = make.width.mas_equalTo(self.vernierWidth);
            } else {
                self.vernierLeftConstraint = make.left.equalTo(cell.titleLabel);
                self.vernierWidthConstraint = make.width.equalTo(cell.titleLabel);
                self->_vernierWidth = cell.titleLabel.frame.size.width;
            }
        }];
        
        [UIView animateWithDuration:self.animateDuration animations:^{
            [self.collectionView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.onceAgainUpdateVernierLocation = YES;
        }];
    }
}

- (void)updateCollectionViewContentInset {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView layoutIfNeeded];
    CGFloat width = self.collectionView.contentSize.width;
    CGFloat margin;
    if (width > SCREEN_WIDTH) {
        width = SCREEN_WIDTH;
        margin = 0;
    } else {
        margin = (SCREEN_WIDTH - width) / 2.0;
    }
    
    switch (self.alignment) {
        case HGCategoryViewAlignmentLeft:
            self.collectionView.contentInset = UIEdgeInsetsZero;
            break;
        case HGCategoryViewAlignmentCenter:
            self.collectionView.contentInset = UIEdgeInsetsMake(0, margin, 0, margin);
            break;
        case HGCategoryViewAlignmentRight:
            self.collectionView.contentInset = UIEdgeInsetsMake(0, margin * 2, 0, 0);
            break;
    }
}

- (CGRect)vernierFrameWithIndex:(NSUInteger)index {
    SegmentCell *cell = [self getCell:index];
    CGRect titleLabelFrame = [cell convertRect:cell.titleLabel.frame toView:self.collectionView];
    if (self.fixedVernierWidth) {
        return CGRectMake(titleLabelFrame.origin.x + (titleLabelFrame.size.width - self.vernierWidth) / 2,
                          self.collectionView.frame.size.height - self.vernierHeight,
                          self.vernierWidth,
                          self.vernierHeight);
    } else {
        return CGRectMake(titleLabelFrame.origin.x,
                          self.collectionView.frame.size.height - self.vernierHeight,
                          cell.titleLabel.frame.size.width,
                          self.vernierHeight);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self getWidthWithContent:self.titles[indexPath.item]];
    CGFloat height = self.height - ONE_PIXEL * 2;
    return CGSizeMake(self.itemWidth > 0 ? self.itemWidth : width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.itemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, self.leftMargin, 0, self.rightMargin);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SegmentCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = self.titles[indexPath.item];
    cell.titleNomalFont = self.titleNomalFont;
    cell.titleSelectedFont = self.titleSelectedFont;
//    cell.titleNormalColor = self.titleNormalColor;
//    cell.titleSelectedColor = self.titleSelectedColor;
    cell.animateDuration = self.animateDuration;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SegmentCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.selected = self.selectedIndex == indexPath.item;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex == indexPath.item) {
        return;
    }
    
    // 防止快速连续点击导致连续缩放动画
    collectionView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        collectionView.userInteractionEnabled = YES;
    });
    
    SegmentCell *selectedCell = [self getCell:self.selectedIndex];
    selectedCell.selected = NO;
    
    SegmentCell *targetCell = [self getCell:indexPath.item];
    targetCell.selected = YES;
    
    self.selectedIndex = indexPath.item;
    NSLog(@"cellselectedIndex====%lu", (unsigned long)self.selectedIndex);
}

#pragma mark - Setters

- (void)setOriginalIndex:(NSUInteger)originalIndex {
    _originalIndex = originalIndex;
    self.selectedIndex = originalIndex;
    [self resetVernierLocation];
    [self.collectionView reloadData];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (self.titles.count == 0) {
        return;
    }
    
    if (selectedIndex > self.titles.count - 1) {
        _selectedIndex = self.titles.count - 1;
    } else {
        _selectedIndex = selectedIndex;
    }
    [self layoutAndScrollToSelectedItem];
}

- (void)resetVernierLocation {
    self.onceAgainUpdateVernierLocation = NO;
    [self updateVernierLocation];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 如果targetCell不存在，在scrollToItemAtIndexPath动画结束后updateVernierLocation
    if (self.needDelayUpdateVernierLocation) {
        self.needDelayUpdateVernierLocation = NO;
        [self updateVernierLocation];
    }
}

@end



