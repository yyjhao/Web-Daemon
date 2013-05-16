//
//  menubarController.h
//  Web Daemon
//
//  The controller for the status bar icons
//
//  Created by Yujian Yao on 15/7/12.
//

#define STATUS_ITEM_VIEW_WIDTH 24.0

#import <Foundation/Foundation.h>
#import "StatusItemView.h"

@interface MenubarController : NSObject

- (void)setStatusItemViewTarget:(id)tar;

@property (nonatomic) BOOL hasActiveIcon;
@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong, readonly) StatusItemView *statusItemView;
@property (nonatomic) NSImage* icon;
@property NSImage* grayIcon;
@property NSImage* notiIcon;
@property NSImage* errorIcon;

@end
