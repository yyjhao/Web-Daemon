//
//  GradientBackgroundView.m
//  Web Daemon
//
//  Created by Yujian Yao on 30/7/12.
//
//

#import "GradientBackgroundView.h"

@implementation GradientBackgroundView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    NSRect contentRect = [self bounds];
    //[[NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY] setFill];
    NSGradient *gard = [[NSGradient alloc] initWithStartingColor: startingColor
                                                     endingColor:endingColor];
    [gard drawInRect:contentRect angle:90];
    
}

- (void)setGradientColor:(NSColor *)color fromTop:(BOOL)fromTop
{
    float st = 0, ed = 0;
    if(fromTop){
        st = 1;
    }else{
        ed = 1;
    }
    startingColor = [NSColor colorWithSRGBRed:color.redComponent green:color.greenComponent blue:color.blueComponent alpha:st];
    endingColor = [NSColor colorWithSRGBRed:color.redComponent green:color.greenComponent blue:color.blueComponent alpha:ed];
}

@end
