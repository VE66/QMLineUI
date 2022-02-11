//
//  QMChatRoomViewController+TableView.m
//  IMSDK
//
//  Created by 焦林生 on 2022/1/10.
//

#import "QMChatRoomViewController+TableView.h"
#import "QMChatRoomViewController+ChatMessage.h"
#import "QMLogistsMoreView.h"
#import "QMChatRobotCell.h"
#import "QMChatRobotFlowCell.h"
#import "QMChatTextCell.h"
#import "QMChatImageCell.h"
#import "QMChatVoiceCell.h"
#import "QMChatFileCell.h"
#import "QMChatNoteCell.h"
#import "QMChatCardCell.h"
#import "QMChatNewCardCell.h"
#import "QMChatRichTextCell.h"
#import "QMChatCallCell.h"
#import "QMChatCommonProblemCell.h"
#import "QMChatFormCell.h"
#import "QMChatLogistcsInfoCell.h"
#import "QMChatRoomXbotCardCell.h"
#import "QMChatListCardCell.h"
#import "QMChatRobotReplyCell.h"
#import "QMTipMessageCell.h"

@implementation QMChatRoomViewController (TableView)

#pragma mark ------- tableViewDelegate ---------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomMessage * message = self.dataArray[self.dataArray.count-indexPath.row-1];
    NSString *identifier = @"";
    if ([message.messageType isEqualToString:@"text"]) {
        if ([message.isRobot isEqualToString:@"1"]) {
            if ([message.isRobot isEqualToString:@"1"] && ![message.questionId isEqualToString:@""]) {
                identifier = NSStringFromClass([QMChatRobotReplyCell class]);
            } else {
                identifier = NSStringFromClass([QMChatRobotCell class]);
            }
        }else if ([message.isRobot isEqualToString:@"2"]) {
            if ([message.robotFlowsStyle isEqualToString:@"2"]) {
                identifier = NSStringFromClass([QMChatRobotCell class]);
            }else {
                identifier = NSStringFromClass([QMChatRobotFlowCell class]);
            }
        }
        else {
            identifier = NSStringFromClass([QMChatTextCell class]);
        }
    }else if ([message.messageType isEqualToString:@"image"]) {
        identifier = NSStringFromClass([QMChatImageCell class]);
    }else if ([message.messageType isEqualToString:@"voice"]) {
        identifier = NSStringFromClass([QMChatVoiceCell class]);
    }else if ([message.messageType isEqualToString:@"file"]) {
        identifier = NSStringFromClass([QMChatFileCell class]);
    }else if ([message.messageType isEqualToString:@"card"]) {
        identifier = NSStringFromClass([QMChatCardCell class]);
    }else if ([message.messageType isEqualToString:@"cardInfo"]) {
        identifier = NSStringFromClass([QMChatRichTextCell class]);
    }else if ([message.messageType isEqualToString:@"richText"]) {
        identifier = NSStringFromClass([QMChatRichTextCell class]);
    }else if ([message.messageType isEqualToString:@"withdrawMessage"]) {
        identifier = NSStringFromClass([QMTipMessageCell class]);
    }else if ([message.messageType isEqualToString:@"cardInfo_New"]) {
        identifier = NSStringFromClass([QMChatCardCell class]);
    }else if ([message.messageType isEqualToString:@"newCardInfo"]) {
        identifier = NSStringFromClass([QMChatNewCardCell class]);
    }else if ([message.messageType isEqualToString:@"video"]) {
        identifier = NSStringFromClass([QMChatCallCell class]);
    }else if ([message.messageType isEqualToString:@"evaluate"]) {
        identifier = NSStringFromClass([QMChatNoteCell class]);
    }else if ([message.messageType isEqualToString:@"NewPushQues"]) {
        identifier = NSStringFromClass([QMChatCommonProblemCell class]);
    }else if ([message.messageType isEqualToString:@"xbotForm"]) {
        identifier = NSStringFromClass([QMChatFormCell class]);
    }else if ([message.messageType isEqualToString:@"xbotFormSubmit"]) {
        identifier = NSStringFromClass([QMChatTextCell class]);
    }else if ([message.messageType isEqualToString:@"msgTask"]) {
        NSDictionary *dic = message.cardMsg_NewDict;
        if ([dic[@"resp_type"] intValue] == 1) {
            identifier = NSStringFromClass([QMChatLogistcsInfoCell class]);
        } else {
            identifier = NSStringFromClass([QMChatRoomXbotCardCell class]);
        }
    }else if ([message.messageType isEqualToString:@"listCard"]) {
        identifier = NSStringFromClass([QMChatListCardCell class]);
    }
    else{
        return UITableViewCell.new;
    }
    
    QMLog(@"identifier = %@",identifier);
    
    QMChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [self createCellWithClassName:identifier cellModel:message indexPath:indexPath];
    }

    if (indexPath.row>0) {
        CustomMessage * preMessage = self.dataArray[self.dataArray.count-indexPath.row];
        UInt64 disTime = message.createdTime.longLongValue - preMessage.createdTime.longLongValue;
        if (disTime<3*60*1000) {
            cell.timeLabel.hidden = YES;
        }else {
            cell.timeLabel.hidden = NO;
        }
    }else {
        cell.timeLabel.hidden = NO;
    }
    
    @weakify(self)
    if ([cell isKindOfClass:[QMChatLogistcsInfoCell class]]) {
        
        NSDictionary *dic = message.cardMsg_NewDict;
        NSDictionary *listDict = dic[@"data"];
        QMLogistcsInfoModel *model = [[QMLogistcsInfoModel alloc] initWithDictionary:listDict error:nil];

        QMChatLogistcsInfoCell *lcell = (QMChatLogistcsInfoCell *)cell;
        lcell.dataModel = model;
        QMLogistcsInfoModel *dataA = model;
        lcell.showMore = ^{
            @strongify(self)
            [self showMoreView:dataA];
        };
    }
    
    [cell setData:message avater:self.avaterStr];
    
    if ([cell isKindOfClass:[QMChatImageCell class]] ||
        [cell isKindOfClass:[QMChatTextCell class]]) {
        cell.needReloadCell = ^(CustomMessage * _Nonnull model) {
            @strongify(self)
            [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CustomMessage *item = obj;
                if ([item._id isEqualToString:model._id]) {
                    [self.chatTableView beginUpdates];
                    NSMutableArray *mutableArr = self.dataArray.mutableCopy;
                    [mutableArr replaceObjectAtIndex:idx withObject:model];
                    self.dataArray = mutableArr;
                    [self.chatTableView endUpdates];
                }
            }];
        };
    }
    if ([message.messageType isEqualToString:@"text"]) {
        cell.tapNetAddress = ^(NSString *address) {
            if (![address hasPrefix:@"http"]) {
                address = [NSString stringWithFormat:@"http://%@", address];
            }

            NSString *str = [address stringByRemovingPercentEncoding];
            NSCharacterSet *character = [[NSCharacterSet characterSetWithCharactersInString:@"{}"] invertedSet];
            address = [str stringByAddingPercentEncodingWithAllowedCharacters:character];
            NSURL *uRL = [NSURL URLWithString:address];
            [[UIApplication sharedApplication] openURL:uRL options:@{} completionHandler:nil];
        };
        
        cell.tapNumberAction = ^(NSString *number) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@%@",number,NSLocalizedString(@"title.mayBeNumber", nil)] preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *callAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.call", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *phone = [NSString stringWithFormat:@"tel://%@",number];
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone] options:@{} completionHandler:nil];
                }else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
                }
            }];
            
            UIAlertAction *copyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.copy", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 复制文本消息
                UIPasteboard *pasteBoard =  [UIPasteboard generalPasteboard];
                pasteBoard.string = number;
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:callAction];
            [alertController addAction:copyAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        };
    }
    
    // 机器人消息可以选择问题代码 答案可以选择有帮助或无帮助
    if ([message.messageType isEqualToString:@"text"] && [message.isRobot isEqualToString:@"1"]) {
        cell.tapSendMessage = ^(NSString *text, NSString *num) {
            @strongify(self)
            if (message.robotFlowList.length) {
                NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                if (![num isEqualToString:@""]) {
                    int number = [num intValue] - 1;
                    NSString *mssg = arr[number][@"button"];
                    if ([mssg isEqualToString:text]) {
                        [self sendText:arr[number][@"text"]];
                    }else {
                        [self sendText:text];
                    }
                }else {
                    [self sendText:text];
                }
            }else {
                if (self.isRobot) {
                    [self sendText:text];
                }
            }
        };

        cell.didBtnAction = ^(BOOL isUseful) {
            @strongify(self)
            if (!message.isUseful||
                [message.isUseful isEqualToString:@"none"]) {

                if ([message.robotType isEqualToString:@"xbot"]) {
                    [self sendXbotRobotFeedback:isUseful message:message];
                }else{
                    [self sendRobotFeedback:isUseful questionId:message.questionId messageId:message._id robotType:message.robotType robotId:message.robotId robotMsgId:message.robotMsgId];
                }
            }
        };
        
        cell.tapArtificialAction = ^(NSString *number) {
            [QMConnect sdkConvertManualWithPeerId:number successBlock:^{
                QMLog(@"转人工成功");
            } failBlock:^{
                QMLog(@"转人工失败");
            }];
        };
        
    }else if ([message.messageType isEqualToString:@"text"] && [message.isRobot isEqualToString:@"2"]) {
        cell.tapSendMessage = ^(NSString *text, NSString *num) {
            @strongify(self)
            if (self.isRobot) {
                if ([message.robotFlowType isEqualToString:@"button"]) {
                    NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                    if (![num isEqualToString:@""]) {
                        int number = [num intValue] - 1;
                        NSString *mssg = arr[number][@"button"];
                        if ([mssg isEqualToString:text]) {
                            [self sendText:arr[number][@"text"]];
                        }else {
                            [self sendText:text];
                        }
                    }else {
                        [self sendText:text];
                    }
                }else if ([message.robotFlowType isEqualToString:@"list"]) {
                    NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
                    if (![num isEqualToString:@""]) {
                        int number = [num intValue] - 1;
                        NSString *mssg = arr[number][@"button"];
                        if ([mssg isEqualToString:text]) {
                            [self sendText:arr[number][@"text"]];
                        }else {
                            [self sendText:text];
                        }
                    }else {
                        [self sendText:text];
                    }
                }else {
                    [self sendText:text];
                }
            }
        };
        
        cell.tapFlowSelectAction = ^(NSArray * _Nonnull array, BOOL isSend) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSend) {
                    NSString *text = @"";
                    for (NSDictionary *item in array) {
                        BOOL select = [item[@"select"] boolValue];
                        if (select) {
                            text = [text stringByAppendingFormat:@" 【%@】、",item[@"text"]];
                        }
                    }
                    text = [text substringToIndex:[text length] - 1];
                    [QMConnect sdkUpdateRobotFlowSend:@"1" withMessageID:message._id];
                    [self sendText:text];
                }else {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
                    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [QMConnect sdkUpdateRobotFlowList:strJson withMessageID:message._id];
                    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        CustomMessage *item = obj;
                        if ([item._id isEqualToString:message._id]) {
                            item.robotFlowList = strJson;
                            NSMutableArray *mutableArr = self.dataArray.mutableCopy;
                            [mutableArr replaceObjectAtIndex:idx withObject:item];
                            self.dataArray = mutableArr;
                        }
                    }];
                }
            });
        };
        
    }else if ([message.messageType isEqualToString:@"evaluate"] && [message.evaluateStatus isEqualToString:@"0"]) {
        cell.noteSelected = ^(CustomMessage * _Nonnull message) {
            [self createEvaluationView:NO andGetServerTime:NO andEvaluatId:message.evaluateId andFrom:@"send"];
        };
    }
    
    if ([message.messageType isEqualToString:@"NewPushQues"]) {
        cell.tapCommonAction = ^(NSInteger index) {
            @strongify(self)
            NSString *strIndex = [NSString stringWithFormat:@"%ld", index];
            
            for (CustomMessage *item in self.dataArray) {
                if ([message._id isEqualToString:item._id]) {
                    item.common_selected_index = strIndex;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [QMConnect sdkChangeCommonProblemIndex:strIndex withMessageID:message._id];
                [self.chatTableView reloadData];
            });
            
        };
        
        cell.tapSendMessage = ^(NSString * _Nonnull message, NSString * _Nonnull number) {
            @strongify(self)
            if (self.isRobot) {
                [self sendText:message];
            }
        };
    }
    
    if ([message.messageType isEqualToString:@"xbotForm"]) {
        cell.didBtnAction = ^(BOOL isbool) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideKeyboard];
            });
        };
    }
    
    if ([message.messageType isEqualToString:@"listCard"]) {
        cell.tapListCardAction = ^(NSDictionary * _Nonnull listDic) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *content = listDic[@"content"];
                if (content.length > 0) {
                    [self sendText:content];
                }
            });
        };
    }
    return cell;
}

