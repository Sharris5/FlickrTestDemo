//
//  FlLookViewController.h
//  FlickrLook
//
//  Created by steven harris on 8/14/14.
//  Copyright (c) 2014 steven harris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlLookZoomViewController.h"

@interface FlLookViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    
        UITextField     *searchTextField;
 
        NSMutableArray  *photoTitles;         // Titles of images
        NSMutableArray  *photoSmallImageData; // Image data (thumbnail)
        NSMutableArray  *photoURLsLargeImage; // URL to larger image
        NSMutableArray  *commentsURLsLargeImage; // URL to larger image
        
        FlLookZoomViewController  *fullImageViewController;
        UIActivityIndicatorView *activityIndicator;      
    
}

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UITableView *theTableView;
@end
