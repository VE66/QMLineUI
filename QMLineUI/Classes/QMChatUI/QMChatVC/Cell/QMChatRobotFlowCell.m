//
//  QMChatRobotFlowCell.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/27.
//

#import "QMChatRobotFlowCell.h"
#import "QMChatFlowView.h"
@implementation QMChatRobotFlowCell {
    
    UILabel *_headerLabel;
    
    UIScrollView *_scrollView;
    
    UICollectionView *_collectionView;
    
    QMChatFlowView *flowView;
    
    NSString *_flowTip;
    
    BOOL flowStyle;
        
    UIView *_lineView;
    
    UIButton *_doneBtn;
    
    UILabel *_sumLabel;
    
    NSArray *_selectedArray;
}

- (void)createUI {
    [super createUI];
    
    flowView = [[QMChatFlowView alloc] init];
    flowView.frame = CGRectMake(67, CGRectGetMaxY(self.timeLabel.frame)+25, 260, 300);
    flowView.layer.masksToBounds = YES;
    flowView.layer.cornerRadius = 8;
    [self.contentView addSubview:flowView];
        
    _lineView = [[UIView alloc] init];
    _lineView.hidden = YES;
    [self.contentView addSubview:_lineView];
    
    _doneBtn = [[UIButton alloc] init];
    _doneBtn.hidden = YES;
    _doneBtn.titleLabel.font = [UIFont fontWithName:QM_PingFangTC_Sem size:14];
    [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_doneBtn setTitleColor:[UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_doneBtn];
    
    _sumLabel = [[UILabel alloc] init];
    _sumLabel.hidden = YES;
    _sumLabel.layer.masksToBounds = YES;
    _sumLabel.layer.cornerRadius = 8;
    _sumLabel.textAlignment = NSTextAlignmentCenter;
    _sumLabel.font = [UIFont fontWithName:QM_PingFangTC_Sem size:14];
    _sumLabel.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_ECECEC_BG : QMColor_News_Custom];
    _sumLabel.backgroundColor = [UIColor colorWithHexString:QMColor_News_Custom alpha:0.1];
    [self.contentView addSubview:_sumLabel];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    self.message = message;
    [super setData:message avater:avater];
    
    [flowView setDarkModeColor];
    
    _selectedArray = [[NSArray alloc] init];
    
    if ([message.fromType isEqualToString:@"0"]) {
        
    }else {
        NSString *robotFlowTip = message.robotFlowTip;
        _flowTip = message.robotFlowTip;
        message.robotFlowTip = [message.robotFlowTip stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
        
        if ([message.robotFlowTip containsString:@"</p>"]) {
            message.robotFlowTip = [message.robotFlowTip stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
        } else if ([message.robotFlowTip containsString:@"<p>"]) {
            if ([message.robotFlowTip hasPrefix:@"<p>"]) {
                message.robotFlowTip = [message.robotFlowTip stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
            }
            message.robotFlowTip = [message.robotFlowTip stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];

        }
        
        message.robotFlowTip = [message.robotFlowTip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //html标签替换
        CGFloat titleHeight = [QMLabelText calcRobotHeight:_flowTip];
//        CGFloat titleHeight = [QMLabelText MLEmojiLabelText:robotFlowTip fontName:QM_PingFangSC_Reg fontSize:16 maxWidth:QMChatTextMaxWidth].height;
        NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
        message.robotFlowTip = [regularExpretion stringByReplacingMatchesInString:message.robotFlowTip options:NSMatchingReportProgress range:NSMakeRange(0, message.robotFlowTip.length) withTemplate:@""];
        
        NSMutableArray * arr = [QMLabelText dictionaryWithJsonString:self.message.robotFlowList];
        CGFloat messageHeight = 0;
        
        if ([message.robotFlowsStyle isEqualToString:@"1"]) {
            if (arr.count < 4) {
                messageHeight = 25+titleHeight+30+arr.count*50;
            }else {
                messageHeight = 265 + titleHeight;
            }
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
        }
        
        BOOL flowSelect = [message.robotFlowSelect boolValue];
        BOOL flowSend = [message.robotFlowSend boolValue];
//        CGFloat selectHeight = (flowSelect && !flowSend) ? 50 : 0;

        if (flowSelect && !flowSend) {
            _lineView.hidden = NO;
            _doneBtn.hidden = NO;
            _sumLabel.hidden = NO;
            
            [self setUIFrame:CGRectGetMaxY(self.timeLabel.frame)+25+messageHeight+5 andArray:arr];
        }else {
            _lineView.hidden = YES;
            _doneBtn.hidden = YES;
            _sumLabel.hidden = YES;
        }

        [self.chatBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kChatLeftAndRightWidth);
            make.top.equalTo(self.iconImage.mas_top);
            make.width.mas_equalTo(260);
            make.bottom.equalTo(self.contentView).offset(-kChatBottomMargin).priority(999);
            make.height.mas_greaterThanOrEqualTo(QMChatTextMinHeight).priority(999);
        }];

        flowView.frame = CGRectMake(kChatLeftAndRightWidth, CGRectGetMaxY(self.timeLabel.frame)+25, 260, messageHeight);
        flowView.flowList = self.message.robotFlowList;
        flowView.robotFlowTip = robotFlowTip;
        flowView.flowSelset = flowSelect;
        flowView.flowSend = flowSend;
        if (message.robotFlowsStyle == nil || [message.robotFlowsStyle isEqualToString:@"0"] || [message.robotFlowsStyle isEqualToString:@"null"]) {
            flowView.isVertical = NO;
        }else {
            flowView.isVertical = YES;
        }
        __weak typeof(self) weakSelf = self;
        flowView.selectAction = ^(NSDictionary * dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tapSendMessage(dic[@"text"], @"");
            });
        };
        flowView.tapFlowNumberAction = ^(NSString * _Nonnull number) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tapNumberAction(number);
            });
        };
        
        flowView.tapFlowUrlAction = ^(NSString * _Nonnull url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tapNetAddress(url);
            });
        };
        @weakify(self)
        flowView.tapSelectAction = ^(NSArray * _Nonnull dataArray) {
            @strongify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_selectedArray = dataArray;
                weakSelf.tapFlowSelectAction(dataArray, NO);
                [weakSelf setUIFrame:CGRectGetMaxY(self.timeLabel.frame)+25+messageHeight+5 andArray:dataArray];
            });
        };
        [flowView setDate];
        message.robotFlowTip = _flowTip;
    }
}

