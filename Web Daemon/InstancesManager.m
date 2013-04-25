//
//  InstancesManager.m
//  Web Daemon
//
//  Created by Yujian Yao on 18/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InstancesManager.h"

@implementation InstancesManager

@synthesize daemons;
@synthesize configs;
@synthesize menu;

-(id)init{
    self = [super init];
    if(self){
        NSArray *paths =
        NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                            NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] :
        NSTemporaryDirectory();
        NSString* storagePath = [basePath stringByAppendingPathComponent:@"WebDaemon"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:storagePath isDirectory:NULL] ) {
            if (![fileManager createDirectoryAtPath:storagePath
                  withIntermediateDirectories:NO attributes:nil error:&error])
            {
                NSAssert(NO, ([NSString stringWithFormat:
                               @"Failed to create App Support directory %@ : %@",
                               storagePath,error]));
                NSLog(@"Error creating application support directory at %@ : %@",
                      storagePath,error);
                return nil;
            } 
        }
        specificSettings = [NSDictionary
                            dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                          pathForResource:@"specific"
                                                          ofType:@"plist"]];
        specificAttributes = [NSArray arrayWithObjects:@"injectingJS", @"shouldReplaceHost", nil];
        storedFile = [storagePath stringByAppendingPathComponent:@"configs.data"];
        configs = [NSKeyedUnarchiver unarchiveObjectWithFile:storedFile];
        if(configs == nil){
            configs = [[NSMutableDictionary alloc] init];
        }
        daemons = [NSMutableDictionary new];
        for (NSString* config in configs) {
            [self updateInstance: config];
        }
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        oriPreloadedSettings = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                                 pathForResource:@"preloaded"
                                                                 ofType:@"plist"]];
        _preloadedSettings = [NSMutableArray arrayWithArray:oriPreloadedSettings];
        preloadedSettingsNames = [NSMutableArray new];
        BOOL repeated;
        
        for (NSDictionary* item in oriPreloadedSettings){
            repeated = NO;
            for(NSString* config in configs){
                if([config isEqualToString:[item objectForKey:@"name"]]){
                    [_preloadedSettings removeObject:item];
                    repeated = YES;
                    break;
                }
            }
            if(!repeated){
               [preloadedSettingsNames addObject:[item objectForKey:@"name"]];
            }
        }
        _webviewForOpeningNewWindow = [WebView new];
        [_webviewForOpeningNewWindow setPolicyDelegate:self];
    }
    return self;
}

- (WebView*)webViewForOpeningNewWindowWithHost:(NSString *)host
{
    tmpHost = host;
    return _webviewForOpeningNewWindow;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener ignore];
    if(tmpHost){
        NSURL* newURL = [NSURL URLWithString:[[request.URL absoluteString] stringByReplacingOccurrencesOfString:request.URL.host withString:tmpHost]];
        NSLog(@"%@ %@ %@",newURL,request.URL, [[request.URL absoluteString] stringByReplacingOccurrencesOfString:request.URL.host withString:tmpHost]);
        [[NSWorkspace sharedWorkspace] openURL:newURL];
    }else{
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }
}

