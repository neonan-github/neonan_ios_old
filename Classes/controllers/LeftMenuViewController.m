//
//  LeftMenuViewController.m
//  Neonan
//
//  Created by capricorn on 13-5-22.
//  Copyright (c) 2013年 neonan. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SearchResultViewController.h"

#import "SideMenuCell.h"

#import <UIAlertView+Blocks.h>

@interface LeftMenuViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *searchBgView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) NSArray *channelTexts;
@property (nonatomic, readonly) NSArray *channelTypes;

@end

@implementation LeftMenuViewController
@synthesize channelTexts = _channelTexts, channelTypes = _channelTypes;

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
    
    self.view.backgroundColor = HEXCOLOR(0x121212);
    
    self.searchBgView.image = [[UIImage imageNamed:@"bg_search_bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    self.clearButton.hidden = _searchField.text.length < 1;
    [self.clearButton addTarget:self action:@selector(clearSearchText) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *firstSeparatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, CompatibleScreenWidth, 2)];
    firstSeparatorView.image = [UIImage imageFromFile:@"img_menu_separator.png"];
    [self.tableView addSubview:firstSeparatorView];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:((NeonanAppDelegate *)ApplicationDelegate).containerController.selectedIndex
                                                            inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cleanUp {
    [super cleanUp];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.searchBgView = nil;
    self.searchButton = nil;
    
    self.searchField.delegate = nil;
    self.searchField = nil;
    
    self.clearButton = nil;
    
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView = nil;
    
    _channelTexts = nil;
    _channelTypes = nil;
}

#pragma mark － UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.channelTexts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
    [self performSelector:@selector(changeController:) withObject:@(indexPath.row) afterDelay:0.2];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.clearButton.hidden = textField.text.length < 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.clearButton.hidden = newText.length < 1;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doSearch:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    return YES;
}

#pragma mark - Private Event Handle

- (void)keyboardWillShow:(NSNotification *)note {
    
}

- (void)keyboardWillHide:(NSNotification *)note {
}

- (void)keyboardDidHide:(NSNotification *)note {
    [self clearSearchText];
    [self.searchField resignFirstResponder];
}

- (void)clearSearchText {
    self.searchField.text = @"";
    self.clearButton.hidden = YES;
}

#pragma mark - Private methods

- (NSArray *)channelTexts {
    if (!_channelTexts) {
        _channelTexts = @[@"首页", @"女人", @"知道", @"爱玩", @"视频"];
    }
    
    return  _channelTexts;
}

- (NSArray *)channelTypes {
    if (!_channelTypes) {
        _channelTypes = @[@"home", @"women", @"know", @"play", @"video"];
    }
    
    return _channelTypes;
}

- (void)changeController:(NSNumber *)index {
    NNContainerViewController *containerController = ((NeonanAppDelegate *)ApplicationDelegate).containerController;
    if (containerController.selectedIndex == index.integerValue) {
        return;
    }
    containerController.selectedIndex = index.integerValue;
}

- (void)doSearch:(NSString *)text {
    if (!text || text.length < 1) {
        [UIHelper alertWithMessage:@"请输入要搜索的关键词"];
        return;
    }
    
    self.sidePanelController.centerPanel = self.sidePanelController.centerPanel;
    
    NNNavigationController *topNavController = (NNNavigationController *)((NeonanAppDelegate *)ApplicationDelegate).containerController.currentViewController;
    SearchResultViewController *viewController = [[SearchResultViewController alloc] init];
    viewController.keyword = text;
    [topNavController pushViewController:viewController animated:NO];
}

@end