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
- (WebView*)openNewWindow:(NSURLRequest*)request withHost:(NSString*)host;
- (void)updateStatus:(WebpopStatus)status;
- (NSImage*)icon;

@end

@interface WebpopController : NSWindowController<NSPageControllerDelegate>{
    BOOL _hasActivePop;
    BOOL _usingWide;
    NSString* _injectingCSS;
    BOOL toReload;
    NSTimer* timer;
    WebToApp* bridge;
    BOOL firstShown;
    NSString *wideHost, *normalHost;
}


@property (weak) IBOutlet PopView *popView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSButton *enlargeBut;
@property (weak) IBOutlet NSProgressIndicator *progressInd;
@property (unsafe_unretained) IBOutlet NSPageController *pageController;

- (IBAction)changeStyle:(id)sender;
- (IBAction)toHome:(id)sender;
- (IBAction)openOut:(id)sender;

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* wideUrl;
@property (nonatomic) BOOL hasActivePop;
@property (nonatomic, readonly, weak) id<WebpopControllerDelegate> delegate;
@property (nonatomic) BOOL usingWide;
@property (nonatomic) BOOL shouldReloadWhenSwitch;
@property (nonatomic) BOOL autoreloadEnabled;
@property NSString* injectingJS;
@property NSString* injectingCSS;
@property BOOL shouldReplaceHost;
@property (assign) id currentItem;

-(id)initWithDelegate:(id<WebpopControllerDelegate>)delegate;

-(void)openPanel;
-(void)closePanel;
-(NSRect)statusrectForWindow:(NSWindow *)window;
-(void)loadWebView;

@end
