//
//  QMChatRoomViewController+ChatMessage.h
//  IMSDK
//
//  Created by 焦林生 on 2022/1/10.
//

#import "QMChatRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMChatRoomViewController (ChatMessage)

//发送文本
- (void)sendText:(NSString *)text;
//发送图片
- (void)sendImage:(UIImage *)image;
//发送语音
- (void)sendAudio:(NSString *)fileName duration:(NSString *)duration;
// 发送文件
- (void)sendFileMessageWithName: (NSString *)fileName AndSize: (NSString *)fileSize AndPath: (NSString *)filePath;
//商品卡片
- (void)insertCardInfoMessage;
- (void)insertNewCardInfoMessage;


@end

NS_ASSUME_NONNULL_END
