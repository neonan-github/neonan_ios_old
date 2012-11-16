//
//  BabyDetailController.m
//  Neonan
//
//  Created by capricorn on 12-10-22.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "BabyDetailController.h"
#import "NNNavigationController.h"
#import "SMPageControl.h"
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

#import "SlideShowDetailModel.h"
#import "ShareHelper.h"

static const float kDescriptionShrinkedLines = 4;
static const float kDescriptionStretchedLines = 7;

static const NSUInteger kTagSSImageView = 1000;
static const NSUInteger kTagSSprogressView = 1001;

@interface BabyDetailController () <SlideShowViewDataSource, SlideShowViewDelegate,
FoldableTextBoxDelegate, UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) UIView *titleBox;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *likeButton;
@property (nonatomic, unsafe_unretained) UIButton *shareButton;

@property (nonatomic, unsafe_unretained) SlideShowView *slideShowView;
@property (nonatomic, unsafe_unretained) SMPageControl *pageControl;
@property (nonatomic, unsafe_unretained) FoldableTextBox *textBox;

@property (nonatomic, strong) SlideShowDetailModel *dataModel;
@property (strong, nonatomic) ShareHelper *shareHelper;

- (void)requestForSlideShow;
- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token;

- (void)updateData;
@end

@implementation BabyDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    // Create a custom back button
    UIButton* backButton = [UIHelper createBackButton:customNavigationBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    SlideShowView *slideShowView = self.slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, -NavBarHeight, CompatibleScreenWidth, CompatibleScreenHeight - StatusBarHeight)];
    slideShowView.dataSource = self;
    slideShowView.delegate = self;
    slideShowView.backgroundColor = DarkThemeColor;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [slideShowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:slideShowView];
    
    UIImageView *navBottomLine = [[UIImageView alloc] initWithImage:[UIImage imageFromFile:@"img_nav_bottom_line.png"]];
    CGRect frame = navBottomLine.frame;
    frame.origin.y = -4;
    navBottomLine.frame = frame;
    
    UILabel *titleLabel = self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, 250, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = _contentTitle;
    
    UIButton *likeButton = self.likeButton = [[UIButton alloc] initWithFrame:CGRectMake(245, 5, 35, 25)];
    likeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
//    likeButton.backgroundColor = RGBA(255, 0, 0, 0.3);
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_normal.png"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_highlighted.png"] forState:UIControlStateHighlighted];
    [likeButton setImage:[UIImage imageFromFile:@"icon_love_highlighted.png"] forState:UIControlStateDisabled];
    [likeButton addTarget:self action:@selector(vote) forControlEvents:UIControlEventTouchUpInside];
    likeButton.enabled = !_voted;
    likeButton.hidden = ![_contentType isEqualToString:@"baby"];
    
    UIButton *shareButton = self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(285, 5, 35, 25)];
    shareButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 10);
//    shareButton.backgroundColor = RGBA(0, 255, 0, 0.3);
    [shareButton setImage:[UIImage imageFromFile:@"icon_share.png"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat delta = [self adjustLayout:_contentTitle];
    UIView *titleBox = self.titleBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 35 + delta)];
    titleBox.backgroundColor = DarkThemeColor;
    [titleBox addSubview:navBottomLine];
    [titleBox addSubview:titleLabel];
    [titleBox addSubview:likeButton];
    [titleBox addSubview:shareButton];
    [self.view addSubview:titleBox];
    
    frame = CGRectMake(0, CompatibleContainerHeight - 32, CompatibleScreenWidth, 0);
    FoldableTextBox *textBox = self.textBox = [[FoldableTextBox alloc] initWithFrame:frame];
    frame.size.height = [textBox getSuggestedHeight];
    textBox.frame = frame;
    textBox.delegate = self;
    textBox.insets = UIEdgeInsetsMake(0, 10, 25, 20);
    [self.view addSubview:textBox];
    
    SMPageControl *pageControl = self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, CompatibleContainerHeight - 18, CompatibleScreenWidth, 16)];
    pageControl.indicatorDiameter = 5;
    pageControl.indicatorMargin = 4;
    pageControl.currentPageIndicatorTintColor = HEXCOLOR(0x00a9ff);
    pageControl.userInteractionEnabled = NO;
    [self.view addSubview:pageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp
{
    self.titleLabel = nil;
    self.likeButton = nil;
    self.shareButton = nil;
    self.titleBox = nil;
    
    self.slideShowView.dataSource = nil;
    self.slideShowView.delegate = nil;
    self.slideShowView = nil;
    
    self.pageControl = nil;
    
    self.textBox.delegate = nil;
    self.textBox = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self cleanUp];
}

