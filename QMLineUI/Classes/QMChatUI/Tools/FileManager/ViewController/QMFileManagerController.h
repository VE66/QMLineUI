//
//  QMFileManagerController.h
//  IMSDK-OC
//
//  Created by HCF on 16/8/10.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlock)(NSString *name, NSString * size, NSString * path);

@interface QMFileManagerController : UIViewController

@property (nonatomic, strong)CallBackBlock callBackBlock;

@property (nonatomic, strong) void(^fileManagerBlock)(NSString *name, NSString * size, NSString * path);

@property (nonatomic, assign)BOOL isForm;

@end
