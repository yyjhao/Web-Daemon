//
//  networkManager.h
//  Web Daemon
//
//  A manager to inform the app when network becomes accessible or not
//
//  Created by Yujian Yao on 15/8/12.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol NetworkManagerDelegate <NSObject>

- (void) networkIsUp;
- (void) networkIsDown;

@end

@interface NetworkManager : NSObject{
    __weak NSObject<NetworkManagerDelegate>* delegate;
}

- (id)initWithDelegate:(NSObject<NetworkManagerDelegate>*) del;

@end
