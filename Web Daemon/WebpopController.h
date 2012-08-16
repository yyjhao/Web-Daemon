//
//  WebpopController.h
//  Web Daemon
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import <Cocoa/Cocoa.h>
#import "StatusItemView.h"
#import "PopView.h"
#import "GradientBackgroundView.h"
#import <WebKit/WebKit.h>
#import "WebToApp.h"
#import <SystemConfiguration/SCNetworkReachability.h>

#define OPEN_DURATION 0.18
#define CLOSE_DURATION .1
#define RELOAD_INTERVAL 120

typedef enum{
    loadError,
    loadOK
} WebpopStatus;

@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
@end

@class WebpopController;

@protocol WebpopControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(WebpopController *)controller;
- (void)updateIcon:(NSImage*)icon;
- (void)updateUsingWide:(BOOL)usingWide;
- (WebView*)openNewWindow:(NSURLRequest*)request;
- (void)updateStatus:(WebpopStatus)status;

@end

@interface WebpopController : NSWindowController{
    BOOL _hasActivePop;
    BOOL _usingWide;
    BOOL toReload;
    NSTimer* timer;
    WebToApp* bridge;
    BOOL firstShown;
}


@property (weak) IBOutlet PopView *popView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSButton *enlargeBut;
@property (weak) IBOutlet NSProgressIndicator *progressInd;

- (IBAction)changeStyle:(id)sender;
- (IBAction)toHome:(id)sender;

@property (retain) NSString* url;
@property (retain) NSString* wideUrl;
@property (nonatomic) BOOL hasActivePop;
@property (nonatomic, readonly, weak) id<WebpopControllerDelegate> delegate;
@property (nonatomic) BOOL usingWide;
@property (nonatomic) BOOL shouldReloadWhenSwitch;
@property (nonatomic) BOOL autoreloadEnabled;
@property NSString* smallUserAgent;
@property NSString* wideUserAgent;
@property NSString* injectingJS;

-(id)initWithDelegate:(id<WebpopControllerDelegate>)delegate;

-(void)openPanel;
-(void)closePanel;
-(NSRect)statusrectForWindow:(NSWindow *)window;
-(void)loadWebView;
-(void)canConnect;

@end
