//
//  QMChatBottomListView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/15.
//

#import "QMChatBottomListView.h"
#import "QMChatShowRichTextController.h"
#import "QMChatUI.h"
@implementation QMChatBottomListView {
    
    UICollectionView *_collectionView;

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return  self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = CGRectMake(0, 0, QM_kScreenWidth, 52);
}

- (void)setDarkModeColor {
    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    [_collectionView reloadData];
}

- (void)createView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, 52) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_Main_Bg_Dark : QMColor_Main_Bg_Light];
    [_collectionView registerClass:[QMChatBottomListCell class] forCellWithReuseIdentifier:NSStringFromClass([QMChatBottomListCell class])];
    [self addSubview:_collectionView];
}

- (void)showData:(NSArray *)array {
    self.dataArr = array;
    [_collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMChatBottomListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QMChatBottomListCell class]) forIndexPath:indexPath];
    [cell showLabelText:self.dataArr[indexPath.row]];
    __weak typeof(self) weakSelf = self;
    cell.tapBottomText = ^(NSString * text) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tapSendText(text);
        });
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat textWidth = [QMLabelText calculateTextWidth:self.dataArr[indexPath.row][@"button"] fontName:QM_PingFangSC_Reg fontSize:16 maxHeight:36];
    return CGSizeMake(textWidth + 24, 36);
}

@end

@implementation QMChatBottomListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.button = [[UIButton alloc] init];
    self.button.frame = CGRectMake(0, 0, 100, 36);
    self.button.backgroundColor = [UIColor whiteColor];
    self.button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [self.button setTitleColor:[UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1] forState:UIControlStateNormal];
    self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = 18;
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.button];
}

- (void)showLabelText:(NSDictionary *)dic {
    self.dic = dic;
    CGFloat textWidth = [QMLabelText calculateTextWidth:dic[@"button"] fontName:QM_PingFangSC_Reg fontSize:16 maxHeight:36];
    [self.button setTitle:dic[@"button"] forState:UIControlStateNormal];
    self.button.frame = CGRectMake(0, 0, textWidth + 24, 36);
    [self.button setTitleColor:[UIColor colorWithHexString:isDarkStyle ? @"#F5F5F5" : QMColor_151515_text] forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor colorWithHexString:isDarkStyle ? @"#262626" : QMColor_News_Agent_Light]];
}

- (void)buttonAction:(UIButton *)button {
    
    NSNumber *typeNum = self.dic[@"button_type"];
    if ([typeNum intValue] == 2) {
        QMChatShowRichTextController *showWebVC = [[QMChatShowRichTextController alloc] init];
        NSString *urlStr = self.dic[@"text"];
        if (urlStr.length > 0) {
            showWebVC.urlStr = urlStr;
            showWebVC.title = self.dic[@"button"];
        }else {
            return;
        }
        showWebVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showWebVC animated:true completion:nil];
    }else {
        self.tapBottomText(self.dic[@"text"]);
    }
}

@end
