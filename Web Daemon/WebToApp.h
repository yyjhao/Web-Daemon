//
//  WebToApp.h
//  Web Daemon
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

@end
