//
//  QMFormDateView.m
//  IMSDK
//
//  Created by lishuijiao on 2021/1/13.
//

#import "QMFormDateView.h"
#import "QMChatUI.h"
static NSString *const defaultBirthdayDate = @"1993-01-01";
static NSString *const defaultDateFormat = @"yyyy-MM-dd";
static CGFloat contentHeiht = 228.0;

@interface QMFormDateView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) dateChooseFinishedBlock finishedBlock;
@property (nonatomic, copy) dateChooseCancelBlock cancelBlock;
@property (nonatomic, copy) NSString *defaultDate;
@property (nonatomic, copy) NSString *dateFormat;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *backgroudContentView;

@end

@implementation QMFormDateView

+ (instancetype)showDateChooseViewWithDefaultDate:(NSString *)defaultDate dateFormat:(NSString *)dateFormat finishedBlock:(dateChooseFinishedBlock)finishedBlock cancelBlock:(dateChooseCancelBlock)cancelBlock{
    QMFormDateView *datePickerView = [[QMFormDateView alloc] init];
    datePickerView.defaultDate = [defaultDate copy];
    datePickerView.dateFormat = [dateFormat copy];
    datePickerView.cancelBlock = nil;
    datePickerView.finishedBlock = nil;
    if (cancelBlock) {
        datePickerView.cancelBlock = [cancelBlock copy];
    }
    if (finishedBlock) {
        datePickerView.finishedBlock = [finishedBlock copy];
    }
    [datePickerView updateDatePickerDate];
    return datePickerView;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupViewsAndData];
    }
    return self;
}

- (void)setupViewsAndData{
    [self layoutCustomViews];
    [self updateDatePickerDate];
    [self addGestureForBgView];
    [self showAnimate];
}

- (void)layoutCustomViews{
    self.frame = [UIScreen mainScreen].bounds;
    
    CGRect re = self.frame;
    if (QM_IS_iPHONEX) {
        re.size.height -= 34.0f;
        self.frame = re;
    }
    self.alpha = 0;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.backgroudContentView];
    [self.backgroudContentView addSubview:self.cancelButton];
    [self.backgroudContentView addSubview:self.confirmButton];
    [self.backgroudContentView addSubview:self.bottomLine];
    [self.backgroudContentView addSubview:self.datePicker];
}

- (void)addGestureForBgView {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)hide:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self hideAnimateWithSelectedStatus:NO];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.backgroudContentView.frame, touchPoint)) {
        return NO;
    }
    return YES;
}

- (void)setDefaultDate:(NSString *)defaultDate dateFormat:(NSString *)dateFormat {
    if (!defaultDate.length) {
        return;
    }
    self.defaultDate = [defaultDate copy];
    self.dateFormat = [dateFormat copy];
}

- (void)updateDatePickerDate {
    if (!self.defaultDate.length) {
        [self.datePicker setDate:[NSDate date]];
        return;
    }
    NSDate *date = [self stringToDate:self.defaultDate format:(self.dateFormat.length) ? self.dateFormat : defaultDateFormat];
    if (!date) {
        date = [self stringToDate:defaultBirthdayDate format:defaultDateFormat];
    }
    [self.datePicker setDate:date];
}

- (void)buttonOnclick:(UIButton *)button{
    if (button == self.confirmButton) {
        [self hideAnimateWithSelectedStatus:YES];
    }else{
        [self hideAnimateWithSelectedStatus:NO];
    }
}

#pragma mark animate
-(void)showAnimate {
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0f;
        CGRect re = self.frame;
        re.origin.y = re.size.height - contentHeiht;
        self.backgroudContentView.frame = re;
    } completion:^(BOOL finished) {
    }];
}

-(void)hideAnimateWithSelectedStatus:(BOOL)status {
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect re = self.frame;
        re.origin.y = re.size.height - contentHeiht;
        self.backgroudContentView.frame = re;
        self.alpha = .0f;
    } completion:^(BOOL finished) {
        if (status) {
            if (self.finishedBlock) {
                self.finishedBlock([self dateToString:self.datePicker.date format:(self.dateFormat.length) ? self.dateFormat : defaultDateFormat]);
                self.finishedBlock = nil;
            }
        }else{
            if (self.cancelBlock) {
                self.cancelBlock();
                self.cancelBlock = nil;
            }
        }
        [self removeFromSuperview];
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }];
}

-(UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:QMColor_333333_text] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(buttonOnclick:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.frame = CGRectMake(QM_kScreenWidth - 53, 0, 30, 44);
    }
    return _confirmButton;
}

-(UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:QMColor_333333_text] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(buttonOnclick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.frame = CGRectMake(22, 0, 30, 44);
    }
    return _cancelButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 44, QM_kScreenWidth, 1)];
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"E4E4E4"];
    }
    return _bottomLine;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44 , QM_kScreenWidth, contentHeiht - 44)];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _datePicker.locale = locale;
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.backgroundColor = [UIColor whiteColor];
    }
    return _datePicker;
}

- (UIView *)backgroudContentView {
    if (!_backgroudContentView) {
        _backgroudContentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - contentHeiht, QM_kScreenWidth, contentHeiht)];
        _backgroudContentView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroudContentView;
}

- (NSDate *)stringToDate:(NSString *)dateString format:(NSString *)format {
    if (!dateString.length) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:format];
    NSDate *dateFormatted = [dateFormatter dateFromString:dateString];
    return dateFormatted;
}

- (NSString *)dateToString:(nullable NSDate *)date format:(NSString *)format {
    if (![date isKindOfClass:[NSDate class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.locale = locale;
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}


@end
