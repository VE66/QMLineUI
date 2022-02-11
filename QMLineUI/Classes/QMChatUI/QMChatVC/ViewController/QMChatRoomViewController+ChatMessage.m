//
//  QMChatRoomViewController+ChatMessage.m
//  IMSDK
//
//  Created by 焦林生 on 2022/1/10.
//

#import "QMChatRoomViewController+ChatMessage.h"
#import "QMChatUI.h"

@implementation QMChatRoomViewController (ChatMessage)

#pragma mark - sendMessage
//发送文本
- (void)sendText:(NSString *)text {
    [QMConnect sendMsgText:text successBlock:^{
        QMLog(@"发送成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createNSTimer];
            self.isSpeak = true;
        });
    } failBlock:^(NSString *reason){
        QMLog(@"发送失败");
        [QMRemind showMessage:reason];
    }];
}

//发送图片
- (void)sendImage:(UIImage *)image {
    [QMConnect sendMsgPic:image successBlock:^{
        QMLog(@"图片发送成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createNSTimer];
            self.isSpeak = true;
        });
    } failBlock:^(NSString *reason){
        QMLog(@"图片发送失败");
    }];
}

//发送语音
- (void)sendAudio:(NSString *)fileName duration:(NSString *)duration {
    NSString *filePath = [NSString stringWithFormat:@"%@.mp3", fileName];
    [QMConnect sendMsgAudio:filePath duration:duration successBlock:^{
        QMLog(@"语音发送成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createNSTimer];
            self.isSpeak = true;
        });
    } failBlock:^(NSString *reason){
        QMLog(@"语音发送失败");
    }];
}

// 发送文件
- (void)sendFileMessageWithName:(NSString *)fileName AndSize:(NSString *)fileSize AndPath:(NSString *)filePath {
    [QMConnect sendMsgFile:fileName filePath:filePath fileSize:fileSize progressHander:nil successBlock:^{
        QMLog(@"文件上传成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createNSTimer];
            self.isSpeak = true;
        });
    } failBlock:^(NSString *reason){
        QMLog(@"文件上传失败");
    }];
}

// 失败消息重新发送
- (void)resendAction:(QMTapGestureRecognizer *)gestureRecognizer {
    NSArray * dataArray = [[NSArray alloc] init];
    dataArray = [QMConnect getOneDataFromDatabase:gestureRecognizer.messageId];
    for (CustomMessage * custom in dataArray) {
        [QMConnect resendMessage:custom successBlock:^{
            QMLog(@"重新发送成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self createNSTimer];
                self.isSpeak = true;
            });
        } failBlock:^(NSString *reason){
            QMLog(@"重新发送失败");
        }];
    }
}

#pragma mark - 商品卡片
//商品信息的卡片(默认是关闭的,需要手动打开注释)
- (void)insertCardInfoMessage {
    [QMConnect deleteCardTypeMessage];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"https://lv-img.szgreenleaf.com/brandImg/%E5%8D%AB%E7%94%9F%E5%B7%BE%E6%97%A5%E7%94%A8-79071590495933511.jpg?Expires=1905855933&OSSAccessKeyId=LTAIfEz63bW0rbAT&Signature=jpcvpoCGcpWlweVaC6iWUYIBvys=" forKey:@"cardImage"]; //此参数需要填写的是URL
    [dic setObject:@"标题水泥粉那的大萨达所多撒费大幅度第三方的辅导费等你顾得上弄" forKey:@"cardHeader"];
    [dic setObject:@"氨基酸大家都哪三大" forKey:@"cardSubhead"];
    [dic setObject:@"￥34345" forKey:@"cardPrice"];
    [dic setObject:@"https://kf.7moor.com" forKey:@"cardUrl"]; //此参数需要填写的是URL
    
    [QMConnect insertCardInfoData:dic type:@"card"];
    
}

- (void)insertNewCardInfoMessage {
    [QMConnect deleteCardTypeMessage:@"cardInfo_New"];

    NSDictionary *dic = @{
        @"showCardInfoMsg"   : @"1",
        @"title"             : @"极品家装北欧风格落地灯极品家装北欧风格落地灯极品家装北欧风格落地灯",
        @"sub_title"         : @"副标题字段副标题字段副标题字段副标题字段副标题字段副标题字段",
        @"img"               : @"http://cdn.duitang.com/uploads/item/201410/21/20141021130151_ndsC4.jpeg",
        @"attr_one"          : @{@"color"   : @"#000000",
                                 @"content" : @"X1"},
        @"attr_two"          : @{@"color"   : @"#333333",
                                 @"content" : @"已发货"},
        @"price"             : @"￥200",
        @"other_title_one"   : @"附加信息1附加信息1附加信息1附加信息1附加信息1",
        @"other_title_two"   : @"附加信息2附加信息2附加信息2附加信息2附加信息2",
        @"other_title_three" : @"附加信息3附加信息3附加信息3附加信息3附加信息3",
        @"target_url"            : @"http://www.baidu.com",
        @"tags"              : @[
                                @{
                                    @"label"       : @"按钮名称",
                                    @"url"         : @"https://www.7moor.com",
                                    @"focusIframe" : @"iframe名称"
                                },
                                @{
                                    @"label"       : @"按钮名称1",
                                    @"url"         : @"https://www.hao123.com",
                                    @"focusIframe" : @"hao123"
                                }],
    };
    
    [QMConnect insertCardInfoData:dic type:@"cardInfo_New"];
}

@end
