//
//  PopView.m
//  Web Daemon
//
//  Created by Yujian Yao on 28/7/12.
//
//

#import "PopView.h"

@implementation PopView


@synthesize arrowX = _arrowX;
@synthesize color;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        color = [NSColor colorWithDeviceWhite:0.9 alpha:FILL_OPACITY];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect contentRect = NSInsetRect([self bounds], LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(_arrowX, NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(_arrowX + ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) -  CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)];
    
    NSPoint toRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) -ARROW_HEIGHT - CORNER_RADIUS) controlPoint1:toRightCorner controlPoint2: toRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) +CORNER_RADIUS)];
    
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect)) controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))];
    
    [path curveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS) controlPoint1:contentRect.origin controlPoint2:contentRect.origin];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(_arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    NSGradient *gard = [[NSGradient alloc] initWithStartingColor: [NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY]
                                                     endingColor:color];
    [gard drawInBezierPath: path angle: 90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [strokeColor setStroke];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
    
}

- (void)setArrowX:(NSInteger)value
{
    _arrowX = value;
    [self setNeedsDisplay:YES];
}

- (void) setColor:(NSColor *)val
{
    color = [NSColor colorWithCalibratedHue:val.hueComponent saturation: pow(val.saturationComponent, 3) brightness: 1 - pow(1 - val.brightnessComponent, 3) alpha:FILL_OPACITY];
    strokeColor = [NSColor colorWithCalibratedHue:color.hueComponent saturation: pow(color.saturationComponent, 3) brightness: 1 - pow(1 - color.brightnessComponent, 3) alpha:FILL_OPACITY];
    [self setNeedsDisplay:YES];
}


@end
