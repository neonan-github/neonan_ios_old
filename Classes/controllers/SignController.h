//
//  SignController.h
//  Neonan
//
//  Created by capricorn on 12-10-23.
//  Copyright (c) 2012年 neonan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+UITextFieldCatagory.h"

@interface SignController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *userTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *leftButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *rightButton;

@end