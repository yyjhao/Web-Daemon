//
//  StatusItemView.h
//  Web Daemon
//
//  The icon for each daemon in the statusbar
//
//  Created by Yujian Yao on 15/7/12.
//

#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, weak, readonly) NSStatusItem *statusItem;
@property (nonatomic, weak) NSImage *image;
@property (nonatomic, weak) NSImage *alternateImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic) SEL rightAction;
@property (nonatomic, weak) id target;


@end
