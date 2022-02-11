//
//  QMChatAssociationInputView.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatAssociationInputView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) void(^questionsSelect)(NSString *question);

- (void)showData:(NSArray *)array andInputText:(NSString *)text;

@end

@interface QMChatAssociationInputCell : UITableViewCell

@property (nonatomic, strong) UILabel *questionLabel;

- (void)setText:(NSString *)text withSelectText:(NSString *)selectText;

@end

NS_ASSUME_NONNULL_END