- (void)dealloc
{
    [self cleanUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_dataModel) {
        [self updateData];
    } else {
        [self requestForSlideShow];
    }
    _textBox.expanded = NO;
}

#pragma mark - UIScrollViewDelegate methods for Image Zoom

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:kTagSSImageView];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:kTagSSImageView];
    CGRect innerFrame = imageView.frame;
    CGRect scrollerBounds = scrollView.bounds;
    
    if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) )
    {
        CGFloat tempx = imageView.center.x - ( scrollerBounds.size.width / 2 );
        CGFloat tempy = imageView.center.y - ( scrollerBounds.size.height / 2 );
        CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);
        
        scrollView.contentOffset = myScrollViewOffset;
    }
    
    UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
    if ( scrollerBounds.size.width > innerFrame.size.width )
    {
        anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
        anEdgeInset.right = -anEdgeInset.left;  // I don't know why this needs to be negative, but that's what works
    }
    if ( scrollerBounds.size.height > innerFrame.size.height )
    {
        anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
        anEdgeInset.bottom = -anEdgeInset.top;  // I don't know why this needs to be negative, but that's what works
    }
    scrollView.contentInset = anEdgeInset;
}

#pragma mark - SlideShowViewDataSource methods

- (NSUInteger)numberOfItemsInSlideShowView:(SlideShowView *)slideShowView {
    NSUInteger count = _dataModel.imgUrls.count;
    [self.pageControl setNumberOfPages:count];
    return count;
    
}

- (UIView *)slideShowView:(SlideShowView *)slideShowView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (!view) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:slideShowView.bounds];
        imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = kTagSSImageView;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:slideShowView.bounds];
        scrollView.delegate = self;
        scrollView.scrollEnabled = NO;
        scrollView.contentSize = imageView.frame.size;
        scrollView.minimumZoomScale = 0.5;
        scrollView.maximumZoomScale = 2.0;
        [scrollView addSubview:imageView];
        view = scrollView;
        
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        progressView.tag = kTagSSprogressView;
        
        CGRect frame = progressView.frame;
        frame.origin.x = (slideShowView.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = (slideShowView.bounds.size.height - frame.size.height) / 2;
        progressView.frame = frame;
        [view addSubview:progressView];
    }
    
    UIImageView *imageView = (UIImageView *)[view viewWithTag:kTagSSImageView];
    UIActivityIndicatorView *progressView = (UIActivityIndicatorView *)[view viewWithTag:kTagSSprogressView];
    NSURL *imgUrl = [NSURL URLWithString:[_dataModel.imgUrls objectAtIndex:index]];
    [imageView setImageWithURL:imgUrl success:^(UIImage *image, BOOL cached) {
//        ((UIScrollView *)view).contentSize = imageView.frame.size;
        [progressView stopAnimating];
    } failure:nil];
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:[imgUrl absoluteString]];
    if (cachedImage) {
        [progressView stopAnimating];
    } else {
        [progressView startAnimating];
    }
    
    return view;
}

#pragma mark - SlideShowViewDelegate methods

- (void)slideShowViewItemIndexDidChange:(SlideShowView *)slideShowView {
    NSUInteger currentIndex = slideShowView.carousel.currentItemIndex;
    NSArray *visibleItems = slideShowView.carousel.visibleItemViews;
    for (UIScrollView *scrollView in visibleItems) {
        [UIView beginAnimations:nil context:nil];
        scrollView.zoomScale = 1.0;
        [UIView commitAnimations];
    }
    [self.pageControl setCurrentPage:currentIndex];
    _textBox.text = [_dataModel.descriptions objectAtIndex:(_dataModel.descriptions.count > 1 ? currentIndex : 0)];
}

#pragma mark - FoldableTextBoxDelegate methods

- (void)onFrameChanged:(CGRect)frame {
    frame.origin.y = self.navigationController.navigationBarHidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
}

#pragma mark - Private methods

