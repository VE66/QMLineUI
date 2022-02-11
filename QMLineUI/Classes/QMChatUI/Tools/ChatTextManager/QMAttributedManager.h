//
//  QMAttributedManager.h
//  Demo-C
//
//  Created by ZCZ on 2021/6/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface QMAttributedManager : NSObject
@property (nonatomic, strong) UIFont *font;

+ (instancetype)shared;
- (NSAttributedString *)filterText:(NSString *)text;
- (NSAttributedString *)filterText:(NSString *)text skipFilterPhoneNum:(BOOL)skipPhoneNum;
- (NSAttributedString *)filterString:(NSString *)text font:(UIFont *)font;
- (NSAttributedString *)filterString:(NSString *)text font:(UIFont *)font skipFilterPhoneNum:(BOOL)skipPhoneNum;
- (NSAttributedString *)filterAttributedString:(NSAttributedString *)text font:(UIFont *)font;
- (NSAttributedString *)filterAttributedString:(NSAttributedString *)text font:(UIFont *)font skipFilterPhoneNum:(BOOL)skipPhoneNum;
@end

NS_ASSUME_NONNULL_END
