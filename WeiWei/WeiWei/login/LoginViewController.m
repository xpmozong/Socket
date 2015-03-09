//
//  LoginViewController.m
//  Draw
//
//  Created by tw001 on 14/11/26.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "LoginViewController.h"
#import "WSocket.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)dealloc
{
    NSLog(@"登录界面释放");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin:) name:kUserLogin object:nil];
    
    _userTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 30)];
    _userTextField.borderStyle = UITextBorderStyleRoundedRect;
    _userTextField.placeholder = @"请输入用户名";
    _userTextField.text = @"xuping";
    [self.view addSubview:_userTextField];
    
    _passwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(_userTextField.frame.origin.x, _userTextField.frame.origin.y + _userTextField.frame.size.height + 10, _userTextField.frame.size.width, _userTextField.frame.size.height)];
    _passwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    _passwdTextField.placeholder = @"请输入密码";
    _passwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwdTextField.secureTextEntry = YES;
    _passwdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwdTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwdTextField.enablesReturnKeyAutomatically = YES;
    _passwdTextField.text = @"123456";
    [self.view addSubview:_passwdTextField];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(10, _passwdTextField.frame.origin.y + _passwdTextField.frame.size.height + 10,  _userTextField.frame.size.width, _userTextField.frame.size.height);
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loging) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

/// 登录消息返回
- (void)userLogin:(NSNotification *)notifi
{
    NSLog(@"登录消息返回====%d", [notifi.object intValue]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([notifi.object intValue] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:_username forKey:kUsername];
            [[NSUserDefaults standardUserDefaults] setObject:_passwd forKey:kPassword];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"用户名或密码错误！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"了解了", nil];
            [alertView show];
        }
    });
}

/// 登录
- (void)loging
{
    [_userTextField resignFirstResponder];
    [_passwdTextField resignFirstResponder];

    _username = _userTextField.text;
    _passwd = _passwdTextField.text;
    
    if (_username.length > 0 && _passwd.length > 0) {
        int stat = [[WSocket shareWSocket] logining:_username passwd:_passwd isRetry:NO];
        if (stat == kConnectFailue) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法连接" message:@"请检查你的网络连接，然后再重试。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"了解了", nil];
            [alertView show];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