- (void)showMoreView:(QMLogistcsInfoModel *)model {
    QMLogistsMoreView *vc = [QMLogistsMoreView defualtView];
    [vc show:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomMessage * message = self.dataArray[self.dataArray.count-indexPath.row-1];
    
    CGFloat height = 25;
    if (indexPath.row>0) {
        CustomMessage * preMessage = self.dataArray[self.dataArray.count-indexPath.row];
        UInt64 disTime = message.createdTime.longLongValue - preMessage.createdTime.longLongValue;
        if (disTime<3*60*1000) {
            height = 25;
        }else {
            height = 60;
        }
    }else {
        height = 60;
    }

    if ([message.messageType isEqualToString:@"text"]) {
        
         if ([message.isRobot isEqualToString:@"2"]) {
            NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:message.robotFlowList];
            CGFloat titleHeight = [QMLabelText calcRobotHeight:message.robotFlowTip];
            CGFloat messageHeight = 0;
            
            BOOL flowSelect = [message.robotFlowSelect boolValue];
            BOOL flowSend = [message.robotFlowSend boolValue];
            CGFloat selectHeight = (flowSelect && !flowSend) ? 50 : 0;
            if ([message.robotFlowsStyle isEqualToString:@"1"]) {
                if (arr.count < 4) {
                    messageHeight = 25+titleHeight+30+arr.count*50;
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }else if ([message.robotFlowsStyle isEqualToString:@"0"]) {
                if (arr.count < 7) {
                    if (arr.count%2 == 0) {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2)*50;
                    }else {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2+1)*50;
                    }
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }else if ([message.robotFlowsStyle isEqualToString:@"2"]) {
                CGFloat robotHeight = [QMLabelText calcRobotHeight:message.message];
                height += robotHeight + 30;
            }else {
                if (arr.count < 7) {
                    if (arr.count%2 == 0) {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2)*50;
                    }else {
                        messageHeight = 25+titleHeight+30+ceil(arr.count/2+1)*50;
                    }
                }else {
                    messageHeight = 265 + titleHeight;
                }
                height += messageHeight + 10 + selectHeight;
            }
        }else {
            return UITableViewAutomaticDimension;
        }

         
    }else if ([message.messageType isEqualToString:@"image"]) {
        return UITableViewAutomaticDimension;

    }else if ([message.messageType isEqualToString:@"voice"]) {
//        return UITableViewAutomaticDimension;
        NSString *voiceStatus = [QMConnect queryVoiceTextStatusWithmessageId:message._id];
        if ([voiceStatus isEqualToString:@"1"]) {
            if (message.fileName.length > 0) {
                CGSize textSize = [QMLabelText MLEmojiLabelText:message.message fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth];
                height += textSize.height + 45;
            }
        }else {
            height += 45;
        }
    }else if ([message.messageType isEqualToString:@"file"]) {
//        height += 90;
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"card"]) {
        height += 165;
    }else if ([message.messageType isEqualToString:@"cardInfo"]) {
        height += 80;
    }else if ([message.messageType isEqualToString:@"richText"]) {
        height += 120;
    }else if ([message.messageType isEqualToString:@"withdrawMessage"]) {
        return UITableViewAutomaticDimension;
//        height += 12;
    }else if ([message.messageType isEqualToString:@"cardInfo_New"]) {
        height += 110;
    }else if ([message.messageType isEqualToString:@"newCardInfo"]) {
        NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            height += 0;
        }else {
            NSString *itemType = dic[@"item_type"];
            NSString *otherTitleOne = dic[@"other_title_one"];
            NSString *otherTitleTwo = dic[@"other_title_two"];
            NSString *otherTitleThree = dic[@"other_title_three"];
            CGFloat otherHeight = 0;
            if (otherTitleOne.length > 0) {
                otherHeight += 5 + 15;
            }
            if (otherTitleTwo.length > 0) {
                otherHeight += 5 + 15;
            }
            if (otherTitleThree.length > 0) {
                otherHeight += 5 + 15;
            }
            
            if (itemType.length > 0) {
                height += 100;
            }else {
                if (otherHeight > 0) {
                    height += 100 + otherHeight + 5 + 10;
                }else {
                    height += 100;
                }
            }
        }
    }else if ([message.messageType isEqualToString:@"video"]) {
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"evaluate"]) {
        return UITableViewAutomaticDimension;
    }else if ([message.messageType isEqualToString:@"NewPushQues"]) {
        return UITableViewAutomaticDimension;

    }else if ([message.messageType isEqualToString:@"xbotForm"]) {
        NSData *jsonData = [message.xbotForm dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            return 0;
        }else {
            if (dic.count) {
                NSString *formPrompt = dic[@"formPrompt"];
                NSString *formName = dic[@"formName"];
                CGFloat promptHeight = [QMLabelText calculateTextHeight:formPrompt fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 67*2 - 30];
                CGFloat nameHeight = [QMLabelText calculateTextHeight:formName fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QM_kScreenWidth - 67*2 - 30];
                height += promptHeight + 20 + nameHeight + 30;
            }else {
                return 0;
            }
        }
    }else if ([message.messageType isEqualToString:@"xbotFormSubmit"]) {
        CGSize textSize = [QMLabelText MLEmojiLabelText:@"提交成功!" fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth];
        height += textSize.height + 30;
    }else if ([message.messageType isEqualToString:@"msgTask"]) {
        NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        NSDictionary *listDict = dic[@"data"];
        if ([dic[@"resp_type"] intValue] == 1) {
            QMLogistcsInfoModel *model = [[QMLogistcsInfoModel alloc] initWithDictionary:listDict error:nil];
            height += [QMChatLogistcsInfoCell getCellHeigt:model];
        } else {
            if (message.cardType == QMMessageCardTypeNone) {
                if(err) {
                    height += 0;
                }else {
                    NSArray *cardList = listDict[@"shop_list"];
                    int shop_list_show = [dic[@"data"][@"shop_list_show"] intValue] ?: 5;

                    int shopNumber = 0;
                    int listNumber = 0;
                    
                    if (shop_list_show <= cardList.count) {
                        for (int i = 0; i < cardList.count; i++) {
                            if (listNumber == shop_list_show) {
                                break;;
                            }
                            NSDictionary *dic = cardList[i];
                            if ([dic[@"item_type"] isEqualToString:@"0"]) {
                                listNumber += 1;
                            }else if ([dic[@"item_type"] isEqualToString:@"1"]) {
                                shopNumber += 1;
                            }
                        }
                    }else {
                        for (NSDictionary *dic in cardList) {
                            if ([dic[@"item_type"] isEqualToString:@"0"]) {
                                listNumber += 1;
                            }else if ([dic[@"item_type"] isEqualToString:@"1"]) {
                                shopNumber += 1;
                            }
                        }
                    }
                    CGFloat cellHeight = 88*listNumber + 72*shopNumber;
                    height += cellHeight + 85;
                }
            } else if (message.cardType == QMMessageCardTypeSeleced) {
                height += 81;
            } else {
                height += 44;
            }
        }
    }else if ([message.messageType isEqualToString:@"listCard"]) {
        height += 110;
    }
    else {
        return 0;
    }
       
    return height;
}

