//
//  WebToApp.h
//  Web Daemon
//
//  Interface between the webView and the application
//  Provides a function to grab attention (changing the color of icon and playing a sound)
//  and to set whether the host of the link should be replaced to the wide version when a
//  link is to be opened in the browser.
//
//  Created by Yujian Yao on 2/8/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    WDImportantNotification = 0,
    WDTrivialNotification = 1
} WDNotificationType;

@protocol WDNotificationHandler<NSObject>

-(void)grabAttention;
-(void)cancelAttention;

@end

@interface WebToApp : NSObject

-(id)initWithTop:(id<WDNotificationHandler>) top;
- (void)grabAttention;
- (void)cancelAttention;

@property (weak) id<WDNotificationHandler> theTop;
@property BOOL shouldReplaceHost;

@end
