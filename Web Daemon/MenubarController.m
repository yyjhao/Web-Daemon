//
//  menubarController.m
//  Web Daemon
//
//  Created by Yujian Yao on 15/7/12.
//

#import "MenubarController.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;
@synthesize statusItem = _statusItem;
@synthesize icon = _icon;
@synthesize grayIcon = _grayIcon;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:_statusItem];
        _icon = [NSImage imageNamed:@"wdori"];
        [_icon setSize:NSSizeFromString(@"16x16")];
        _statusItemView.alternateImage = _icon;
        [_grayIcon setSize:NSSizeFromString(@"16x16")];
        _statusItemView.image = _grayIcon;
        _statusItemView.action = @selector(togglePanel:);
        _statusItemView.rightAction = @selector(showMenu:);
    }
    return self;
}

-(void) setIcon:(NSImage *)icon
{
    [icon setSize:NSSizeFromString(@"16x16")];
    _statusItemView.alternateImage = icon;
    _icon = icon;
    _grayIcon = [self filterImageToGray:icon];
    [_grayIcon setSize:NSSizeFromString(@"16x16")];
    _statusItemView.image = _grayIcon;
    _notiIcon = [self filterImageToNoti:icon];
    [_notiIcon setSize:NSSizeFromString(@"16x16")];
    _errorIcon = [self filterImageToError:icon];
    [_errorIcon setSize:NSSizeFromString(@"16x16")];
}

- (void)setStatusItemViewTarget:(id)tar{
    _statusItemView.target = tar;
}

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
}

- (NSImage *)filterImageToGray:(NSImage *)srcImage
{
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep 
                                     imageRepWithData:[srcImage TIFFRepresentation]]; 
    
    NSInteger w = [srcImageRep pixelsWide];
    NSInteger h = [srcImageRep pixelsHigh];
    int x, y; 
    
    NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(w,h)]; 
    
    NSBitmapImageRep *grayImageRep = [srcImageRep copy];
    
    unsigned char *srcData = [srcImageRep bitmapData]; 
    unsigned char *destData = [grayImageRep bitmapData]; 
    unsigned char *p1, *p2; 
    long n = [srcImageRep bitsPerPixel] / 8;
    
    for ( y = 0; y < h; y++ ) { 
        for ( x = 0; x < w; x++ ) { 
            p1 = srcData + n * (y * w + x); 
            p2 = destData + n * (y * w + x); 
            
            p2[1] = p2[2] = p2[0] = (unsigned char)rint( pow((p1[0] + p1[1] + p1[2]) / 3, 5) / pow( 255, 4));
            p2[3] = p1[3];
        } 
    } 
    
    [destImage addRepresentation:grayImageRep]; 
    return destImage; 
}


- (NSImage *)filterImageToError:(NSImage *)srcImage
{
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep
                                     imageRepWithData:[srcImage TIFFRepresentation]];
    
    NSInteger w = [srcImageRep pixelsWide];
    NSInteger h = [srcImageRep pixelsHigh];
    int x, y;
    
    NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(w,h)];
    
    NSBitmapImageRep *grayImageRep = [srcImageRep copy];
    
    unsigned char *srcData = [srcImageRep bitmapData];
    unsigned char *destData = [grayImageRep bitmapData];
    unsigned char *p1, *p2;
    long n = [srcImageRep bitsPerPixel] / 8;
    
    for ( y = 0; y < h; y++ ) {
        for ( x = 0; x < w; x++ ) {
            p1 = srcData + n * (y * w + x);
            p2 = destData + n * (y * w + x);
            
            p2[1] = p2[2] = p2[0] = (unsigned char)rint( pow((p1[0] + p1[1] + p1[2]) / 3, 5) / pow( 255, 4));
            p2[3] = p1[3] / 3;
        }
    }
    
    [destImage addRepresentation:grayImageRep];
    return destImage;
}

- (NSImage *)filterImageToNoti:(NSImage *)srcImage
{
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep
                                     imageRepWithData:[srcImage TIFFRepresentation]];
    
    NSInteger w = [srcImageRep pixelsWide];
    NSInteger h = [srcImageRep pixelsHigh];
    int x, y;
    
    NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(w,h)];
    
    NSBitmapImageRep *grayImageRep = [srcImageRep copy];
    
    unsigned char *srcData = [srcImageRep bitmapData];
    unsigned char *destData = [grayImageRep bitmapData];
    unsigned char *p1, *p2;
    long n = [srcImageRep bitsPerPixel] / 8;
    
    for ( y = 0; y < h; y++ ) {
        for ( x = 0; x < w; x++ ) {
            p1 = srcData + n * (y * w + x);
            p2 = destData + n * (y * w + x);
            
            p2[1] = p2[2] = (unsigned char)rint((p1[0] + p1[1] + p1[2]) / 3);
            p2[0] = 255;
            p2[3] = p1[3];
        }
    }
    
    [destImage addRepresentation:grayImageRep];
    return destImage;
}


- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}
@end
