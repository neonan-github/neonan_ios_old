//
//  ArticleDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "ArticleDetailController.h"
#import "SignController.h"
#import "CommentListController.h"
#import "NNNavigationController.h"
#import "ShareHelper.h"

#import "CommentBox.h"
#import <UIWebView+RemoveShadow.h>

static const NSString *kHtmlTemplate = @"<html> \n"
"<head> \n"
"<style type=\"text/css\"> \n"
"body {font-family: \"%@\"; font-size: %@em; color: white; padding: 1em;}\n"
"a:link {color: white; text-decoration: none;}\n"
"a:visited {color: white; text-decoration: none;}\n"
"a:hover {color: white; text-decoration: none;}\n"
"a:active {color: white; text-decoration: none;}\n"
"</style> \n"
"</head> \n"
"<body>%@</body> \n"
"</html>";

@interface ArticleDetailController () <UIWebViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet CommentBox *commentBox;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shareButton;
//@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) ShareHelper *shareHelper;

- (void)loadHtml;

@end

@implementation ArticleDetailController

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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = DarkThemeColor;
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [_textView removeShadow];
    _textView.scalesPageToFit = YES;
    _textView.delegate = self;
    _textView.dataDetectorTypes = UIDataDetectorTypeNone;
    
//    [_commentButton removeFromSuperview];
//    [_commentButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
//    _commentBox.rightView = _commentButton;
    [_commentBox.countButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
    [_commentBox.doneButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
    
    [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadHtml];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setTextView:nil];
    [self setCommentBox:nil];
    [self setShareButton:nil];
    self.shareHelper = nil;
    [super viewDidUnload];
}

#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoadWithRequest type:%d", navigationType);
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
   [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"a\").removeAttribute(\"href\");"]; 
//   [webView stringByEvaluatingJavaScriptFromString:@"document.anchors[\"ancDevx\"].removeAttribute(\"href\");"]; 
}

#pragma mark - Keyboard events handle

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
//    _commentBox.rightView = nil;
    
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
//    _commentBox.rightView = _commentButton;
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = self.commentBox.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.size.height = containerFrame.origin.y - tableFrame.origin.y;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	self.commentBox.frame = containerFrame;
//    self.tableView.frame = tableFrame;
	
	// commit animations
	[UIView commitAnimations];
}

#pragma mark - Private methods

- (void)loadHtml {
    // Load HTML data
	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"article_sample.html" ofType:nil];
	NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
//	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *formattedHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@em; color: white; padding: 1em;}\n"
                                   "a:link {color: white; text-decoration: none;}\n"
                                   "a:visited {color: white; text-decoration: none;}\n"
                                   "a:hover {color: white; text-decoration: none;}\n"
                                   "a:active {color: white; text-decoration: none;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"helvetica", [NSNumber numberWithInt:2], html];
    [_textView loadHTMLString:formattedHTML baseURL:nil];
}

- (void)share {
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    [self.shareHelper showShareView];
}

- (void)publish:(UIButton *)button {
    SignController *controller = [[SignController alloc] init];
    [self.navigationController presentModalViewController:controller animated:YES];
}

- (void)showComments {
    CommentListController *controller = [[CommentListController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