- (void)setUIFrame:(CGFloat)height andArray:(NSArray *)array {
    int number = 0;
    for (NSDictionary *item in array) {
        BOOL selected = [item[@"select"] boolValue];
        if (selected) {
            number += 1;
        }
    }
    _sumLabel.text = [NSString stringWithFormat:@"%d", number];
    CGFloat btnWidth = [QMLabelText calculateTextWidth:@"哈确定" fontName:QM_PingFangTC_Sem fontSize:14 maxHeight:100];
    CGFloat numWidth = [QMLabelText calculateTextWidth:_sumLabel.text fontName:QM_PingFangTC_Sem fontSize:14 maxHeight:100] + 10;
    CGFloat width = btnWidth + numWidth;
    _lineView.frame = CGRectMake(67+15, height, 230, 1);
    [UIView drawDashLine:_lineView lineLength:2 lineSpacing:2 lineColor:[UIColor colorWithHexString:@"#CACACA"]];
    _doneBtn.frame = CGRectMake(67+130-width/2 , height + 13.5, btnWidth, 16);
    _sumLabel.frame = CGRectMake(67+130-width/2+btnWidth, height + 13.5, numWidth, 16);
}

- (void)doneAction:(UIButton *)button {
    if (![self.message.robotFlowSend boolValue]) {
        self.tapFlowSelectAction(_selectedArray, YES);        
    }
}

#pragma mark 文本处理
- (NSMutableArray *)showHtml: (NSString *)htmlString {

    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    
    if ([htmlString containsString:@"</p>"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    } else if ([htmlString containsString:@"<p>"]) {
        if ([htmlString hasPrefix:@"<p>"]) {
            htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
        }
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    }
    
    // 拆分文本和图片
    __block NSString *tempString = htmlString;
    __block NSMutableArray *srcArr = [NSMutableArray array];
    
    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    [regularExpretion enumerateMatchesInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length != 0) {
            // 字符串
            NSString *actionString = [NSString stringWithFormat:@"%@",[htmlString substringWithRange:result.range]];
            
            // 新的range
            NSRange range = [tempString rangeOfString:actionString];
            
            NSArray *components = nil;
            if ([actionString rangeOfString:@"<img src=\""].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src=\""];
            }else if ([actionString rangeOfString:@"<img src="].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src="];
            }

            if (components.count >= 2) {
                // 文本内容
                QMLabelText *model1 = [[QMLabelText alloc] init];
                model1.type = @"text";
                model1.content = [tempString substringToIndex:range.location];
                [srcArr addObject:model1];
                
                // 图片内容
                QMLabelText *model2 = [[QMLabelText alloc] init];
                model2.type = @"image";
                model2.content = [tempString substringWithRange:range];;
                [srcArr addObject:model2];
                tempString = [tempString substringFromIndex:range.location+range.length];
            }
        }
    }];
    
    QMLabelText *model3 = [[QMLabelText alloc] init];
    model3.type = @"text";
    model3.content = tempString;
    [srcArr addObject:model3];
    return srcArr;
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

