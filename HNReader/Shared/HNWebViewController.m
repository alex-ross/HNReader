//
//  HNWebViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNWebViewController.h"

@implementation HNWebViewController

@synthesize webView, entry;
@synthesize toolbar, popoverController, items;
@synthesize readableButton;
@synthesize displayedURL = _displayedURL;

- (id)init {
    if ((self = [super init])) {
        self.items = [NSMutableArray arrayWithCapacity:2];
        self.webView = nil;
        self.toolbar = nil;
        self.entry = nil;
        _displayedURL = nil;
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    [webView setScalesPageToFit:YES];
    [webView setDelegate:self];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // load a toolbar for our splitview (pad only)
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 44.0f)];
        [toolbar setTintColor:[HNReaderTheme brightOrangeColor]];
        [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [webView setFrame:CGRectMake(frame.origin.x, 44.0f, frame.size.width, frame.size.height - 44.0f)];
        [contentView addSubview:toolbar];
    }
    
    [contentView addSubview:webView];
    
    self.view = contentView;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:entry.linkURL]];
//        [webView loadRequest:request];
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        // FIXME: use readable button here?
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"R" style:UIBarButtonItemStyleBordered target:self action:@selector(makeReadable)];
        [[self navigationItem] setRightBarButtonItem:button];
        
        //FIXME: don't need to track the entry anymore, do we?
        self.displayedURL = [NSURL URLWithString:[entry linkURL]];
        [self shouldLoadURL:_displayedURL];
    }
    else {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(shouldLoadFromNotification:) name:@"HNLoadSiteNotification" object:nil];

        [defaultCenter addObserver:self selector:@selector(shouldStopLoading) name:@"HNStopLoadingNotification" object:nil];
    
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil 
                                                                                action:nil];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"R" style:UIBarButtonItemStyleBordered target:self action:@selector(makeReadable)];
        [self.items addObject:spacer];
        [self.items addObject:button];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
	barButtonItem.title = NSLocalizedString(@"News", @"News popover title");
	barButtonItem.style = UIBarButtonItemStyleBordered;
	
	[self.items insertObject:barButtonItem atIndex:0];
    // don't use animation so there isn't a ui artifact when launching in landscape
    // really don't need it here since this is called during rotations
	[toolbar setItems:self.items animated:NO];
	self.popoverController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	[self.items removeObjectAtIndex:0];
    // don't use animation so there isn't a ui artifact when launching in landscape
    // really don't need it here since this is called during rotations
	[toolbar setItems:self.items animated:NO];
    popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {

}

#pragma mark - HNEntriesViewControllerDelegate

- (void)shouldLoadURL:(NSURL *)aURL {
    
    self.displayedURL = aURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_displayedURL];
    [webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)shouldStopLoading {
    [webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // empty out the webview
    // http://lists.apple.com/archives/cocoa-dev/2010/Nov/msg00680.html
    // [webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    // https://discussions.apple.com/thread/1727260
    if (error.code == NSURLErrorCancelled) return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert view title") 
                                                    message:[error localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"ok button title") 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)shouldLoadFromNotification:(NSNotification *)aNotification {
    NSDictionary *extraInfo = [aNotification userInfo];
    NSString *aURLString = extraInfo[@"kHNURL"];
    NSURL *aURL = [NSURL URLWithString:aURLString];
    
    [self shouldLoadURL:aURL];
}

- (void)makeReadable {
    NSURL *aURL = _displayedURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:aURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawHtmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        const char *html_content = [rawHtmlString UTF8String];
        char *readable_content = readable(html_content, "", NULL, READABLE_OPTIONS_DEFAULT);
        
        if (readable_content != NULL) {
            
            // FIXME: cache teh file paths...
            NSString *filePath = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                
                // if this is a phone, we have a smaller screen
                // so add the meta tag to specify the viewport
                // 28 px is also too big for phone
                filePath = [[NSBundle mainBundle] pathForResource:@"iphone-formatting" ofType:@"html"];
            }
            else {
                filePath = [[NSBundle mainBundle] pathForResource:@"ipad-formatting" ofType:@"html"];
            }
            
            NSString *formattingTags = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString *readableHTMLString = @(readable_content);
            NSString *html = [NSString stringWithFormat:@"%@%@", formattingTags, readableHTMLString];
            
            [webView loadHTMLString:html baseURL:aURL];
        }
        
        // NSLog(@"succuess: %@", [NSString stringWithCString:readable_content encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
        NSString *message = NSLocalizedString(@"Could not find readable content on the page", @"Could not find readable content on the page.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

@end
