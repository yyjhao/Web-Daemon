//
//  AppDelegate.m
//  Web Daemon
//
//  Created by Yujian Yao on 16/7/12.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize bar = _bar;
@synthesize tabs = _tabs;
@synthesize creatorSheet = _creatorSheet;
@synthesize instancesTable = _instancesTable;
@synthesize smallURLField = _smallURLField;
@synthesize wideURLField = _wideURLField;
@synthesize autoRefreshBox = _autoRefreshBox;
@synthesize switchPageBox = _switchPageBox;
@synthesize createBut = _createBut;
@synthesize iconView = _iconView;
@synthesize contextMenu = _contextMenu;
@synthesize namePicker = _namePicker;
@synthesize cssField = _cssField;
@synthesize jsField = _jsField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    nManager = [[NetworkManager alloc] initWithDelegate:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [manager saveData];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    if(manager.daemons.count == 0){
        return YES;
    }else{
        return NO;
    }
}

- (void)awakeFromNib
{
    [_bar setSelectedItemIdentifier:@"generalViewSelector"];
    [_window center];
    [_instancesTable setDataSource:manager];
    [_smallURLField setDelegate:self];
    [_wideURLField setDelegate:self];
    [_window setDefaultButtonCell:[_createBut cell]];
    [_instancesTable setTarget:self];
    [_instancesTable setRowHeight:24];
    [_instancesTable setDoubleAction:@selector(showEditor:)];
    _namePicker.delegate = self;
    _namePicker.dataSource = manager;
    _launchAtLoginBut.state = [self.launchAtLogin integerValue];
    if(manager.daemons.count == 0){
        [NSApp activateIgnoringOtherApps: YES];
        [_window makeKeyAndOrderFront:self];
    }
}

