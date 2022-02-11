//
//  QMChatCommonProblemCell.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/28.
//

#import "QMChatCommonProblemCell.h"
#import "SegmentView.h"
#import "AnswerView.h"
#import "AnswerMoreView.h"

@interface QMChatCommonProblemCell () <SegmentViewDelegate, AnswerViewDelegate>

@property (nonatomic, strong) SegmentView *segmentView;

@property (nonatomic, strong) AnswerView *answerView;

@property (nonatomic, strong) UIImageView *titleImageView;

@property (nonatomic, strong) UIView *moreView;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic) BOOL isDragging;

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, copy) NSMutableArray *nameArray;

@property (nonatomic, copy) NSMutableArray *listArray;

@property (nonatomic, strong) AnswerMoreView *answerMoreView;

@end

@implementation QMChatCommonProblemCell

- (void)createUI {
    [super createUI];
    
    _titleImageView = [[UIImageView alloc] init];
    _titleImageView.image = [UIImage imageNamed:@"qm_common_title"];
    [self.chatBackgroundView addSubview:_titleImageView];
    
    _segmentView = [[SegmentView alloc] init];
    _segmentView.delegate = self;
    _segmentView.alignment = HGCategoryViewAlignmentLeft;
    _segmentView.originalIndex = 0;
    _segmentView.itemSpacing = 25;
    _segmentView.topBorder.hidden = YES;
    [self.chatBackgroundView addSubview:_segmentView];
    
    _answerView = [[AnswerView alloc] init];
    _answerView.delegate = self;
    [self.chatBackgroundView addSubview:_answerView];
    
    _moreView = [[UIView alloc] init];
    _moreView.hidden = YES;
    [self.chatBackgroundView addSubview:_moreView];
    
    _moreButton = [[UIButton alloc] init];
    _moreButton.titleLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:14];
    [_moreButton setTitle:@"查看更多" forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreView addSubview:_moreButton];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.chatBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kChatIconMargin);
        make.right.equalTo(self.contentView).offset(-kChatIconMargin);
        make.top.equalTo(self.iconImage.mas_top).priority(999);
        make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin);
        make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight);
    }];
    
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatBackgroundView).offset(kChatBottomMargin);
        make.left.equalTo(self.chatBackgroundView).offset(QMFixWidth(15));
        make.width.mas_equalTo(155);
        make.height.mas_equalTo(43);
    }];
    
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom);
        make.left.right.equalTo(self.chatBackgroundView);
        make.height.mas_equalTo(40).priority(999);
    }];

    [self.answerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentView.mas_bottom);
        make.left.right.equalTo(self.chatBackgroundView);
        make.height.mas_greaterThanOrEqualTo(200).priority(999);
    }];
    
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.answerView.mas_bottom);
        make.left.right.equalTo(self.chatBackgroundView);
        make.height.mas_greaterThanOrEqualTo(1).priority(999);
        make.bottom.equalTo(self.chatBackgroundView.mas_bottom);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.moreView);
    }];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    
    [super setData:message avater:avater];
    
    self.message = message;
    
    self.iconImage.hidden = YES;
    
    [self setDarkStyle];

    NSData *jsonData = [message.common_questions_group dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *commonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return;
    }

    if (commonArray.count) {
        for (NSDictionary *item in commonArray) {
            NSString *name = item[@"name"];
            NSArray *list = item[@"list"];
            if (name.length) {
                [self.nameArray addObject:name];
            }
            if (list.count) {
                [self.listArray addObject:list];
            }
        }
    }else {
        return;
    }

    if (message.common_questions_img.length > 0) {
        [_titleImageView sd_setImageWithURL:[NSURL URLWithString:message.common_questions_img] placeholderImage:[UIImage imageNamed:@"qm_common_title"]];
    }
    
    if ([message.fromType isEqualToString:@"1"]) {
        
        int cellIndex = message.common_selected_index.intValue;
    
        [_segmentView changeSelected:cellIndex];
        
        [self.answerView setSelectedPage:cellIndex animated:NO];
        
        self.segmentView.titles = self.nameArray;
        self.answerView.lists = self.listArray;
        
        [self.segmentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.segmentView.height).priority(999);
        }];
        
        NSArray *itemArray = self.listArray[cellIndex];

        CGFloat answerHeight = itemArray.count > 5 ? 5 * 45 + 40 : itemArray.count * 45;

        [self.answerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.segmentView.mas_bottom);
            make.left.right.equalTo(self.chatBackgroundView);
            make.height.mas_equalTo(answerHeight).priority(999);
        }];
        
        self.moreView.hidden = itemArray.count > 5 ? NO : YES;
        
        if (self.moreView.hidden == YES) {
            [self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.answerView.mas_bottom);
                make.left.right.equalTo(self.chatBackgroundView);
                make.height.mas_equalTo(1);
                make.bottom.equalTo(self.chatBackgroundView.mas_bottom);
            }];
        } else {
            [self.moreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.answerView.mas_bottom).offset(-39);
                make.left.right.equalTo(self.chatBackgroundView);
                make.bottom.equalTo(self.chatBackgroundView.mas_bottom);
            }];
            
        }
    }
}

