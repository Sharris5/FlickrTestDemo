//
//  FlLookViewController.m
//  FlickrLook
//
//  Created by steven harris on 8/14/14.
//  Copyright (c) 2014 steven harris. All rights reserved.
//

#import "FlLookViewController.h"
#import "Json.h"
#import "FlLookZoomViewController.h"


#define debug(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Private interface definitions
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
@interface FlLookViewController(private)
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)slideViewOffScreen;
- (void)searchFlickrPhotos:(NSString *)text;
@end

//#error
// Replace this with your Flickr key

NSString *const FlickrAPIKey = @"1261ad68b2d5178166d83dfe8d60eb94";
NSString *const FlickrAPISecret = @"d1045080fd6ffa53";

@implementation FlLookViewController

/**************************************************************************
 *
 * Private implementation section
 *
 **************************************************************************/

#pragma mark -
#pragma mark Private Methods

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    
    [photoTitles removeAllObjects];
    [photoSmallImageData removeAllObjects];
    [photoURLsLargeImage removeAllObjects];
    [commentsURLsLargeImage removeAllObjects];
    
    [self searchFlickrPhotos:searchTextField.text];
    
    [activityIndicator startAnimating];
    
	return YES;
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Store incoming data into a string
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"CALLING:%@", jsonString);
    
    // Create a dictionary from the JSON string
	NSDictionary *results = [jsonString JSONValue];
	
    // Build an array from the dictionary for easy access to each entry
	NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
    
    // Loop through each entry in the dictionary...
	for (NSDictionary *photo in photos)
    {
        // Get title of the image
		NSString *title = [photo objectForKey:@"title"];
        
        // Save the title to the photo titles array
		[photoTitles addObject:(title.length > 0 ? title : @"Untitled")];
		
        // Build the URL to where the image is stored (see the Flickr API)
        // In the format http://farmX.static.flickr.com/server/id/secret
        // Notice the "_s" which requests a "small" image 75 x 75 pixels
		NSString *photoURLString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_s.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        // The performance (scrolling) of the table will be much better if we
        // build an array of the image data here, and then add this data as
        // the cell.image value (see cellForRowAtIndexPath:)
		[photoSmallImageData addObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
        
        // Build and save the URL to the large image so we can zoom
        // in on the image if requested
		photoURLString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_m.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
		[photoURLsLargeImage addObject:[NSURL URLWithString:photoURLString]];
        
        // Build the string to call the Flickr API for username and comments
        NSString *commentsURLString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&secret=%@", FlickrAPIKey, [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        
        [commentsURLsLargeImage addObject:[NSURL URLWithString:commentsURLString]];
 
        NSURL *commentsURL = [NSURL URLWithString:commentsURLString];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL: commentsURL];
        
        [NSURLConnection
         sendAsynchronousRequest:request
         queue:[[NSOperationQueue alloc] init]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)
         {
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             if ([data length] >0 && error == nil && [httpResponse statusCode] == 200)
             {
                 NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 
                 NSLog(@"Got comments response:%@", jsonString);
                 
                 // Create a dictionary from the JSON string
                 NSDictionary *results = [jsonString JSONValue];
                 
                 NSLog(@"Author is %@", [results objectForKey:@"author"]);
                 NSLog(@"Comments are %@",[results objectForKey:@"tag"]);
                 
                            }
        
        
         }
    
         ];
    }
    
    
    
    // Update the table with data
    [_theTableView reloadData];
    
    // Stop the activity indicator
    [activityIndicator stopAnimating];
    
	
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
-(void)searchFlickrPhotos:(NSString *)text
{
    // Build the string to call the Flickr API
	NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=15&format=json&nojsoncallback=1", FlickrAPIKey, text];
    
    // Create NSURL string from formatted string, by calling the Flickr API
	NSURL *url = [NSURL URLWithString:urlString];
    
  
    
    // Setup and start async download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)showZoomedImage:(NSIndexPath *)indexPath
{
    // Remove from view (and release)
    if ([fullImageViewController.zoomView superview])
        [fullImageViewController.zoomView removeFromSuperview];
    
    fullImageViewController = [[FlLookZoomViewController alloc] initWithURL:[photoURLsLargeImage objectAtIndex:indexPath.row] commentURL:[commentsURLsLargeImage objectAtIndex:indexPath.row]];
    
    [self.view addSubview:fullImageViewController.zoomView];
    
    // Slide this view off screen
    CGRect frame = fullImageViewController.zoomView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.45];
    
    // Slide the image to its new location (onscreen)
    frame.origin.x = 0;
    fullImageViewController.zoomView.frame = frame;
    
    [UIView commitAnimations];
}

/**************************************************************************
 *
 * Class implementation section
 *
 **************************************************************************/
#pragma mark -
#pragma mark Table Mgmt

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [photoTitles count];
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    searchTextField.hidden = YES;
    
    // If we've created this VC before...
    if (fullImageViewController != nil)
    {
        // Slide this view off screen
        CGRect frame = fullImageViewController.zoomView.frame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.45];
        
        // Off screen location
        frame.origin.x = -320;
        fullImageViewController.zoomView.frame = frame;
        
        [UIView commitAnimations];
        
    }
    
    [self performSelector:@selector(showZoomedImage:) withObject:indexPath afterDelay:0.1];
}

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cachedCell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cachedCell"];
    
#if __IPHONE_3_0
    cell.textLabel.text = [photoTitles objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
#else
    cell.text = [photoTitles objectAtIndex:indexPath.row];
    cell.font = [UIFont systemFontOfSize:13.0];
#endif
	
	NSData *imageData = [photoSmallImageData objectAtIndex:indexPath.row];
    
#if __IPHONE_3_0
    cell.imageView.image = [UIImage imageWithData:imageData];
#else
	cell.image = [UIImage imageWithData:imageData];
#endif
	
	return cell;
}

#pragma mark -
#pragma mark Event Mgmt

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    searchTextField.hidden = NO;
}

#pragma mark -
#pragma mark View Mgmt

/*-------------------------------------------------------------
 *
 *------------------------------------------------------------*/
- (void)viewDidLoad 
{
    
    // Create textfield for the search text
   
    [_searchField setBorderStyle:UITextBorderStyleRoundedRect];
    _searchField.placeholder = @"search";
    _searchField.returnKeyType = UIReturnKeyDone;
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchField.delegate = self;
    
    // Create table view
    [_theTableView setDelegate:self];
    [_theTableView setDataSource:self];
    [_theTableView setRowHeight:80];
    [_theTableView setBackgroundColor:[UIColor grayColor]];
    [_theTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
 
    // Initialize our arrays
    photoTitles = [[NSMutableArray alloc] init];
    photoSmallImageData = [[NSMutableArray alloc] init];
    photoURLsLargeImage = [[NSMutableArray alloc] init];
    commentsURLsLargeImage = [[NSMutableArray alloc] init];
    
    
    
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