- (void)tap:(UITapGestureRecognizer *)recognizer {
    BOOL hidden = !self.navigationController.navigationBarHidden;
    
    [UIView beginAnimations:nil context:nil];
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    
    CGRect frame = self.slideShowView.frame;
    frame.origin.y = hidden ? 0 : -NavBarHeight;
    self.slideShowView.frame = frame;
    
    frame = self.titleBox.frame;
    frame.origin.y = hidden ? -frame.size.height : 0;
    self.titleBox.frame = frame;
    
    frame = self.textBox.frame;
    frame.origin.y = hidden ? (CompatibleScreenHeight - StatusBarHeight) : (CompatibleContainerHeight - frame.size.height);
    self.textBox.frame = frame;
//    方法一
//    frame = self.pageControl.frame;
//    frame.origin.y = hidden ? (390 + 44) : 390;
//    self.pageControl.frame = frame;
    //方法二
    self.pageControl.transform = CGAffineTransformMakeTranslation(0, hidden ? NavBarHeight : 0);
    [UIView commitAnimations];
}

- (void)share {
    if (!_dataModel) {
        return;
    }
    
    if (!self.shareHelper) {
        self.shareHelper = [[ShareHelper alloc] initWithRootViewController:self];
    }
    
    _shareHelper.title = [_contentType isEqualToString:@"baby"] ? [NSString stringWithFormat:@"牛男宝贝 %@", _dataModel.title]: _dataModel.title;
    _shareHelper.shareUrl = _dataModel.shareUrl;
    [_shareHelper showShareView];
}

- (void)vote {
    SessionManager *sessionManager = [SessionManager sharedManager];
    NSString *babyId = _contentId;
    [sessionManager requsetToken:self success:^(NSString *token) {
        [self requestForVote:babyId withToken:token];
    }];
}

#pragma mark - Private Request methods

- (void)requestForSlideShowWithParams:(NSDictionary *)parameters success:(void (^)())success {
    [[NNHttpClient sharedClient] getAtPath:@"work_info" parameters:parameters responseClass:[SlideShowDetailModel class] success:^(id<Jsonable> response) {
        self.dataModel = response;
        [self updateData];
        
        if (success) {
            success();
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

- (void)requestForSlideShow {
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect frame = progressView.frame;
    frame.origin.x = (_slideShowView.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = (_slideShowView.bounds.size.height - frame.size.height) / 2;
    progressView.frame = frame;
    [_slideShowView addSubview:progressView];
    [progressView startAnimating];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:_contentType, @"content_type",
                                _contentId, @"content_id", nil];
    
    SessionManager *sessionManager = [SessionManager sharedManager];
    if ([sessionManager getToken] || [sessionManager canAutoLogin]) {
        [sessionManager requsetToken:self success:^(NSString *token) {
            [parameters setValue:token forKey:@"token"];
            [self requestForSlideShowWithParams:parameters success:^{
                [progressView removeFromSuperview];
            }];
        }];
    } else {
        [self requestForSlideShowWithParams:parameters success:^{
            [progressView removeFromSuperview];
        }];
    }
}

- (void)requestForVote:(NSString *)babyId withToken:(NSString *)token {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:babyId, @"content_id",
                                token, @"token", nil];
    
    [[NNHttpClient sharedClient] postAtPath:@"baby_vote" parameters:parameters responseClass:nil success:^(id<Jsonable> response) {
        if ([self isViewLoaded]) {
            _dataModel.voted = YES;
            [self updateData];
        }
    } failure:^(ResponseError *error) {
        NSLog(@"error:%@", error.message);
        [UIHelper alertWithMessage:error.message];
    }];
}

#pragma mark - Private UI related

- (CGFloat)adjustLayout:(NSString *)title {
    CGFloat titleOriginalHeight = _titleLabel.frame.size.height;
    CGFloat titleAdjustedHeight = [UIHelper computeHeightForLabel:_titleLabel withText:title];
    CGFloat delta = titleAdjustedHeight - titleOriginalHeight;
    
    CGRect frame = _titleLabel.frame;
    frame.size.height = titleAdjustedHeight;
    _titleLabel.frame = frame;

    return delta;
}

- (void)updateData {
    [_slideShowView reloadData];
    [self slideShowViewItemIndexDidChange:_slideShowView];
    
    _likeButton.enabled = !_dataModel.voted;
    
//    _titleLabel.text = _dataModel.title;
}

@end
