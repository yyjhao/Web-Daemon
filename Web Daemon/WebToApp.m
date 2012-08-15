//
//  WebToApp.m
//  Web Daemon
//
//  Created by Yujian Yao on 2/8/12.
//
//

#import "WebToApp.h"

@implementation WebToApp


+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(postNotification:))
    {
        return @"postNotification";
    }
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(postNotification:))
    {
        return NO;
    }
    return YES;
}

-(id)initWithTop:(id<WDNotificationHandler>) top{
    self = [super init];
    if(self){
        _theTop = top;
    }
    return self;
}

- (void)postNotification:(WDNotificationType)type
{
    [_theTop postNotification:type];
}

@end
