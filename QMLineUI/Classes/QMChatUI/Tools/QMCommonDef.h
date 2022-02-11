//
//  QMCommonDef.h
//  IMSDK
//
//  Created by 焦林生 on 2021/12/23.
//

#ifndef QMCommonDef_h
#define QMCommonDef_h

typedef enum : NSUInteger {
    ChatCall_video_Invite = 1, /**主动视频邀请*/
    ChatCall_video_beInvited, /**视频被邀请*/
    ChatCall_voice_Invite, /**主动语音邀请*/
    ChatCall_voice_beInvited, /**视频被邀请*/
} ChatCallType;

/// 输出日志 (格式: [时间] [哪个方法] [哪行] [输出内容])
#ifdef DEBUG
#define QMLog(fmt, ...) printf("\n🏅[%s] %s [第%d行] [%s]🏅\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])
#else
#define QMLog(fmt, ...)
#endif

//@weakify @strongify
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#endif /* QMCommonDef_h */
