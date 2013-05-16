//
//  topController.m
//  Web Daemon
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import "topController.h"

@implementation TopController

@synthesize menuBarController;
@synthesize webpopController;
@synthesize name;
@synthesize manager;

- (id)initWithConfig:(NSMutableDictionary *)config
{
    self = [super init];
    if(self){
        self.menuBarController = [[MenubarController alloc] init];
        [menuBarController setStatusItemViewTarget:self];
        _notified = NO;
        webpopController = [[WebpopController alloc] initWithDelegate:self];
        [webpopController addObserver:self forKeyPath:@"hasActivePop" options:0 context:kContextActivePanel];
        
        [self updateWithConfig:config];
    }
    
    return self;
}

- (void)updateWithConfig:(NSMutableDictionary *)config
{
    webpopController.url = [config objectForKey:@"smallURL"];
    webpopController.wideUrl = [config objectForKey:@"wideURL"];
    webpopController.shouldReloadWhenSwitch = [[config objectForKey:@"shouldReloadWhenSwitch"] boolValue];
    
    NSString* css = [config objectForKey:@"injectingCSS"];
    if(css){
        [webpopController setInjectingCSS: css];
    }
    
    NSString* js = [config objectForKey:@"injectingJS"];
    if(js){
        [webpopController setInjectingJS: js];
    }
    
    [webpopController awakeFromNib];
    
    self.name = [config objectForKey:@"name"];
    
    NSImage* icon = [config objectForKey:@"icon"];
    if((id)icon == (id)[NSNull null]){
        icon = [NSImage imageNamed:@"wdori"];
    }
    [self setIcon:icon];
    
    webpopController.autoreloadEnabled = [[config objectForKey:@"autoReload"] boolValue];
    webpopController.usingWide = [[config objectForKey:@"usingWide"] boolValue];
    
    [webpopController loadWebView];
}

-(WebView*)openNewWindow:(NSURLRequest *)request withHost:(NSString *)host
{
    return [manager webViewForOpeningNewWindowWithHost:host];
}


void *kContextActivePanel = &kContextActivePanel;

- (void)updateIcon:(NSImage *)icon
{
    if([manager updateIcon:icon ofName:name]){
        //manage says yes, we can now change on our side
        [self setIcon:icon];
    };
}

- (void)setIcon:(NSImage*)icon
{
    NSImage *tmp = [icon copy];
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep
                                     imageRepWithData:[tmp TIFFRepresentation]];
    
    NSInteger w = [srcImageRep pixelsWide];
    NSInteger h = [srcImageRep pixelsHigh];
    int x, y;
    
    unsigned char *srcData = [srcImageRep bitmapData];
    long n = [srcImageRep bitsPerPixel] / 8;
    long r = 0,g = 0,b = 0;
    unsigned char *p1;
    
    for ( y = 0; y < h; y++ ) {
        for ( x = 0; x < w; x++ ) {
            p1 = srcData + n * (y * w + x);
            r += p1[0];
            g += p1[1];
            b += p1[2];
        }
    }
    NSInteger count = w * h * 255;
    webpopController.popView.color = [NSColor colorWithDeviceRed:(double)r / count green:(double)g / count blue: (double)b / count alpha:1];
    
    menuBarController.icon = icon;
    
    _icon = icon;
}

- (NSImage*)icon{
    return _icon;
}

- (void)updateUsingWide:(BOOL)usingWide
{
    [manager updateUsingWide:usingWide ofName:name];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menuBarController.hasActiveIcon = self.webpopController.hasActivePop;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)togglePanel:(id)sender
{
    self.menuBarController.hasActiveIcon = !self.menuBarController.hasActiveIcon;
    self.webpopController.hasActivePop = self.menuBarController.hasActiveIcon;
    if(self.menuBarController.hasActiveIcon){
        _notified = NO;
        if(menuBarController.statusItemView.image == menuBarController.notiIcon){
            menuBarController.statusItemView.image = menuBarController.grayIcon;
        }
    }
}

- (void)showMenu: (id)sender
{
    manager.daemonToDisable = self;
    [[sender statusItem] popUpStatusItemMenu:manager.menu];
}

- (StatusItemView *)statusItemViewForPanelController:(WebpopController *)controller
{
    return self.menuBarController.statusItemView;
}

-(void)grabAttention
{
    if(!_notified && !self.menuBarController.hasActiveIcon){
        [[NSSound soundNamed:@"Glass"] play];
        menuBarController.statusItemView.image = menuBarController.notiIcon;
        _notified = YES;
    }
}

-(void)cancelAttention{
    if(_notified){
        _notified = NO;
        if(!self.menuBarController.hasActiveIcon){
            menuBarController.statusItemView.image = menuBarController.grayIcon;
        }
    }
}

-(void)updateStatus:(WebpopStatus)status{
    if(status == loadError){
        menuBarController.statusItemView.image = menuBarController.errorIcon;
    }else{
        menuBarController.statusItemView.image = menuBarController.grayIcon;
    }
}

- (void)dealloc
{
    self.menuBarController.hasActiveIcon = NO;
    self.webpopController.hasActivePop = NO;
    [webpopController removeObserver:self forKeyPath:@"hasActivePop"];
}

@end
