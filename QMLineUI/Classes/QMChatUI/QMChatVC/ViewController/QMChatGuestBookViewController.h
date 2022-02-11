//
//  QMChatGuestBookViewController.h
//  IMSDK
//
//  Created by lishuijiao on 2020/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatGuestBookViewController : UIViewController

@property (nonatomic, copy) NSString *peerId;
//留言板标题
@property (nonatomic, copy) NSString *headerTitle;

@property (nonatomic, copy) NSArray *contactFields; // 自定义联系字段

@property (nonatomic, copy) NSString *leaveMsg; // 留言内容

@property (nonatomic, assign) BOOL isScheduleLeave; //是否是日程管理留言

@end

NS_ASSUME_NONNULL_END
