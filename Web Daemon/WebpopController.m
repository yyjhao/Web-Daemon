//
//  WebpopController.m
//  Web Daemon
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import "WebpopController.h"

@implementation WebpopController
@synthesize popView;
@synthesize titleLabel;
@synthesize webView;
@synthesize enlargeBut;
@synthesize progressInd;
@synthesize url = _url;
@synthesize wideUrl = _wideUrl;
@synthesize shouldReloadWhenSwitch;
@synthesize autoreloadEnabled;
@synthesize injectingJS;
@synthesize pageController;

NSString *const WideUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10";
NSString *const SmallUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_0 like Mac OS X; en-us) AppleWebKit/534.6 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";

- (id)initWithDelegate:(id<WebpopControllerDelegate, WDNotificationHandler>)delegate
{
    self = [super initWithWindowNibName:@"WebpopController"];
    if(self != nil)
    {
        _delegate = delegate;
        bridge = [[WebToApp alloc] initWithTop:delegate];
        bridge.shouldReplaceHost = NO;
        _usingWide = NO;
        _shouldReplaceHost = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSModalPanelWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    [webView setDrawsBackground:NO];
    [webView setFrameLoadDelegate:self];
    [webView setPolicyDelegate:self];
    [webView setUIDelegate:self];
    [webView setContinuousSpellCheckingEnabled:YES];
    
    [pageController setDelegate: self];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *storagePath = [basePath stringByAppendingPathComponent:@"WebDaemon"];

    WebPreferences* pref = [webView preferences];
    [pref setMinimumFontSize:12];
    [pref _setLocalStorageDatabasePath:storagePath];
    [pref setLocalStorageEnabled:YES];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(loadInProgress:)
        name:WebViewProgressEstimateChangedNotification
        object:webView];
}

+ (NSString *) trimHost: (NSString *)host
{
    NSArray* comps = [host componentsSeparatedByString: @"."];
    unsigned long c = [comps count];
    if(c > 2){
        return [NSString stringWithFormat: @"%@.%@", [comps objectAtIndex: c - 2], [comps lastObject]];
    }else{
        return host;
    }
}

- (void) setWideUrl:(NSString *)wideUrl
{
    _wideUrl = [wideUrl copy];
    wideHost = [WebpopController trimHost: [[NSURL URLWithString: _wideUrl] host]];
}

- (void) setUrl:(NSString *)url
{
    _url = [url copy];
    normalHost = [WebpopController  trimHost: [[NSURL URLWithString: _url] host]];
}

- (BOOL) belongToCurrentHost: (NSString *) host
{
    if ([host length] == 0)return NO;
    NSString* thost = [WebpopController  trimHost:host];
    return [thost isEqualToString: wideHost] || [thost isEqualToString: normalHost];
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
    if(frame == webView.mainFrame){
        [_delegate updateIcon:image];
    }
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setIcon:[_delegate icon]];
    [alert setInformativeText:message];
    [alert setMessageText:[NSString stringWithFormat:@"Web Daemon - %@", [webView mainFrameTitle]]];
    [alert runModal];
}

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setInformativeText:message];
    [alert setMessageText:[NSString stringWithFormat:@"Web Daemon - %@", [webView mainFrameTitle]]];
    [alert setIcon:[_delegate icon]];
    
    return [alert runModal] == NSAlertFirstButtonReturn;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    NSString* newHost = nil;
    if (bridge.shouldReplaceHost){
        newHost = [[NSURL URLWithString: _wideUrl] host];
    }
    return [_delegate openNewWindow:request withHost:newHost];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString* host = [[request URL] host];
    if(([[actionInformation objectForKey:@"WebActionModifierFlagsKey"] integerValue] & NSCommandKeyMask) ||
       (host != nil &&
            frame == [webView mainFrame] &&
            ![self belongToCurrentHost: host]))
    {
        [listener ignore];
        [[NSWorkspace sharedWorkspace] openURL:request.URL];
    }else{
        [listener use];
    }
}

- (BOOL)hasActivePop
{
    return _hasActivePop;
}

- (void)setHasActivePop:(BOOL)flag
{
    if(_hasActivePop != flag)
    {
        _hasActivePop = flag;
        if(flag)
        {
            [self openPanel];
        }else{
            [self closePanel];
            if(toReload){
                [self startReloadTimer];
                toReload = NO;
            }
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePop = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if([[self window] isVisible])
    {
        self.hasActivePop = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusrectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = round(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.popView.arrowX = panelX;
}

- (void)cancelOperation:(id)sender
{
    self.hasActivePop = NO;
}

- (NSRect) statusrectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(24.0, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
    
}


- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusrectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame: panelRect display: YES];
    [self windowDidResize:nil];
    [panel makeKeyAndOrderFront:nil];
    
    if(firstShown){
        [webView scrollToBeginningOfDocument:self];
        firstShown=NO;
    }
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}


- (void)setSize:(NSInteger) w :(NSInteger) h
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusrectForWindow:[self window]];
    
    NSRect panelRect = [[self window] frame];
    panelRect.size.width = w;
    panelRect.size.height = h;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    [[self window] setFrame: panelRect display:YES animate:YES];
}

