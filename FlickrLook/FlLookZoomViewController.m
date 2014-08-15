//
//  FlLookZoomViewController.m
//  FlickrLook
//
//  Created by steven harris on 8/14/14.
//  Copyright (c) 2014 steven harris. All rights reserved.
//

#import "FlLookZoomViewController.h"
#import "JSON.h"

#define debug(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);

@interface FlLookZoomViewController ()

@end

@implementation FlLookZoomViewController

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (id)initWithURL:(NSURL *)url commentURL:(NSURL *)commentUrl;
{
    if (self = [super init])
    {
        // Create the view offscreen (to the right)
        self.zoomView.frame = CGRectMake(320, 0, 320, 240);
        
        // Setup image
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        fullsizeImage = [[FlLookZoomView alloc] initWithImage:[UIImage imageWithData:imageData]];
        
        // Get comments and author!
        
        //NSURL *url = [NSURL URLWithString:commentUrl];
        
        
        // Setup and start async download
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: commentUrl];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        // Center the image...
        int width = fullsizeImage.frame.size.width;
        int height = fullsizeImage.frame.size.height;
        
        int x = (320 - width) / 2;
        int y = (240 - height) / 2;
        
        [fullsizeImage setFrame:CGRectMake(x, y, width, height)];
        fullsizeImage.userInteractionEnabled = YES;
        [self.zoomView addSubview:fullsizeImage];
        
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Store incoming data into a string
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Got comments response:%@", jsonString);
    
    // Create a dictionary from the JSON string
	NSDictionary *results = [jsonString JSONValue];
	
    // Build an array from the dictionary for easy access to each entry
	//NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
    
}

#pragma mark -
#pragma mark Event Mgmt

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.zoomView slideViewOffScreen];
    
    // We now send the same event up to the next responder
    // (the JSONFlickrViewController) so we can show enable
    // the search textfield again
    [self.nextResponder touchesBegan:touches withEvent:event];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
