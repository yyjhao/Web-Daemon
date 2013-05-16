//
//  StatusItemView.m
//  Web Daemon
//
//  Created by Yujian Yao on 15/7/12.
//

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = round((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon drawAtPoint:iconPoint fromRect:bounds operation:NSCompositeSourceOver fraction:1];
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if(self != nil){
        _statusItem = statusItem;
        _statusItem.view = self;
    }
    return self;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [NSApp sendAction:self.rightAction to:self.target from:self];
}


- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}


- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

- (void)setImage:(NSImage *)newImage
{
    if(_image != newImage){
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage{
    if(_alternateImage != newImage){
        _alternateImage = newImage;
        if(self.isHighlighted){
            [self setNeedsDisplay:YES];
        }
    }
}

- (NSRect)globalRect{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
