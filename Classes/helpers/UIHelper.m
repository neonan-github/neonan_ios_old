//
//  UIHelper.m
//  Neonan
//
//  Created by capricorn on 12-10-18.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+ (void)fitScrollView:(UIScrollView *)scrollView withMaxHeight:(float)maxHeight {
    CGRect frame = scrollView.frame;
    frame.size.height = MIN(maxHeight, scrollView.contentSize.height);
    scrollView.frame = frame;
}

+ (void)view:(UIView *)view alignBottomTo:(float)bottom {
    CGRect frame = view.frame;
    frame.origin.y = bottom - frame.size.height;
    view.frame = frame;
}

+ (NSUInteger)computeContentLines:(NSString *)content withWidth:(CGFloat)width andFont:(UIFont *)font {
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [content sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    return  (NSUInteger)(size.height / font.lineHeight);
}

+ (CGFloat)computeHeightForLabel:(UILabel *)label withText:(NSString *)text {
    CGFloat originalHeight = label.frame.size.height;
    
    NSInteger originalLines = [UIHelper computeContentLines:label.text withWidth:label.frame.size.width andFont:label.font];
    NSInteger newlines = [UIHelper computeContentLines:text withWidth:label.frame.size.width andFont:label.font];
    
    return originalHeight + (newlines - (originalLines > 0 ? originalLines : 1)) * label.font.lineHeight;
}

+ (void)setBackAction:(SEL)action forController:(UIViewController *)controller withImage:(UIImage *)image {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UIButton *)createBarButton:(CGFloat)margin
{
    UIImage* buttonImage = [[UIImage imageFromFile:@"bg_bar_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0.0];
//    UIImage* buttonHighlightImage = [[UIImage imageFromFile:@"bg_bar_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0.0];
    
    // Create a custom button
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:HEXCOLOR(0x16a1e8) forState:UIControlStateHighlighted];
    [button setTitleColor:HEXCOLOR(0x16a1e8) forState:UIControlStateSelected];
    
    // Set the title to use the same font and shadow as the standard back button
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    //    button.titleLabel.textColor = [UIColor whiteColor];
    //    button.titleLabel.shadowOffset = CGSizeMake(1, 1);
    //    button.titleLabel.shadowColor = [UIColor lightGrayColor];
    
    // Set the break mode to truncate at the end like the standard back button
    button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Inset the title on the left and right
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 3.0, 0, 3.0);
    
    // Make the button as high as the passed in image
    button.frame = CGRectMake(0, 0, buttonImage.size.width + margin * 2, buttonImage.size.height);
    
    // Set the stretchable images as the background for the button
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
//    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateSelected];
    
    return button;
}

+ (UIButton *)createBackButton:(CustomNavigationBar *)navigationBar {
    UIImage* buttonImage = [UIImage imageFromFile:@"bg_back_button.png"];
    UIButton* button = [navigationBar backButtonWith:buttonImage highlight:buttonImage leftCapWidth:16];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:HEXCOLOR(0x16a1e8) forState:UIControlStateHighlighted];
    [button setTitleColor:HEXCOLOR(0x16a1e8) forState:UIControlStateSelected];
    button.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    
    [navigationBar setText:@"返回" onBackButton:button];
    
    return button;
}

+ (void)alertWithMessage:(NSString *)message {
    static UIAlertView *alertView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    });
    
    alertView.message = message;
    [alertView show];
}

@end

@implementation UIImage (UIImageUtil)

+ (UIImage *)imageFromFile:(NSString *)fileName {
    NSArray *splits = [fileName componentsSeparatedByString:@"."];
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:[splits objectAtIndex:0] ofType:[splits objectAtIndex:1]];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    return [UIImage imageWithData:imageData];
}

+ (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
