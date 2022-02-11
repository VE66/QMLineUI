//
//  NSObject+QMUIKit_OC.m
//  IMSDK
//
//  Created by 焦林生 on 2021/10/20.
//

#import "NSObject+QMUIKit_OC.h"
#import <objc/runtime.h>
@implementation NSObject (QMUIKit_OC)

@end

@implementation UIButton (QMCategory)

static char MSExtendEdgeKey;


- (void)layoutButtonWithEdgeInsetsStyle:(QMButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space {
    
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    /**
     MKButtonEdgeInsetsStyleTop, // image在上，label在下
     MKButtonEdgeInsetsStyleLeft, // image在左，label在右
     MKButtonEdgeInsetsStyleBottom, // image在下，label在上
     MKButtonEdgeInsetsStyleRight // image在右，label在左
     */
    switch (style) {
        case QMButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case QMButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case QMButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case QMButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}


- (void)extendTouchArea:(UIEdgeInsets)edgeArea {
    objc_setAssociatedObject(self, &MSExtendEdgeKey, [NSValue valueWithUIEdgeInsets:edgeArea], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIEdgeInsets edge = [objc_getAssociatedObject(self, &MSExtendEdgeKey) UIEdgeInsetsValue];
    
    CGRect extendArea = self.bounds;
    if (edge.left || edge.right || edge.top || edge.bottom) {
        extendArea = CGRectMake(self.bounds.origin.x - edge.left,
                                self.bounds.origin.y - edge.top,
                                self.bounds.size.width + edge.left + edge.right,
                                self.bounds.size.height + edge.top + edge.bottom);
    }
    return CGRectContainsPoint(extendArea, point);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage createImageWithColor:backgroundColor] forState:state];
}

@end

@implementation UIImage (QMImage)

+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end

@interface UIControl ()
/// 是否忽略点击事件；YES，忽略点击事件，NO，允许点击事件
@property (nonatomic, assign) BOOL isIgnoreEvent;
@end

@implementation UIControl(QMCategory)

static const CGFloat QMEventDefaultTimeInterval = 0;

#pragma mark -- 按钮事件点击间隔
- (BOOL)isIgnoreEvent {
    return [objc_getAssociatedObject(self, @"isIgnoreEvent") boolValue];
}

- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent {
    objc_setAssociatedObject(self, @"isIgnoreEvent", @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)QM_eventTimeInterval {
    return [objc_getAssociatedObject(self, @"QM_eventTimeInterval") doubleValue];
}

- (void)setQM_eventTimeInterval:(NSTimeInterval)QM_eventTimeInterval {
    objc_setAssociatedObject(self, @"QM_eventTimeInterval", @(QM_eventTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL systemSEL = @selector(sendAction:to:forEvent:);
        SEL replaceSEL = @selector(QM_sendAction:to:forEvent:);
        Method systemMethod = class_getInstanceMethod(self, systemSEL);
        Method replaceMethod = class_getInstanceMethod(self, replaceSEL);
        
        BOOL isAdd = class_addMethod(self, systemSEL, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod));
        
        if (isAdd) {
            class_replaceMethod(self, replaceSEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        } else {
            // 添加失败，说明本类中有 replaceMethod 的实现，此时只需要将 systemMethod 和 replaceMethod 的IMP互换一下即可
            method_exchangeImplementations(systemMethod, replaceMethod);
        }
    });
}

- (void)QM_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([target isKindOfClass:NSClassFromString(@"UISwipeActionPullView")]) {
        [self setIsIgnoreEvent:NO];
        [self QM_sendAction:action to:target forEvent:event];
    }else {

    self.QM_eventTimeInterval = self.QM_eventTimeInterval == 0 ? QMEventDefaultTimeInterval : self.QM_eventTimeInterval;
    if (self.isIgnoreEvent){
        return;
    } else if (self.QM_eventTimeInterval >= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.QM_eventTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setIsIgnoreEvent:NO];
        });
    }
    self.isIgnoreEvent = YES;
    [self QM_sendAction:action to:target forEvent:event];
          
    }
}

@end


@implementation NSString (QMString)

