//
//  topController.h
//  Web Daemon
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import <Foundation/Foundation.h>
#import "WebpopController.h"
#import "MenubarController.h"
#import "InstancesManager.h"
#import "GradientBackgroundView.h"

@class InstancesManager;

@interface TopController : NSObject<WebpopControllerDelegate, WDNotificationHandler>

-(id)initWithConfig:(NSMutableDictionary*)config;
-(void)updateWithConfig:(NSMutableDictionary*)config;

@property (nonatomic, strong) MenubarController *menuBarController;
@property (nonatomic, strong) WebpopController *webpopController;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, weak) InstancesManager* manager;
@property BOOL notified;

- (void)togglePanel:(id)sender;
- (void)updateIcon:(NSImage*)icon;
- (void)updateUsingWide:(BOOL)usingWide;
- (WebView*)openNewWindow:(NSURLRequest *)request;

@end
