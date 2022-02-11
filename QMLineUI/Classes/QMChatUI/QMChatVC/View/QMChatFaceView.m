//
//  QMChatFaceView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/13.
//

#import "QMChatFaceView.h"
#import "QMChatUI.h"
#define FaceSectionBarHeight  46   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

#define Pages 2

@implementation QMChatFaceView {
    UIPageControl *pageControl;
    UIScrollView *scrollView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [scrollView removeFromSuperview];
    [pageControl removeFromSuperview];
    [self.sendButton removeFromSuperview];
    [self createView];
    scrollView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_1E1E1E_BG : QMColor_F6F6F6_BG];
}

- (void)createView{
    self.backgroundColor = [UIColor whiteColor];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,5.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-(QM_IS_iPHONEX ? 34 : 0)-FacePageControlHeight-FaceSectionBarHeight)];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame)*Pages,CGRectGetHeight(scrollView.frame))];
    
    for (int i= 0;i<Pages;i++) {
        TCFaceView *faceView = [[TCFaceView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(scrollView.bounds)) forIndexPath:i];
        [scrollView addSubview:faceView];
        faceView.delegate = self;
    }
    
    pageControl = [[UIPageControl alloc]init];
    [pageControl setFrame:CGRectMake(0,CGRectGetMaxY(scrollView.frame),CGRectGetWidth(self.bounds),FacePageControlHeight)];
    [self addSubview:pageControl];
    [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    pageControl.numberOfPages = Pages;
    pageControl.currentPage   = 0;
        
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(self.bounds.size.width-70, self.bounds.size.height-(QM_IS_iPHONEX ? 34 : 0)-30, 50, 30);
    self.sendButton.backgroundColor = [UIColor colorWithRed:13/255.0 green:139/255.0 blue:249/255.0 alpha:1];
    [self.sendButton setTitle:NSLocalizedString(@"button.send", nil) forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)buttonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendFaceAction)]) {
        [self.delegate sendFaceAction];
    }
}

#pragma mark  scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x/320;
    pageControl.currentPage = page;
}

#pragma mark ZBFaceView Delegate
- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del {
    if ([self.delegate respondsToSelector:@selector(SendTheFaceStr:isDelete:)]) {
        [self.delegate SendTheFaceStr:faceName isDelete:del];
    }
}

@end
