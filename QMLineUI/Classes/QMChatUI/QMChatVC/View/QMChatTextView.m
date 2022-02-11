//
//  QMChatTextView.m
//  IMSDK
//
//  Created by 焦林生 on 2021/12/9.
//

#import "QMChatTextView.h"

@implementation QMChatTextView

- (instancetype)init {
    if (self = [super init]) {
        UIColor *color = [UIColor colorWithRed:32/255.0f green:188/255.0f blue:158/255.0f alpha:1];
        self.linkTextAttributes = @{NSForegroundColorAttributeName: color};
        self.editable = false;
        self.scrollEnabled = false;

    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    if (action == @selector(copy:)) {
        return YES;
    }
    return false;
}

- (void)copy:(id)sender {
    [super copy:sender];
    [self endEditing:YES];
}

@end
