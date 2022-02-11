//
//  QMItemCollectionCell.m
//  IMSDK-OC
//
//  Created by HCF on 16/8/10.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import "QMItemCollectionCell.h"

@implementation QMItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.contentView addSubview:self.iconImageView];
}

- (void)configureWithName: (NSString *)name {
    self.iconImageView.image = [UIImage imageNamed:name];    
}



@end
