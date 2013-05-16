//
//  AppDelegate.m
//  Webdaemon Helper
//
//  This helper allows one to make the app start at login
//
//  Created by Yujian Yao on 13/8/12.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath]
                            stringByDeletingLastPathComponent]
                           stringByDeletingLastPathComponent]
                          stringByDeletingLastPathComponent]
                         stringByDeletingLastPathComponent]; // Removes path down to /Applications/Great.app
    NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath]; // Uses string with bundle binary executable
    [[NSWorkspace sharedWorkspace] launchApplication:binaryPath]; // Launches binary
    [NSApp terminate:nil];
}

@end
