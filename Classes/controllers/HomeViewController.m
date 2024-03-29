//
//  HomeViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeViewController.h"
#import "ArticleDetailViewController.h"
#import "GalleryDetailViewController.h"
#import "VideoPlayViewController.h"

#import "NNButton.h"
#import "HomeGridViewCell.h"

#import "MainSlideShowModel.h"
#import "CommonListModel.h"

#import <SwipeView.h>
#import <KKGridView.h>
#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>
#import <SVPullToRefresh.h>
#import <SMPageControl.h>

static const NSInteger kPageCount = 6;
static const NSInteger kItemPerPageCount = 6;

static const NSInteger kTagHeaderImageView = 1000;
static const NSInteger kTagHeaderLabel = 1001;
static const NSInteger kTagHeaderBottomLine = 1002;

static NSString *const kHeaderBottomLineName = @"bottomLine";
static NSString *const kLastUpdateKey = @"home_last_update";

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource,
KKGridViewDataSource, KKGridViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet SMPageControl *pageControl;
@property (weak, nonatomic) UILabel *currentPageLabel;

@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign) CGFloat lastScrollOffset;

@property (nonatomic, strong) MainSlideShowModel *slideShowModel;
@property (nonatomic, strong) CommonListModel *listDataModel;
@property (nonatomic, strong) ResponseError *responseError;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = DarkThemeColor;
    
    self.navigationItem.titleView = [UIHelper createLogoView];
    
    UIButton *navLeftButton = [UIHelper createLeftBarButton:@"icon_menu_normal.png"];
    [navLeftButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
    UIButton *navRightButton = [UIHelper createLeftBarButton:@"icon_nav_account.png"];
    [navRightButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
    
    self.lastScrollOffset = 0;
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    [self.swipeView reloadData];
    
    self.pageControl.hidden = NO;
    self.pageControl.indicatorMargin = 5;
    self.pageControl.numberOfPages = kPageCount;
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
    self.pageControl.backgroundColor = RGBA(0, 0, 0, 0.77);
    
    UILabel *currentPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 7, 16)];
    self.currentPageLabel = currentPageLabel;
    [currentPageLabel setCenterX:CGRectGetMinX([self.pageControl rectForPageIndicator:0]) + 4];
    currentPageLabel.textAlignment = NSTextAlignmentCenter;
    currentPageLabel.backgroundColor = [UIColor clearColor];
    currentPageLabel.textColor = [UIColor whiteColor];
    currentPageLabel.font = [UIFont systemFontOfSize:11];
    currentPageLabel.text = @"1";
    [self.pageControl addSubview:currentPageLabel];
    
//    for (NSUInteger i = 0; i < kPageCount; i++) {
//        [self.pageControl setCurrentImage:[HomeViewController indicatorImageForPage:i] forPage:i];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.slideShowModel = nil;
    self.listDataModel = nil;
    self.responseError = nil;
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
    self.pageControl = nil;
    self.currentPageLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.swipeView scrollToItemAtIndex:self.currentPageIndex duration:0];
    
    if (!self.slideShowModel || !self.listDataModel) {
        [self refreshAfterDelay:0.5];
    } else {
        KKGridView *currentPageView = ((KKGridView *)[self.swipeView itemViewAtIndex:self.currentPageIndex]);
        [currentPageView reloadData];
    }
}

