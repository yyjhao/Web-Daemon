//
//  PopView.h
//  Web Daemon
//
//  Translucent view with a small arrow at the top
//  The background color can be changed 
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import <Cocoa/Cocoa.h>

#define LINE_THICKNESS 1.0f
#define ARROW_WIDTH 20
#define ARROW_HEIGHT 10
#define CORNER_RADIUS 15.0f
#define FILL_OPACITY 0.9f

@interface PopView : NSView{
    NSColor* strokeColor;
}

@property (nonatomic, assign) NSInteger arrowX;
@property (nonatomic, copy) NSColor* color;

@end
