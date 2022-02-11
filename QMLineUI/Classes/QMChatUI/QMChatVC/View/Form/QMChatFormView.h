//
//  QMChatFormView.h
//  IMSDK
//
//  Created by lishuijiao on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatFormView : UIView

//原始数据
@property (nonatomic, strong) NSDictionary *dataDic;

//标题
@property (nonatomic, copy) NSString *title;

//备注
@property (nonatomic, copy) NSString *note;

//消息id
@property (nonatomic, copy) NSString *messageId;

- (void)setFormInfoArr:(NSArray *)formInfo;

@end

NS_ASSUME_NONNULL_END