#pragma mark - SwipeViewDataSource methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return kPageCount;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    KKGridView *gridView = (KKGridView *)view;
    
    if (!view) {   
        gridView = [[KKGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
        gridView.backgroundColor = [UIColor clearColor];
        gridView.dataSource = self;
        gridView.delegate = self;
        gridView.cellSize = CGSizeMake(145.0, 116.0);
        gridView.cellPadding = CGSizeMake(10, 10);
        gridView.gridHeaderView = [self createHeaderView];
//        gridView.gridFooterView = [self createFooterView];
        
        [gridView addPullToRefreshWithActionHandler:^{
            [self requestData];
        }];
        gridView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    
    KKGridView *currentPageView = ((KKGridView *)[swipeView itemViewAtIndex:self.currentPageIndex]);
    
    gridView.tag = index;
    gridView.gridHeaderView.tag = index;
    gridView.contentOffset = currentPageView.contentOffset;
    [gridView reloadData];
    
    [self fillDataInHeaderView:gridView.gridHeaderView];
    
//    UIView *headerBottomLineView = [gridView.gridHeaderView viewWithTag:kTagHeaderBottomLine];
//    CGRect frame = headerBottomLineView.frame;
//    frame.size.width = 50 * (index + 1);
//    headerBottomLineView.frame = frame;
    
    return gridView;
}

#pragma mark - SwipeViewDelegate methods

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.currentPageIndex = swipeView.currentPage;
    self.pageControl.currentPage = swipeView.currentPage;
    self.pageControl.hidden = NO;
    
    [self.currentPageLabel setCenterX:CGRectGetMinX([self.pageControl rectForPageIndicator:swipeView.currentPage]) + 4];
    self.currentPageLabel.text = [NSString stringWithFormat:@"%d", swipeView.currentPage + 1];
}

#pragma mark - KKGridViewDataSource methods

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return kItemPerPageCount;
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    HomeGridViewCell * cell = (HomeGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[HomeGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 145.0, 116.0) reuseIdentifier:CellIdentifier];
    }
    
    NSInteger index = gridView.tag * kItemPerPageCount + indexPath.index;
    
    CommonItem *model = index >= self.listDataModel.items.count ? nil : self.listDataModel.items[index];
    
    Record *record = [[Record alloc] init];
    record.contentId = model.contentId;
    record.contentType = model.contentType;
    
    cell.viewed = [[HistoryRecorder sharedRecorder] isRecorded:record];
    cell.titleLabel.text = model.title;
    
    cell.tagImageView.image = [model.contentType isEqualToString:@"video"] ? [UIImage imageNamed:@"icon_video_tag"] : nil;
    
    [cell.imageView setImageWithURL:[URLHelper imageURLWithString:model.thumbUrl]
                   placeholderImage:[UIImage imageNamed:@"img_placeholder_common"]];
    
    return cell;
}

#pragma mark - KKGridViewDelegate methods

- (void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    [gridView deselectItemsAtIndexPaths:@[indexPath] animated:YES];
    
    if (self.swipeView.isDragging || !self.listDataModel) {
        return;
    }
    
    NSInteger index = gridView.tag * kItemPerPageCount + indexPath.index;
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:self.listDataModel.items[index]
                                                        andChannel:@"home"];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL hidden;
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.height || (scrollView.contentOffset.y > self.lastScrollOffset && scrollView.contentOffset.y > 0)) {
        hidden = YES;
    } else {
        hidden = NO;
    }
    
    if (hidden != self.pageControl.hidden) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        self.pageControl.hidden = hidden;
        [UIView commitAnimations];
    }
    
    self.lastScrollOffset = scrollView.contentOffset.y;
}

#pragma mark - Private Event Handle

- (void)onHeaderViewClicked:(id)sender {
    if (!self.slideShowModel) {
        return;
    }
    
    [(NeonanAppDelegate *)ApplicationDelegate navigationController:self.navigationController
                                          pushViewControllerByType:self.slideShowModel.list[[sender tag]]
                                                        andChannel:@"home"];
}

#pragma mark - Private Request methods