+ (NSString *)getTimeDate:(NSDate *)date timeStatus:(BOOL)status {
    NSString *ret = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 当前时间
    NSDate *currentDate = [NSDate date];
    NSDateComponents *curComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:currentDate];
    
    NSInteger currentYear = [curComponents year];
    NSInteger currentMonth = [curComponents month];
    NSInteger currentDay = [curComponents day];

    // 目标判断时间
    NSDateComponents *srcComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    NSInteger srcYear = [srcComponents year];
    NSInteger srcMonth = [srcComponents month];
    NSInteger srcDay = [srcComponents day];

   // 要额外显示的时间分钟
    NSString *timeExtraStr = (status ? [self getTimeString:date format:@"HH:mm"] : @"");
    // 当年
    if (currentYear == srcYear) {
        long currentTimestamp = [self getTimeStamp:currentDate];
        long srcTimestamp = [self getTimeStamp:date];
        // 相差时间（单位：秒）
        long delta = currentTimestamp - srcTimestamp;
        // 当天（月份和日期一致才是）
        if(currentMonth == srcMonth && currentDay == srcDay) {
            // 时间相差60秒以内
            if (delta < 60) {
                ret = @"刚刚";
            }else {
                // 否则当天其它时间段的，直接显示“时:分”的形式
                ret = [self getTimeString:date format:@"HH:mm"];
            }
        }else {
            // 当年 && 当天之外的时间（即昨天及以前的时间）
            // 昨天（以“现在”的时候为基准-1天）
            NSDate *yesterdayDate = [NSDate date];
            yesterdayDate = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:yesterdayDate];
            NSDateComponents *yesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:yesterdayDate];
            NSInteger yesterdayMonth = [yesterdayComponents month];
            NSInteger yesterdayDay = [yesterdayComponents day];
            // 前天（以“现在”的时候为基准-2天）
            NSDate *beforeYesterdayDate = [NSDate date];
            beforeYesterdayDate = [NSDate dateWithTimeInterval:-48*60*60 sinceDate:beforeYesterdayDate];
            NSDateComponents *beforeYesterdayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:beforeYesterdayDate];
            NSInteger beforeYesterdayMonth = [beforeYesterdayComponents month];
            NSInteger beforeYesterdayDay = [beforeYesterdayComponents day];
            // 用目标日期的“月”和“天”跟上方计算出来的“昨天”进行比较，是最为准确的（如果用时间戳差值
            // 的形式，是不准确的，比如：现在时刻是2019年02月22日1:00、而srcDate是2019年02月21日23:00，
            // 这两者间只相差2小时，直接用“delta/3600” > 24小时来判断是否昨天，就完全是扯蛋的逻辑了）
            if (srcMonth == yesterdayMonth && srcDay == yesterdayDay) {
                ret = [NSString stringWithFormat:@"昨天%@", timeExtraStr]; // -1d
            }else if (srcMonth == beforeYesterdayMonth && srcDay == beforeYesterdayDay) {
                ret = [NSString stringWithFormat:@"前天%@", timeExtraStr]; // -2d
            }else {
                // 跟当前时间相差的小时数
                long deltaHour = (delta/3600);
                // 如果小于或等 7*24小时就显示星期几
                if (deltaHour <= 7*24) {
                    NSArray *weekdayAry = [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
                    // 取出的星期数：1表示星期天，2表示星期一，3表示星期二。。。。 6表示星期五，7表示星期六
                    NSInteger srcWeekday = [srcComponents weekday];
                    // 取出当前是星期几
                    NSString *weedayDesc = [weekdayAry objectAtIndex:(srcWeekday-1)];
                    ret = [NSString stringWithFormat:@"%@%@",weedayDesc, timeExtraStr];
                }else {
                    ret = [NSString stringWithFormat:@"%@%@",[self getTimeString:date format:@"yyyy/M/d"], timeExtraStr];
                }
            }
        }
    }else {
        // 往年
        ret = [NSString stringWithFormat:@"%@%@", [self getTimeString:date format:@"yyyy/M/d"], timeExtraStr];
    }
    return ret;
}

+ (NSString*)getTimeString:(NSDate*)date format:(NSString*)fmt {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:fmt];
    return [format stringFromDate:(date == nil ? [self getiOSDefaultDate] : date)];
}

// 获得指定NSDate对象iOS时间戳（格式遵从ios的习惯，以秒为单位）。
+ (long)getTimeStamp:(NSDate*)date {
    NSTimeInterval interval = [date timeIntervalSince1970];
    long time  = [[NSNumber numberWithDouble:interval] longValue];
    return time;
}

+ (NSDate*)getiOSDefaultDate {
    return [NSDate date];
}

@end