- (void)setDarkStyle {
    self.segmentView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    self.segmentView.titleNormalColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_151515_text];
    self.segmentView.titleSelectedColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_FFFFFF_text : QMColor_News_Custom];
    self.moreView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    [self.moreButton setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : QMColor_News_Custom] forState:UIControlStateNormal];
}

#pragma mark - buttonAction
- (void)moreAction:(UIButton *)button {
    if (_answerMoreView) {
        [_answerMoreView removeFromSuperview];
    }
    
    _answerMoreView = [[AnswerMoreView alloc] init];
    _answerMoreView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:_answerMoreView];
    [_answerMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    NSString *index = self.message.common_selected_index.length ? self.message.common_selected_index : @"0";
    [_answerMoreView setModel:self.listArray[[index integerValue]] andTitle:self.nameArray[[index integerValue]]];
    
    @weakify(self)
    _answerMoreView.tapTableView = ^(NSString * _Nonnull text) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tapSendMessage(text, @"");
        });
    };
}

#pragma mark - SegmentViewDelegate
- (void)SegmentViewDidSelectedItemAtIndex:(NSInteger)index {
    self.message.common_selected_index = [NSString stringWithFormat:@"%ld", (long)index];
    self.isDragging = NO;
    [self.answerView setSelectedPage:index animated:NO];
//    if (index != _selectedIndex) {
//        self.selectedIndex = index;
//        self.tapCommonAction(index);
//    }
}

#pragma mark - AnswerViewDelegate
- (void)pagesViewWillBeginDragging {
    self.isDragging = YES;
}

- (void)pagesViewDidEndDragging {

}

- (void)pagesViewScrollingToTargetPage:(NSInteger)targetPage sourcePage:(NSInteger)sourcePage percent:(CGFloat)percent {
    if (!self.isDragging) {
        return;
    }
    [self.segmentView scrollToTargetIndex:targetPage sourceIndex:sourcePage percent:percent];

}

- (void)pagesViewWillTransitionToPage:(NSInteger)page {

}

- (void)pagesViewDidTransitionToPage:(NSInteger)page {
    self.message.common_selected_index = [NSString stringWithFormat:@"%ld", (long)page];
    if (page != _selectedIndex) {
        self.selectedIndex = page;
        self.tapCommonAction(page);
    }
}

- (void)pagesViewSelectedText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tapSendMessage(text, @"");
    });
}

- (NSMutableArray *)listArray {
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}

- (NSMutableArray *)nameArray {
    if (!_nameArray) {
        _nameArray = [NSMutableArray array];
    }
    return _nameArray;
}

@end
