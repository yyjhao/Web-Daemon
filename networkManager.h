//
//  networkManager.h
//  Web Daemon
//
//  Created by Yujian Yao on 15/8/12.
//
//

#import <Foundation/Foundation.h>

@protocol NetworkManagerDelegate <NSObject>

- (void) networkIsUp;
- (void) networkIsDown;

@end

@interface NetworkManager : NSObject{
    NSObject<NetworkManagerDelegate>* delegate;
}

- (id)initWithDelegate:(NSObject<NetworkManagerDelegate>*) del;

@end
