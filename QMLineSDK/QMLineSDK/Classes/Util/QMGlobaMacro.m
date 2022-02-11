//
//  QMGlobaMacro.m
//  QMLineSDK
//
//  Created by haochongfeng on 2018/10/23.
//  Copyright © 2018年 haochongfeng. All rights reserved.
//

#import "QMGlobaMacro.h"
#import <sys/utsname.h>

@implementation QMGlobaMacro

+ (instancetype)shared {
    static QMGlobaMacro *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.monitorDict = [NSDictionary dictionary];
        instance.monitorContext = @"";
        instance.custom_sessionId = @"";
        instance.custom_accessId = @"";
        instance.registUserId = @"";
        instance.isDynamicConnection = YES;
        instance.oemHost = ping_host;
        instance.oemPort = ping_port;
        instance.oemHttp = baseUrlStr;
        instance.isRegist = NO;
        instance.isQINiuServer = NO;
        instance.qiNiuFileServer = @"https://fs-im-resources.7moor.com";
        instance.qiNiuZoneServer = @"fs-im-resources.7moor.com";
    });
    return instance;
}

+ (NSString *)deviceModelName {
    struct utsname sysinfo;
    uname(&sysinfo);
    
    NSString *device = [NSString stringWithCString:sysinfo.machine encoding:NSUTF8StringEncoding];
    
    if ([device isEqualToString:@"iPhone1,1"])    return @"iphone1G";
    if ([device isEqualToString:@"iPhone1,2"])    return @"iphone3G";
    if ([device isEqualToString:@"iPhone2,1"])    return @"iphone3GS";
    if ([device isEqualToString:@"iPhone3,1"])    return @"iphone4";
    if ([device isEqualToString:@"iPhone3,2"])    return @"iphone4";
    if ([device isEqualToString:@"iPhone3,2"])    return @"iphone4";
    if ([device isEqualToString:@"iPhone4,1"])    return @"iphone4s";
    if ([device isEqualToString:@"iPhone5,1"])    return @"iphone5";
    if ([device isEqualToString:@"iPhone5,2"])    return @"iphone5";
    if ([device isEqualToString:@"iPhone5,3"])    return @"iphone5c";
    if ([device isEqualToString:@"iPhone5,4"])    return @"iphone5c";
    if ([device isEqualToString:@"iPhone6,1"])    return @"iphone5s";
    if ([device isEqualToString:@"iPhone6,2"])    return @"iphone5s";
    if ([device isEqualToString:@"iPhone7,1"])    return @"iphone6plus";
    if ([device isEqualToString:@"iPhone7,2"])    return @"iphone6";
    if ([device isEqualToString:@"iPhone8,1"])    return @"iphone6s";
    if ([device isEqualToString:@"iPhone8,2"])    return @"iphone6splus";
    if ([device isEqualToString:@"iPhone8,4"])    return @"iphoneSE";
    if ([device isEqualToString:@"iPhone9,1"])    return @"iPhone7";
    if ([device isEqualToString:@"iPhone9,3"])    return @"iPhone7";
    if ([device isEqualToString:@"iPhone9,2"])    return @"iPhone7plus";
    if ([device isEqualToString:@"iPhone9,4"])    return @"iPhone7plus";
    if ([device isEqualToString:@"iPhone10,1"])    return @"iPhone8";
    if ([device isEqualToString:@"iPhone10,4"])    return @"iPhone8";
    if ([device isEqualToString:@"iPhone10,2"])    return @"iPhone8plus";
    if ([device isEqualToString:@"iPhone10,5"])    return @"iPhone8plus";
    if ([device isEqualToString:@"iPhone10,3"])    return @"iPhoneX";
    if ([device isEqualToString:@"iPhone10,6"])    return @"iPhoneX";
    if ([device isEqualToString:@"iPhone11,8"])    return @"iPhoneXR";
    if ([device isEqualToString:@"iPhone11,2"])    return @"iPhoneXS";
    if ([device isEqualToString:@"iPhone11,4"])    return @"iPhoneXS";
    if ([device isEqualToString:@"iPhone11,6"])    return @"iPhoneXSmax";

    //iPod 系列
    if ([device isEqualToString:@"iPod1,1"])      return @"ipodtouch1";
    if ([device isEqualToString:@"iPod2,1"])      return @"ipodtouch2";
    if ([device isEqualToString:@"iPod3,1"])      return @"ipodtouch3";
    if ([device isEqualToString:@"iPod4,1"])      return @"ipodtouch4";
    if ([device isEqualToString:@"iPod5,1"])      return @"ipodtouch5";
    if ([device isEqualToString:@"iPod7,1"])      return @"ipodtouch6";
    
    //iPad 系列
    if ([device isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([device isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([device isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([device isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([device isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([device isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([device isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([device isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([device isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([device isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([device isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([device isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([device isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([device isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([device isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([device isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([device isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([device isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([device isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([device isEqualToString:@"i386"])         return @"Simulator";
    if ([device isEqualToString:@"x86_64"])       return @"Simulator";
    
    device = [device stringByReplacingOccurrencesOfString:@"," withString:@""];
    return device;
}

+ (NSString *)JSONString:(id)dictionary {
    NSString *jsonStr = nil;
    
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return jsonStr;
}

+ (NSString *)pathOfDocument {
//    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return doc;
}

+ (NSString *)nowDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return [formatter stringFromDate:date];
}

@end
