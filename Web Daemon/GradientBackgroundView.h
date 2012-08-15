//
//  GradientBackgroundView.h
//  Web Daemon
//
//  Created by Yujian Yao on 30/7/12.
//
//

#import <Cocoa/Cocoa.h>

@interface GradientBackgroundView : NSView{
    NSColor* startingColor;
    NSColor* endingColor;
}

-(void)setGradientColor:(NSColor*)color fromTop:(BOOL)fromTop;

@end
