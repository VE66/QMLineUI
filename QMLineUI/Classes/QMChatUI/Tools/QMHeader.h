//
//  QMHeader.h
//  IMSDK
//
//  Created by 焦林生 on 2021/12/23.
//

#ifndef QMHeader_h
#define QMHeader_h

#import "UIColor+QMColor.h"
#import "UIView+QMView.h"
#import "NSObject+QMUIKit_OC.h"
#import "QMChatRoomViewController+ChatMessage.h"
#import "NSAttributedString+QMEmojiExtension.h"
#import "QMLabelText.h"
#import "QMRemind.h"
#import "QMPushManager.h"
#import "QMTapGestureRecognizer.h"
#import "MLEmojiLabel.h"
#import "QMCommonDef.h"
#import "QMAudioPlayer.h"
#import "QMAudioRecorder.h"
#import "SJVoiceTransform.h"
#import "QMProfileManager.h"
#import "QMActivityView.h"
#import "QMAttributedManager.h"
#import <QMLineSDK/QMLineSDK.h>
                                                                                                                                                                                                                                    
#import <JSONModel/JSONModel.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh/MJRefresh.h>

/********** 屏幕宽高 **********/
#define QM_kStatusBarHeight  [UIApplication sharedApplication].statusBarFrame.size.height
#define kStatusBarAndNavHeight (QM_kStatusBarHeight + 44.0)
#define QM_IS_iPHONEX  ((QM_kStatusBarHeight > 20)?YES:NO)
#define kSafeArea (QM_IS_iPHONEX ? 34.0 : 0)

#define QM_kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define QM_kScreenHeight (QM_IS_iPHONEX ? ([[UIScreen mainScreen] bounds].size.height - 34) : ([[UIScreen mainScreen] bounds].size.height))
#define kScreenAllHeight  [[UIScreen mainScreen] bounds].size.height

/********** 暗黑模式 **********/
#define isDarkStyle ([QMPushManager share].isStyle)

/********** 比例适配 **********/
#define QMFixWidth(x) ((int)((x) * QM_kScreenWidth/375))
#define QMFixHeight(x) ((int)((x) * QM_kScreenHeight/667))

/********** 字体 **********/
#define QMFONT(x) [UIFont systemFontOfSize:QMFixWidth(x)]
#define FONTNAME(name,x)  [UIFont fontWithName:name size:QMFixWidth(x)]
/** 系统加粗 */
#define QMFont_Medium(size)          FONTNAME(@"PingFangSC-Medium", size)
#define QMFont_Semibold(size)        FONTNAME(@"PingFangSC-Semibold", size)
#define QMFont_TCSemibold(size)      FONTNAME(@"PingFangTC-Semibold", size)

static NSString *QM_PingFangSC_Med = @"PingFangSC-Medium";
static NSString *QM_PingFangSC_Reg = @"PingFangSC-Regular";
static NSString *QM_PingFangTC_Sem = @"PingFangTC-Semibold";

/********** 色值 **********/
#define QMHEXRGB(hex)   [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#define QM_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define QM_RGB(r,g,b) QM_RGBA(r,g,b,1.0)

/********** 常量 **********/
#define kInputViewHeight 75
#define kChatLeftAndRightWidth  QMFixWidth(67)
#define QMChatTextMaxWidth (QM_kScreenWidth - kChatLeftAndRightWidth*2)
#define kChatTopMargin 20
#define kChatBottomMargin 10
#define QMChatTextMinHeight 45
#define kChatIconWidth QMFixWidth(45)
#define kChatIconMargin QMFixWidth(12)


/********** 通知 **********/
#define TUIKitNotification_TIMRefreshListener @"TUIKitNotification_TIMRefreshListener"

/// 字符串为空
#define QMStringIsEmpty(str)     ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
/// 数组为空
#define QMArrayIsEmpty(array)    (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
/// 字典为空
#define QMDictIsEmpty(dic)       (dic == nil || [dic isKindOfClass:[NSNull class]] )


#endif /* QMHeader_h */
