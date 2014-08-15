//
//  FlLookZoomViewController.h
//  FlickrLook
//
//  Created by steven harris on 8/14/14.
//  Copyright (c) 2014 steven harris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlLookZoomView.h"

@interface FlLookZoomViewController : UIViewController
{
    FlLookZoomView *fullsizeImage;
}

- (id)initWithURL:(NSURL *)url commentURL:(NSURL *)commentUrl;

@property (nonatomic, weak) IBOutlet FlLookZoomView *zoomView;

@end
