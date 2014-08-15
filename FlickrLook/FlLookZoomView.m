//
//  FlLookZoomView.m
//  FlickrLook
//
//  Created by steven harris on 8/15/14.
//  Copyright (c) 2014 steven harris. All rights reserved.
//

#import "FlLookZoomView.h"

@implementation FlLookZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)slideViewOffScreen
{
    // Get the frame of this view
    CGRect frame = self.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.45];
    
    // Set view to this offscreen location
    frame.origin.x = -320;
    self.frame = frame;
    
    // Slide view
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
