//
//  QMChatRoomXbotCardCell.m
//  IMSDK-OC
//
//  Created by lishuijiao on 2019/12/23.
//  Copyright © 2019 HCF. All rights reserved.
//

#import "QMChatRoomXbotCardCell.h"
#import "QMChatRoomXbotCardView.h"

@interface QMChatRoomXbotCardCell ()
@property (nonatomic, strong) QMChatRoomXbotCardView *cardView;
@end


@implementation QMChatRoomXbotCardCell {
    NSString *_messageId;

    UILabel *_titleLabel;
    UILabel *_shopName;
    UILabel *_shopAction;
    UITableView *_tableView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.cardView];
    }
    return self;
}

- (QMChatRoomXbotCardView*)cardView {
    if (!_cardView) {
        _cardView = [[QMChatRoomXbotCardView alloc] initWithFrame:CGRectMake(67,  CGRectGetMaxY(self.timeLabel.frame) + 25, QM_kScreenWidth - 67 * 2, 300)];
    }
    return _cardView;
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    _messageId = message._id;
    self.message = message;
    [super setData:message avater:avater];

    NSData *jsonData = [message.cardMessage_New dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        return;
    }else {
        
        CGFloat cellHeight = 0.0;
        CGFloat cellWidth = QM_kScreenWidth - 67 * 2;

        int shop_list_show = [dic[@"data"][@"shop_list_show"] intValue] ?: 5;
        
        int showCount = 0;
        if (message.cardType == QMMessageCardTypeNone) {
            NSArray *cardList = dic[@"data"][@"shop_list"];
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
            showCount = listNumber + shopNumber;
            
            cellHeight = 88*listNumber + 72*shopNumber + 85;
        } else if (message.cardType == QMMessageCardTypeSeleced) {
            cellHeight = 81;
        } else {
            cellHeight = 44;
        }
        
        _cardView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame) + 25, cellWidth, cellHeight);
        _cardView.messageId = _messageId;
        _cardView.type = message.cardType;
        _cardView.showCount = showCount;
        [_cardView setCardDic:dic];
        self.chatBackgroundView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame) + 25, cellWidth, cellHeight);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
