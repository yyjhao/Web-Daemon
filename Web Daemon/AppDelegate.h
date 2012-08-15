//
//  AppDelegate.h
//  Web Daemon
//
//  Created by Yujian Yao on 16/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstancesManager.h"
#import <ServiceManagement/ServiceManagement.h>
#import "NetworkManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate, NSComboBoxDelegate, NetworkManagerDelegate>{
    IBOutlet InstancesManager* manager;
    NSMutableDictionary* editingConfig;
    BOOL usingEditor;
    NetworkManager* nManager;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSToolbar *bar;
@property (weak) IBOutlet NSTabView *tabs;
@property (unsafe_unretained) IBOutlet NSPanel *creatorSheet;
@property (weak) IBOutlet NSTableView *instancesTable;
@property (weak) IBOutlet NSTextField *smallURLField;
@property (weak) IBOutlet NSTextField *wideURLField;
@property (weak) IBOutlet NSButton *autoRefreshBox;
@property (weak) IBOutlet NSButtonCell *switchPageBox;
@property (weak) IBOutlet NSButton *createBut;
@property (weak) IBOutlet NSImageView *iconView;
@property (weak) IBOutlet NSMenu *contextMenu;
@property (weak) IBOutlet NSComboBox *namePicker;
@property IBOutlet NSNumber* launchAtLogin;
@property (weak) IBOutlet NSButton *launchAtLoginBut;

- (IBAction)changePref:(id)sender;
- (IBAction)showCreator:(id)sender;
- (IBAction)endCreator:(id)sender;
- (IBAction)applyCreator:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)showPref:(id)sender;
- (IBAction)nameSelected:(id)sender;
- (IBAction)changeAutoLaunch:(id)sender;

@end
