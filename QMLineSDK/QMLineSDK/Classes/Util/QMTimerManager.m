//
//  QMTimerManager.m
//  QMLineSDK
//
//  Created by lishuijiao on 2021/4/7.
//  Copyright © 2021 haochongfeng. All rights reserved.
//

#import "QMTimerManager.h"

@implementation QMTimerManager

static NSMutableDictionary *timers_;

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
    });
}

+ (NSString *)execTask:(void(^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async
{
    if (!task || start < 0 || (interval <= 0 && repeats)) {
        return nil;
    }

    NSString *name = [NSString stringWithFormat:@"%zd", timers_.count];
    
    dispatch_queue_t queue = async ? dispatch_queue_create("timer", DISPATCH_QUEUE_SERIAL) : dispatch_get_main_queue();

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start*NSEC_PER_SEC),
                              interval*NSEC_PER_SEC,
                              0);
    
    dispatch_source_set_event_handler(timer, ^{
        if (!repeats) {
            [self cancelTask:name];
        }
        task();
    });
    dispatch_resume(timer);

    timers_[name] = timer;
        
    return name;
}

+ (void)cancelTask:(NSString *)name {
    if (name.length == 0) {
        return;
    }
    dispatch_source_t timer = timers_[name];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:name];
    }
}
@end
