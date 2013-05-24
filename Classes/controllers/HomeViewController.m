//
//  HomeViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-23.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "HomeViewController.h"

#import "HomeGridViewCell.h"

#import <SwipeView.h>
#import <AQGridView.h>
#import <TTTAttributedLabel.h>
#import <UIImageView+WebCache.h>

static const NSInteger kPageCount = 6;
static const NSInteger kItemPerPageCount = 6;

static const NSInteger kTagHeaderImageView = 1000;
static const NSInteger kTagHeaderLabel = 1001;

@interface HomeViewController () <SwipeViewDelegate, SwipeViewDataSource,
AQGridViewDelegate, AQGridViewDataSource>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@property (nonatomic, assign) NSInteger currentPageIndex;

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
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    
    self.currentPageIndex = self.swipeView.currentPage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    self.swipeView.dataSource = nil;
    self.swipeView.delegate = nil;
    self.swipeView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.swipeView reloadData];
}

#pragma mark - SwipeViewDataSource methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return kPageCount;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    AQGridView *gridView = (AQGridView *)view;
    
    if (!view) {   
        gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, CompatibleContainerHeight)];
        gridView.leftContentInset = 5;
        gridView.rightContentInset = 5;
//        gridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
        gridView.backgroundColor = [UIColor clearColor];
        gridView.dataSource = self;
        gridView.delegate = self;
        
        gridView.gridHeaderView = [self createHeaderView];
        gridView.gridFooterView = [self createFooterView];
    }
    
    AQGridView *currentPageView = ((AQGridView *)[swipeView itemViewAtIndex:self.currentPageIndex]);
    
    gridView.tag = index;
    gridView.contentOffset = currentPageView.contentOffset;
    [gridView reloadData];
    
    return gridView;
}

#pragma mark - SwipeViewDelegate methods

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    self.currentPageIndex = swipeView.currentPage;
}

#pragma mark - AQGridViewDataSource methods

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)gridView {
    return kItemPerPageCount;
}

- (AQGridViewCell *)gridView:(AQGridView *)gridView cellForItemAtIndex:(NSUInteger)index {
    static NSString *CellIdentifier = @"Cell";
    
    HomeGridViewCell * cell = (HomeGridViewCell *)[gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[HomeGridViewCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 145.0, 116.0) reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor blueColor];
    }
    
    return cell;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)gridView {
    return CGSizeMake(155.0, 126.0);
}

#pragma mark - Private methods

- (UIView *)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 182)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 166)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [UIColor greenColor];
    imageView.tag = kTagHeaderImageView;
    [imageView setImageWithURL:[NSURL URLWithString:@"http://cdn.neonan.com/uploads/4684cf45-f8e6-4fab-bc6f-1728aac7fbb8.jpg_680"]];
    [headerView addSubview:imageView];
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, 177 - 28, 300, 28)];
    label.textInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    label.clipsToBounds = YES;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = RGBA(0, 0, 0, 0.5);
    label.tag = kTagHeaderLabel;
    
    CALayer *bottomLineLayer = [CALayer layer];
    bottomLineLayer.frame = CGRectMake(0, 27, 300, 1);
    bottomLineLayer.backgroundColor = HEXCOLOR(0x0096ff).CGColor;
    [label.layer addSublayer:bottomLineLayer];
    
    label.text = @"请掌握穷变富的原则top 10";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView *)createFooterView {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, CompatibleScreenWidth, 5)];
}

@end
