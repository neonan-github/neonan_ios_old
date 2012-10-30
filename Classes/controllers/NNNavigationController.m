//
//  NNNavigationController.m
//  Neonan
//
//  Created by capricorn on 12-10-26.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "NNNavigationController.h"
#import "CustomNavigationBar.h"

@interface NNNavigationController ()
@property (unsafe_unretained, nonatomic) UIButton *backButton;
@end

@implementation NNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CustomNavigationBar *navigationBar = [[CustomNavigationBar alloc] init];
        navigationBar.topLineColor = RGB(32, 32, 32);
        navigationBar.bottomLineColor = RGB(32, 32, 32);
        navigationBar.gradientStartColor = RGB(32, 32, 32);
        navigationBar.gradientEndColor = RGB(32, 32, 32);
//        navigationBar.tintColor = [UIColor blackColor];
        navigationBar.navigationController = self;

        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((CompatibleScreenWidth - 85) / 2, (NavBarHeight - 19) / 2, 85, 19)];
        logoView.image = [UIImage imageFromFile:@"img_logo.png"];
        [navigationBar addSubview:logoView];
        
        UIImage *image = [UIImage imageFromFile:@"icon_left_arrow_white.png"];
        UIButton *backButton = self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (44 - image.size.height) / 2, image.size.width, image.size.height)];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [navigationBar addSubview:backButton];
        
        [self setValue:navigationBar forKeyPath:@"navigationBar"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.backButton.hidden = !self.showsBackButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.backButton = nil;
    
    [super viewDidUnload];
}

- (void)setShowsBackButton:(BOOL)showsBackButton {
    if (_showsBackButton != showsBackButton) {
        _showsBackButton = showsBackButton;
        _backButton.hidden = !showsBackButton;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.navigationItem.hidesBackButton = YES;
    [super pushViewController:viewController animated:animated];
}

#pragma mark - Private methods

- (void)back {
    [self popViewControllerAnimated:YES];
}

@end