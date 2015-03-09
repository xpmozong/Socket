//
//  AppDelegate.h
//  WeiWei
//
//  Created by 许 萍 on 14-5-5.
//  Copyright (c) 2014年 许 萍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *username;  // 登录用户名
@property (strong, nonatomic) NSString *passwd;    // 登录密码
@property (strong, nonatomic) MessageViewController *messageVC;
@property (strong, nonatomic) UITabBarController *tabBarC;

- (void)initTabBar; // 登录成功 初始化界面

@end