- (void)requestForSlideShow:(NSString *)channel success:(void (^)(MainSlideShowModel *model))success failure:(void (^)())failure {
    NSDictionary *parameters = @{@"channel": channel, @"count": @(6)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathSlideShow
                                parameters:parameters
                             responseClass:[MainSlideShowModel class]
                                   success:^(id<Jsonable> response) {
                                       if (success) {
                                           success(response);
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       self.responseError = error;
                                       if (failure) {
                                           failure();
                                       }
                                   }];
}

- (void)requestForList:(NSString *)channel success:(void (^)(CommonListModel *model))success failure:(void (^)())failure {
    NSDictionary *parameters = @{@"channel": channel, @"sort_type": @"new", @"count": @(36),
                                 @"offset": @(0)};
    
    [[NNHttpClient sharedClient] getAtPath:kPathWorkList
                                parameters:parameters
                             responseClass:[CommonListModel class]
                                   success:^(id<Jsonable> response) {
                                       if (success) {
                                           success(response);
                                       }
                                   }
                                   failure:^(ResponseError *error) {
                                       self.responseError = error;
                                       if (failure) {
                                           failure();
                                       }
                                   }];
}

- (void)requestData {
    self.swipeView.scrollEnabled = NO;
    
    __block MainSlideShowModel *slideShowModel = nil;
    __block CommonListModel *listDataModel = nil;
    
    void (^done)() = ^ {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            KKGridView *gridView = (KKGridView *)[self.swipeView itemViewAtIndex:self.currentPageIndex];
            [gridView.pullToRefreshView stopAnimating];
            
            [self.swipeView reloadItemAtIndex:self.currentPageIndex];
            self.swipeView.scrollEnabled = YES;
        });
    };
    
    void (^success)() = ^{
        if (listDataModel && slideShowModel) {
            [UserDefaults setInteger:[[NSDate date] timeIntervalSince1970] forKey:kLastUpdateKey];
            [UserDefaults synchronize];
            
            self.listDataModel = listDataModel;
            self.slideShowModel = slideShowModel;
            
            if (self.visible) {
                done();
            }
        }
    };
    
    void (^failure)() = ^{
        if (self.responseError && (!listDataModel || !slideShowModel)) {
            if (self.visible) {
                [UIHelper alertWithMessage:self.responseError.message];
                
                done();
            }
            
            self.responseError = nil;
        }
    };

    [self requestForSlideShow:@"home"
                      success:^(MainSlideShowModel *model){
                          slideShowModel = model;
                          success();
                      }
                      failure:^{
                          failure();
                      }];
    
    [self requestForList:@"home"
                 success:^(CommonListModel *model){
                     listDataModel = model;
                     success();
                 }
                 failure:^{
                     failure();
                 }];
}

#pragma mark - Private methods

- (UIView *)createHeaderView {
    NNButton *headerView = [[NNButton alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 176)];
    [headerView addTarget:self action:@selector(onHeaderViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 166)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor blackColor];
    imageView.tag = kTagHeaderImageView;
    [headerView addSubview:imageView];
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 176 - 28, 300, 28)];
    label.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    label.clipsToBounds = YES;
    label.font = [UIFont systemFontOfSize:16];
    label.highlightedTextColor = HEXCOLOR(0x0096ff);
    label.textColor = [UIColor whiteColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = RGBA(0, 0, 0, 0.5);
    label.tag = kTagHeaderLabel;
    [headerView addSubview:label];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(label.x, label.y + 26, 300, 2)];
    bottomLineView.tag = kTagHeaderBottomLine;
    bottomLineView.backgroundColor = HEXCOLOR(0x0096ff);
    [headerView addSubview:bottomLineView];
    
    return headerView;
}

- (UIView *)createFooterView {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 5)];
}

+ (UIImage *)indicatorImageForPage:(NSUInteger)page {
    CGFloat width = IS_RETINA ? 10 : 5;
    CGFloat height = IS_RETINA ? 32 : 16;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    UIFont *font = [UIFont systemFontOfSize:11];
    NSString *pageText = [NSString stringWithFormat:@"%d", page + 1];
    
    CGFloat textWidth = [UIHelper widthOfString:pageText withFont:font];
    CGRect rect = CGRectMake((width - textWidth) / 2, (height - font.lineHeight) / 2, textWidth, font.lineHeight);
    
    [[UIColor whiteColor] set];
    [pageText drawInRect:CGRectIntegral(rect) withFont:font];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)fillDataInHeaderView:(UIView *)headerView {
    MSSItem *model = !self.slideShowModel ? nil : self.slideShowModel.list[headerView.tag];
    
    Record *record = [[Record alloc] init];
    record.contentId = model.contentId;
    record.contentType = model.contentType;
    
    ((NNButton *)headerView).viewed = [[HistoryRecorder sharedRecorder] isRecorded:record];
    
    __weak UIImageView *weakImageView = (UIImageView *)[headerView viewWithTag:kTagHeaderImageView];
    [weakImageView setImageWithURL:[URLHelper imageURLWithString:model.imgUrl]
                  placeholderImage:[UIImage imageFromFile:@"img_placeholder_home_slide.png"]];
    
    TTTAttributedLabel *label = (TTTAttributedLabel *)[headerView viewWithTag:kTagHeaderLabel];
    label.text = model.title;
}

- (void)refreshAfterDelay:(double)seconds {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        KKGridView *currentPageView = ((KKGridView *)[self.swipeView itemViewAtIndex:self.currentPageIndex]);
        if (currentPageView) {
            [currentPageView triggerPullToRefresh];
        } else {
            [self refreshAfterDelay:0.5];
        }
    });
}

@end