-(void)finalize
{
    [self saveData];
    [super finalize];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [configs count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSMutableDictionary* config = [configs objectForKey: [[configs allKeys] objectAtIndex:row]];
    
    if([tableColumn.identifier isEqualToString: @"icon"]){
        NSImage* icon = [config objectForKey:@"icon"];
        if((id)icon == [NSNull null]){
            return nil;
        }
        return icon;
    }else if([tableColumn.identifier isEqualToString:@"name"]){
        return [config objectForKey:@"name"];
    }else if([tableColumn.identifier isEqualToString:@"enabled"]){
        return [config objectForKey:@"enabled"];
    }else{
        return nil;
    };
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(![tableColumn.identifier isEqualToString:@"enabled"]){
        return;
    }
    NSMutableDictionary* config = [configs objectForKey: [[configs allKeys] objectAtIndex:row]];
    [config setObject:object forKey:@"enabled"];
    [self updateInstance:[config objectForKey:@"name"]];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [preloadedSettingsNames count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [preloadedSettingsNames objectAtIndex:index];
}

- (NSString*)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string
{
    for (NSString* item in preloadedSettingsNames){
        if([[item lowercaseString] hasPrefix:[string lowercaseString]]){
            return item;
        }
    }
    return nil;
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    return [preloadedSettingsNames indexOfObject:string];
}

-(BOOL)addInstance:(NSMutableDictionary *)ins
{
    if([configs objectForKey:[ins objectForKey:@"name"]]){
        return NO;
    }
    NSString* name = [ins objectForKey:@"name"];
    [configs setObject: ins forKey:name];
    [self updateInstance:name];
    if([preloadedSettingsNames containsObject:name]){
        NSUInteger index = [preloadedSettingsNames indexOfObject:name];
        [preloadedSettingsNames removeObject:name];
        [_preloadedSettings removeObjectAtIndex:index];
    }
    return YES;
}

-(BOOL)removeInstance:(NSString *)name
{
    if(![configs objectForKey:name]){
        return NO;
    }
    [configs removeObjectForKey:name];
    [self updateInstance:name];
    for(NSDictionary* item in oriPreloadedSettings){
        if([[item objectForKey:@"name"] isEqualToString:name]){
            [_preloadedSettings addObject:item];
            [preloadedSettingsNames addObject:name];
        }
    }
    return YES;
}

-(void)updateInstance:(NSString *)name 
{
    TopController* daemon = [daemons objectForKey:name];
    NSMutableDictionary *config = [configs objectForKey:name];
    if(config){
        NSString* url = [config objectForKey:@"smallURL"];
        if(![url hasPrefix:@"http://"] && (![url hasPrefix:@"https://"] && (![url hasPrefix:@"file://"]))){
            [config setValue:[NSString stringWithFormat:@"http://%@", url] forKey:@"smallURL"];
        }
        url = [config objectForKey:@"wideURL"];
        if(![url hasPrefix:@"http://"] && (![url hasPrefix:@"https://"] && (![url hasPrefix:@"file://"]))){
            [config setValue:[NSString stringWithFormat:@"http://%@", url] forKey:@"wideURL"];
        }
    }
    if(daemon && (!config || ![[config objectForKey:@"enabled"] boolValue])){
        NSLog(@"deleting");
        [daemons removeObjectForKey:name];
        [daemon.webpopController.webView.windowScriptObject setValue:nil forKey:@"WebDaemon"];
        daemon = nil;
    }else if([[config objectForKey:@"enabled"] boolValue] && config && !daemon){
        daemon = [[TopController alloc] initWithConfig:config];
        daemon.manager = self;
        NSURL* url = [NSURL URLWithString:[config objectForKey:@"smallURL"]];
        NSDictionary* setting = [specificSettings objectForKey:url.host];
        if(setting){
            for(NSString* attribute in specificAttributes){
                NSString* value = [setting objectForKey:attribute];
                if(value){
                    [daemon.webpopController setValue:value forKey:attribute];
                }
            }
        }
        [daemon.webpopController loadWebView];
        [daemons setObject:daemon forKey:name];
    }else{
        [daemon updateWithConfig:config];
    }
}

-(void)renameInstance:(NSString *)oldname to:(NSString *)newName
{
    NSMutableDictionary* config = [configs objectForKey:oldname];
    TopController* daemon = [daemons objectForKey:oldname];
    daemon.name = newName;
    [configs removeObjectForKey:oldname];
    [config setObject:newName forKey:@"name"];
    [configs setObject:config forKey:newName];
    [daemons removeObjectForKey:oldname];
    [daemons setObject:daemon forKey:newName];
    for(NSDictionary* item in oriPreloadedSettings){
        if([[item objectForKey:@"name"] isEqualToString:oldname]){
            [_preloadedSettings addObject:item];
            [preloadedSettingsNames addObject:oldname];
        }
    }
    if([preloadedSettingsNames containsObject:newName]){
        NSUInteger index = [preloadedSettingsNames indexOfObject:newName];
        [preloadedSettingsNames removeObject:newName];
        [_preloadedSettings removeObjectAtIndex:index];
    }
}

-(BOOL)updateIcon:(NSImage *)icon ofName:(NSString *)name
{
    NSMutableDictionary* config = [configs objectForKey:name];
    //only allow updating icon if there's no icon set
    if([config objectForKey:@"icon"] == [NSNull null]){
        [config setObject:icon forKey:@"icon"];
        return YES;
    }
    return NO;
}

-(void)updateUsingWide:(BOOL)usingWide ofName:(NSString *)name
{
    NSMutableDictionary* config = [configs objectForKey:name];
    [config setObject:[NSNumber numberWithBool:usingWide] forKey:@"usingWide"];
}

-(void)saveData
{
    NSLog(@"saved");
    [NSKeyedArchiver archiveRootObject:configs toFile:storedFile];
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    TopController* daemon = [daemons objectForKey:[notification.userInfo objectForKey:@"name"]];
    if(!daemon.webpopController.hasActivePop){
        [daemon togglePanel:self];
    }
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
}

-(IBAction)disableDaemon:(id)sender{
    NSString* name = [[daemons allKeysForObject:_daemonToDisable] objectAtIndex:0];
    [[configs objectForKey:name] setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
    [self updateInstance:name];
}

@end
