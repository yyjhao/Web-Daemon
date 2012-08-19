//
//  InstancesManager.h
//  Web Daemon
//
//  Created by Yujian Yao on 18/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopController.h"

@interface InstancesManager : NSObject<NSTableViewDataSource, NSUserNotificationCenterDelegate, NSComboBoxDataSource>{
    __strong NSString* storedFile;
    NSMutableArray* preloadedSettingsNames;
    NSArray* oriPreloadedSettings;
    NSDictionary* specificSettings;
    NSArray* specificAttributes;
    NSString* tmpHost;
}

- (id)init;
- (void)renameInstance:(NSString*)oldname to:(NSString*)newName;
- (BOOL)removeInstance:(NSString*)name;
- (BOOL)addInstance:(NSMutableDictionary*)ins;
- (void)updateInstance:(NSString*)name;
- (void)saveData;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (BOOL)updateIcon:(NSImage*)icon ofName:(NSString*)name;
- (void)updateUsingWide:(BOOL)usingWide ofName:(NSString*)name;
- (WebView*)webViewForOpeningNewWindowWithHost:(NSString*)host;

@property (strong, nonatomic) NSMutableDictionary* configs;
@property (strong, nonatomic) NSMutableDictionary* daemons;
@property (weak) IBOutlet NSMenu* menu;
@property (strong, nonatomic, readonly) NSMutableArray* preloadedSettings;
@property WebView* webviewForOpeningNewWindow;
@property (weak) NSController* daemonToDisable;

-(IBAction)disableDaemon:(id)sender;

@end
