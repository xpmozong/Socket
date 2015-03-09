//
//  LoginViewController.h
//  Draw
//
//  Created by tw001 on 14/11/26.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) NSString *username;  // 登录用户名
@property (strong, nonatomic) NSString *passwd;    // 登录密码
@property (strong, nonatomic) UITextField *userTextField;
@property (strong, nonatomic) UITextField *passwdTextField;

@end
