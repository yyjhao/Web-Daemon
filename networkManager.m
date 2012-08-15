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
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate networkIsDown];
            });
        };
        
        [reach startNotifier];
    }
    return self;
}

@end
