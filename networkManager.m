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
    }
    return self;
}

@end