- (BOOL)usingWide
{
    return _usingWide;
}

- (NSString*)injectingCSS
{
    return _injectingCSS;
}

- (void) setInjectingCSS:(NSString *)injectingCSS
{
    _injectingCSS = [[injectingCSS componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];

}

- (void)setUsingWide:(BOOL)flag
{
    if(_usingWide != flag){
        _usingWide = flag;
        [_delegate updateUsingWide:flag];
        
        if(flag){
            if(shouldReloadWhenSwitch){
                [self setSize: 1024: 760];
            }else{
                [self setSize: 640: 700];
            }
            [enlargeBut setImage:[NSImage imageNamed:@"NSExitFullScreenTemplate"]];
        }else{
            [self setSize:320 :450];
            [enlargeBut setImage:[NSImage imageNamed:@"NSEnterFullScreenTemplate"]];
        }
        if(shouldReloadWhenSwitch){
            [self loadWebView];
        }
    }
}

- (void)loadInProgress:(NSNotification *)notification
{
    if(1 - [webView estimatedProgress] < 0.01){
        [progressInd setHidden:YES];
        [titleLabel setStringValue:[webView mainFrameTitle]];
    }
    [progressInd setDoubleValue: [webView estimatedProgress] * 100];
}

- (void)startReloadTimer
{
    [self stopReloadTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_INTERVAL
                                             target:self
                                           selector:@selector(refreshWebview)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)stopReloadTimer{
    [timer invalidate];
    timer = nil;
}

- (void)setAutoreloadEnabled:(BOOL)au
{
    if(au){
        [self startReloadTimer];
    }else{
        [self stopReloadTimer];
        toReload = NO;
    }
}

- (void)refreshWebview{
    if(_hasActivePop){
        toReload = YES;
        [self stopReloadTimer];
    }else{
        [self loadWebView];
    }
}

- (void)loadWebView{
    [progressInd setHidden:NO];
    [titleLabel setStringValue:@"Loading..."];
    [progressInd setDoubleValue:0];
    if(_usingWide && shouldReloadWhenSwitch)
    {
        [webView setCustomUserAgent:WideUserAgent];
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString: _wideUrl]];
        [[webView mainFrame] loadRequest:request];
    }else{
        [webView setCustomUserAgent:SmallUserAgent];

        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString: _url]];
        [[webView mainFrame] loadRequest:request];
    }

}

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{
    [windowObject setValue:bridge forKey:@"WebDaemon"];
    if(frame == [webView mainFrame] && frame.dataSource.request.URL.host.length){
        [webView stringByEvaluatingJavaScriptFromString:
            [NSString stringWithFormat: @"document.addEventListener('DOMContentLoaded', function () {%@;%@;}, false);%@",
                [NSString stringWithFormat: @"var s = document.createElement('style'); s.innerHTML='%@'; document.head.appendChild(s);", _injectingCSS],
//                @"[].forEach.call(document.querySelectorAll('a[href^=\"http\"]'),function(elm){if(elm.hostname != location.host){elm.target='_blank';}});if(window.$ && $(document).on){$(document).on('click',function(e){$(e.target).trigger('tap')});}",
                @"",
                injectingJS]];
        [_delegate updateStatus:loadOK];
        firstShown = YES;
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    [frame loadHTMLString:[NSString stringWithFormat:@"<head><title>Error</title><body><h2 class='wd-error-string'>%@</h1>", error.localizedDescription] baseURL:nil];
    [_delegate updateStatus:loadError];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if(error.code != -999){
        [frame loadHTMLString:[NSString stringWithFormat:@"<head><title>Error</title><body><h2 class='wd-error-string'>%@</h1>", error.localizedDescription] baseURL:nil];
        [_delegate updateStatus:loadError];
    }
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame {
    if (frame == [sender mainFrame]) {
        id object = [sender.backForwardList currentItem];
        BOOL isCurrentItem = self.currentItem && (object == self.currentItem) ? YES : NO;
        if (!isCurrentItem) {
            [self.pageController navigateForwardToObject:[sender.backForwardList currentItem]];
        }
    }
}


- (void)pageControllerWillStartLiveTransition:(NSPageController *)pageController {
    self.currentItem = [self.webView.backForwardList currentItem];
}

- (void)pageController:(NSPageController *)pageController didTransitionToObject:(id)object {
    BOOL isCurrentItem = self.currentItem && (object == self.currentItem) ? YES : NO;
    if (!isCurrentItem) {
        self.currentItem = object;
        [self.webView goToBackForwardItem:object];
    }
}

- (void)pageControllerDidEndLiveTransition:(NSPageController *)pageController {
    self.currentItem = nil;
    [pageController completeTransition];
}

-(void)dealloc
{
    [[webView mainFrame] loadHTMLString: @"" baseURL: nil];
    [webView stopLoading:self];
}


- (IBAction)changeStyle:(id)sender {
    self.usingWide = !self.usingWide;
}

- (IBAction)toHome:(id)sender {
    [self loadWebView];
}

- (IBAction)openOut:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: _wideUrl]];
}
@end
