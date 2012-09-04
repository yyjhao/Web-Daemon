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
    if(sel == @selector(grabAttention))
    {
        return @"grabAttention";
    }else if(sel == @selector(cancelAttention)){
        return @"cancelAttention";
    }
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(grabAttention) || sel == @selector(cancelAttention))
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

- (void)grabAttention
{
    [_theTop grabAttention];
}

- (void)cancelAttention
{
    [_theTop cancelAttention];
}

@end
