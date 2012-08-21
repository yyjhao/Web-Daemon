//
//  networkManager.m
//  Web Daemon
//
//  Created by Yujian Yao on 15/8/12.
//
//

#import "NetworkManager.h"

@implementation NetworkManager

- (id)initWithDelegate:(NSObject<NetworkManagerDelegate> *)del{
    self = [super init];
    if(self){
        delegate = del;
        Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach)
        {
            NSLog(@"REACHABLE!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate networkIsUp];
            });
        };
        
        reach.unreachableBlock = ^(Reachability*reach)
        {
            NSLog(@"UNREACHABLE!");
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [delegate networkIsDown];
            });
        };
        
        [reach startNotifier];
    }
    return self;
}

@end