#pragma mark - 机器人评价Action
// xbot机器人帮助评价
- (void)sendXbotRobotFeedback:(BOOL)isUseful message:(CustomMessage *)message {
    @weakify(self)
    [QMConnect sdkSubmitXbotRobotFeedback:isUseful message:message successBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            for (CustomMessage *mes in self.dataArray) {
                if ([mes._id isEqualToString:message._id]) {
                    mes.isUseful = isUseful == YES ? @"useful" : @"useless";
                    break;
                }
            }
            [self.chatTableView reloadData];
        });
    } failBlock:^{
        
    }];
}

// 机器人帮助评价
- (void)sendRobotFeedback: (BOOL)isUseful questionId: (NSString *)questionId messageId: (NSString *)messageId robotType: (NSString *)robotType robotId: (NSString *)robotId robotMsgId: (NSString *)robotMsgId {
    @weakify(self)
    [QMConnect sdkSubmitRobotFeedback:isUseful questionId:questionId messageId:messageId robotType:robotType robotId:robotId robotMsgId:robotMsgId successBlock:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CustomMessage *message in self.dataArray) {
                if ([message._id isEqualToString:messageId]) {
                    message.isUseful = isUseful == YES ? @"useful" : @"useless";
                    break;
                }
            }
            [self.chatTableView reloadData];
        });
    } failBlock:^{
        
    }];
}

- (QMChatBaseCell *)createCellWithClassName:(NSString *)className
                                      cellModel:(CustomMessage *)cellModel
                                      indexPath:(NSIndexPath *)indexPath {
    QMChatBaseCell * cell = nil;
    
    Class cellClass = NSClassFromString(className);
    
    cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
    
    if (cell == nil) {
        cell = [[QMChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QMChatBaseCell"];
    }
    
    return cell;
}

@end
