//
//  QMChatCallCell.m
//  IMSDK
//
//  Created by 张传章 on 2020/11/6.
//

#import "QMChatCallCell.h"
#import "MLEmojiLabel.h"
@interface QMChatCallCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) MLEmojiLabel *titleLab;

@end

@implementation QMChatCallCell

- (void)createUI {
    [super createUI];
    _iconImageView = [[UIImageView alloc] init];
    [self.chatBackgroundView addSubview:_iconImageView];
    
    _titleLab = [MLEmojiLabel new];
    _titleLab.numberOfLines = 0;
    _titleLab.font = [UIFont systemFontOfSize:14.0f];
    _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.chatBackgroundView addSubview:_titleLab];
}

- (void)setData:(CustomMessage *)message avater:(NSString *)avater {
    [super setData:message avater:avater];
    
    _titleLab.textColor = isDarkStyle ? [UIColor whiteColor] : [UIColor blackColor];
    
    [self setUIWithVideoStatus:message.videoStatus from:message.fromType];

    if ([message.fromType isEqualToString:@"0"]) {

        self.iconImageView.image = [UIImage imageNamed:@"kf_chatrow_video_right"];
        
        [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-QMFixWidth(10));
            make.centerY.equalTo(self.chatBackgroundView);
        }];
        [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(QMFixWidth(10));
            make.right.equalTo(self.titleLab.mas_left).offset(-QMFixWidth(10));
            make.centerY.equalTo(self.chatBackgroundView);
            make.size.mas_equalTo(CGSizeMake(22, 15));
        }];
        
    }else {
        
        self.iconImageView.image = [UIImage imageNamed:@"kf_chatrow_video_left"];
        [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(QMFixWidth(10));
            make.centerY.equalTo(self.chatBackgroundView);
            make.size.mas_equalTo(CGSizeMake(22, 15));
        }];
        [self.titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(QMFixWidth(10));
            make.centerY.equalTo(self.iconImageView);
            make.right.equalTo(self.chatBackgroundView.mas_right).offset(-QMFixWidth(10));
        }];
    }
}

- (void)setUIWithVideoStatus:(NSString *)status from:(NSString *)from {
    if ([status isEqualToString:@"Hangup"] || [status isEqualToString:@"hangup"]) {
        _titleLab.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"通话时长:", nil), [self dateFormat:self.message.message]];
    }else if ([status isEqualToString:@"cancel"]) {
        if ([self.message.fromType isEqualToString:@"0"]) {
            _titleLab.text = NSLocalizedString(@"已取消", nil);
        }else {
            _titleLab.text = NSLocalizedString(@"对方已取消", nil);
        }
    }else if ([status isEqualToString:@"refuse"]) {
        if ([self.message.fromType isEqualToString:@"0"]) {
            _titleLab.text = NSLocalizedString(@"对方已拒绝", nil);
        }else {
            _titleLab.text = NSLocalizedString(@"已拒绝", nil);
        }
    }else {
        _titleLab.textColor = [UIColor clearColor];
        _iconImageView.image = nil;
        _titleLab.text = nil;
    }
}

- (NSString *)dateFormat:(NSString *)string {
    int second = string.intValue/1000; // 秒
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", second/60%60, second%60];
    return time;
//    return [NSString stringWithFormat:@"%02d:%02d:%02d",second/3600, second/60%60, second%60];
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