- (void)matchName
{
    NSString* name = _namePicker.stringValue;
    for(NSDictionary* item in manager.preloadedSettings){
        if([[item objectForKey:@"name"] isEqualToString:name]){
            NSLog(@"%@", item);
            _smallURLField.stringValue = [item objectForKey:@"smallURL"];
            _wideURLField.stringValue = [item objectForKey:@"wideURL"];
            _autoRefreshBox.state = [[item objectForKey:@"autorefresh"] integerValue];
            _switchPageBox.state = [[item objectForKey:@"shouldSwitch"] integerValue];
            _jsField.string = [[item objectForKey: @"injectingJS"] copy];
            _cssField.string = [[item objectForKey: @"injectingCSS"] copy];
            [_createBut setEnabled:YES];
            return;
        }
    }
    name = [name lowercaseString];
    NSRange dotRange, spaceRange;
    dotRange = [name rangeOfString:@"."];
    spaceRange = [name rangeOfString:@" "];
    NSArray* components;
    if(dotRange.location != NSNotFound && spaceRange.location != NSNotFound){
        //no point parsing
        return;
    }else if(dotRange.location != NSNotFound){
        _smallURLField.stringValue = [NSString stringWithFormat:@"http://%@/",name];
        _wideURLField.stringValue = [NSString stringWithFormat:@"http://%@/",name];
        [_createBut setEnabled:YES];
    }else if(spaceRange.location != NSNotFound){
        components = [name componentsSeparatedByString:@" "];
        components = [[components reverseObjectEnumerator] allObjects];
        NSString* newURL = [components componentsJoinedByString:@"."];
        _smallURLField.stringValue = [NSString stringWithFormat:@"http://%@.com/",newURL];
        _wideURLField.stringValue = [NSString stringWithFormat:@"http://%@.com/",newURL];
        [_createBut setEnabled:YES];
    }else{
        _smallURLField.stringValue = [NSString stringWithFormat:@"http://%@.com/",name];
        _wideURLField.stringValue = [NSString stringWithFormat:@"http://%@.com/",name];
        [_createBut setEnabled:YES];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if ([firstResponder isKindOfClass:[NSText class]] && (NSComboBox*)[(NSText *)firstResponder delegate] == _namePicker) {
        [self matchName];
    }
    if(_namePicker.stringValue.length > 0 && _smallURLField.stringValue.length > 0 && _wideURLField.stringValue.length > 0){
        [_createBut setEnabled:YES];
    }else{
        [_createBut setEnabled:NO];
    }
    
}

- (IBAction)changePref:(id)sender {
    NSRect frame = _window.frame;
    if([[sender label] isEqualToString:@"General"]){
        frame.size.width = 320;
        frame.size.height = 220;
        [_tabs selectTabViewItemAtIndex:1];
        
    }else if([[sender label] isEqualToString:@"Manage Icons"]){
        frame.size.width = 520;
        frame.size.height = 500;
        [_tabs selectTabViewItemAtIndex:0];
    }
    frame.origin.y -= frame.size.height - _window.frame.size.height;
    frame.origin.x -= (frame.size.width - _window.frame.size.width) / 2;
    [_window setFrame:frame display:YES animate:YES];
}

- (void)showEditor:(id)sender {
    if([_instancesTable clickedRow] >= [manager.configs count])return;
    editingConfig = [manager.configs objectForKey:[[manager.configs allKeys] objectAtIndex:[_instancesTable clickedRow]]];
    [_createBut setTitle:@"Done"];
    [_namePicker setStringValue:[editingConfig objectForKey:@"name"]];
    [_smallURLField setStringValue:[editingConfig objectForKey:@"smallURL"]];
    [_wideURLField setStringValue:[editingConfig objectForKey:@"wideURL"]];
    if([editingConfig objectForKey:@"icon"] != [NSNull null]){
        [_iconView setImage:[editingConfig objectForKey:@"icon"]];
    }
    [_switchPageBox setState:[[editingConfig objectForKey:@"shouldReloadWhenSwitch"] boolValue]? NSOnState: NSOffState];
    [_autoRefreshBox setState:[[editingConfig objectForKey:@"autoReload"] boolValue]? NSOnState: NSOffState];
    [_createBut setEnabled:YES];
    [_namePicker setEnabled:NO];
    NSString* str = [editingConfig objectForKey: @"injectingJS"];
    if(str == nil){
        str = @"";
    }
    [_jsField setString: str];
    str = [editingConfig objectForKey: @"injectingCSS"];
    if(str == nil){
        str = @"";
    }
    [_cssField setString:str];
    usingEditor = YES;
    [NSApp beginSheet:_creatorSheet modalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)showCreator:(id)sender {
    [_createBut setTitle:@"Create"];
    [_createBut setEnabled:NO];
    [_namePicker setEnabled:YES];
    [_switchPageBox setState: NSOffState];
    [_autoRefreshBox setState: NSOffState];
    usingEditor = NO;
    [NSApp beginSheet:_creatorSheet modalForWindow:_window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)endCreator:(id)sender {
    [_namePicker setStringValue:@""];
    [_smallURLField setStringValue:@""];
    [_wideURLField setStringValue:@""];
    [_cssField setString: @""];
    [_jsField setString: @""];
    [_iconView setImage:nil];
    [NSApp endSheet:_creatorSheet];
    [_creatorSheet orderOut:sender];
    [_instancesTable dataSource];
}

- (IBAction)applyCreator:(id)sender {
    id img = _iconView.image;
    if(img == nil){
        img = [NSNull null];
    }
    if(usingEditor){
        NSString* name = [editingConfig objectForKey:@"name"];
        if(![name isEqualToString:_namePicker.stringValue]){
            if([manager.configs objectForKey:_namePicker.stringValue]){
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"The name is already used. You should pick a unique name."];
                [alert runModal];
                return;
            }
            [manager renameInstance:name to:_namePicker.stringValue];
        }
        [editingConfig setObject:_smallURLField.stringValue forKey:@"smallURL"];
        [editingConfig setObject:_wideURLField.stringValue forKey:@"wideURL"];
        [editingConfig setObject:img forKey:@"icon"];
        [editingConfig setObject:[NSNumber numberWithBool:_autoRefreshBox.state == NSOnState] forKey:@"autoReload"];
        [editingConfig setObject:[NSNumber numberWithBool:_switchPageBox.state == NSOnState] forKey:@"shouldReloadWhenSwitch"];
        [editingConfig setObject:[_cssField.string copy]  forKey:@"injectingCSS"];
        [editingConfig setObject:[_jsField.string copy] forKey:@"injectingJS"];
        [manager updateInstance:_namePicker.stringValue];
    }else{
        if([manager.configs objectForKey:_namePicker.stringValue]){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"The name is already used. You should pick a unique name."];
            [alert runModal];
            return;
        }
        NSMutableDictionary* ins = [[NSMutableDictionary alloc]
                                    initWithObjects: [[NSArray alloc] initWithObjects:
                                                      _namePicker.stringValue,
                                                      _smallURLField.stringValue,
                                                      _wideURLField.stringValue,
                                                      img,
                                                      [NSNumber numberWithBool:YES], 
                                                      [NSNumber numberWithBool:_autoRefreshBox.state == NSOnState], 
                                                      [NSNumber numberWithBool:_switchPageBox.state == NSOnState],
                                                      [_cssField.string copy],
                                                      [_jsField.string copy],
                                                      nil]
                                    forKeys:[[NSArray alloc] initWithObjects:@"name", @"smallURL", @"wideURL", @"icon", @"enabled", @"autoReload", @"shouldReloadWhenSwitch", @"injectingCSS", @"injectingJS", nil]
                                    ];

        [manager addInstance:ins];
    }
    [_instancesTable reloadData];
    [_namePicker reloadData];
    [self endCreator:sender];
}

- (IBAction)deleteItem:(id)sender {
    if([_instancesTable selectedRow] < 0)return;
    NSAlert* confirm = [NSAlert alertWithMessageText:[NSString stringWithFormat: @"Are you sure you want to delete %@?", [[manager.configs allKeys] objectAtIndex:[_instancesTable selectedRow]]] defaultButton:@"No" alternateButton:@"Yes" otherButton:nil informativeTextWithFormat:@"You cannot undo this action."];
    [confirm beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)showPref:(id)sender {
    [_window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)nameSelected:(id)sender {
    [self matchName];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if(returnCode == NSAlertAlternateReturn){
        [manager removeInstance:[[manager.configs allKeys] objectAtIndex:[_instancesTable selectedRow]]];
        [_instancesTable reloadData];
    }
}

- (IBAction)changeAutoLaunch:(id)sender{
    self.launchAtLogin = [NSNumber numberWithInteger:[sender state]];
}

- (void)setLaunchAtLogin:(NSNumber *)launchAtLogin{
    NSURL *url = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/Library/LoginItems/Webdaemon Helper.app"];
    
	// Registering helper app
	if (LSRegisterURL(CFBridgingRetain(url), true) != noErr) {
		NSLog(@"LSRegisterURL failed!");
	}
    // Setting login
	if (!SMLoginItemSetEnabled((CFStringRef)@"yyjhao.Webdaemon-Helper",
                               (bool)[launchAtLogin boolValue])) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"SMLoginItemSetEnabled failed!"];
        [alert runModal];
	}
}

-(NSNumber*)launchAtLogin{
    CFArrayRef cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([@"yyjhao.Webdaemon-Helper" isEqualToString:[job objectForKey:@"Label"]]) {
                return [NSNumber numberWithBool:[[job objectForKey:@"OnDemand"] boolValue]];
                break;
            }
        }
    }
    return [NSNumber numberWithBool:NO];
}

-(void)networkIsDown{
    
}

-(void)networkIsUp{
    for(NSString* name in manager.daemons){
        [((TopController*)[manager.daemons valueForKey:name]).webpopController loadWebView];
    }
}


@end
