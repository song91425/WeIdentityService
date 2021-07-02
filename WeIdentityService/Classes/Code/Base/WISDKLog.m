//
//  WISDKLog.m
//  WeIdentityService
//
//  Created by tank on 2021/1/7.
//

#import "WISDKLog.h"

static WISDKLog * sdkLog;
@implementation WISDKLog
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once , ^{
        sdkLog = [WISDKLog new];
        sdkLog.printLog = NO;
    });
    return sdkLog;
}

+ (void)log:(const char*)sel desc:(NSString *)desc{
    [self log:sel desc:desc argKeys:nil argValues:nil];

}

+ (void)log:(const char*)sel desc:(NSString *)desc argKeys:(NSArray *)keys argValues:(NSArray *)values{
//    if (printSS) {
//        [self printCall];
//    }
//
    NSString *selStr = [NSString stringWithFormat:@"\n====================\n====================[SDK log]====================\n====================\n%s\n%@\n",sel,desc];
    NSMutableString *mutStr = [NSMutableString new];
    [mutStr appendString:selStr];
    if (keys == nil) {
        [mutStr appendString:@"\n====================\n"];
        if(WISDKLog.sharedInstance.printLog)
            if(WISDKLog.sharedInstance.printLog)
                NSLog(@"%@",mutStr);
        return;
    }
    for (int i = 0 ; i < keys.count; i++) {
        [mutStr appendString:@">>>>>>> "];
        [mutStr appendString:keys[i]];
        [mutStr appendString:@":"];
        [mutStr appendString:[values[i] description]];
        [mutStr appendString:@"\n"];
    }
    [mutStr appendString:@"====================\n"];
    if(WISDKLog.sharedInstance.printLog)
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"%@",mutStr);

}

+ (void)printCall{
    NSArray *syms = [NSThread  callStackSymbols];
    if ([syms count] > 1) {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"\n<%@ %p> %@ - caller: %@ ", [self class], self, NSStringFromSelector(_cmd),[syms objectAtIndex:1]);
    } else {
        if(WISDKLog.sharedInstance.printLog)
            NSLog(@"\n<%@ %p> %@", [self class], self, NSStringFromSelector(_cmd));
    }
}

@end
