//
//  QMChatShowRichTextController.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatShowRichTextController : UIViewController

@property (nonatomic, copy) NSString *urlStr;

//用于机器人表单消息附件展示
@property (nonatomic, assign)BOOL isForm;

@end

NS_ASSUME_NONNULL_END
