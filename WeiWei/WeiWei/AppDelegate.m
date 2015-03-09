//
//  AppDelegate.m
//  WeiWei
//
//  Created by 许 萍 on 14-5-5.
//  Copyright (c) 2014年 许 萍. All rights reserved.
//

#import "AppDelegate.h"
#import "ContactsViewController.h"
#import "MeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginOut:) name:kUserLoginOut object:nil];
    
    WSocket *ws = [WSocket shareWSocket];
    [ws createTables];
    
    [self initTabBar];
    
    _username = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    _passwd = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
    NSLog(@"username=%@== passwd=%@==", _username, _passwd);
    if (_username.length > 0 && _passwd.length > 0) {
        int login_stat = [ws logining:_username passwd:_passwd isRetry:NO];
        if (login_stat == 0) {
            NSLog(@"登录中...");
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogin:) name:kUserLogin object:nil];
        }
        
    }else{
        [_messageVC goLogin];
    }
    
    return YES;
}

/// 登录消息返回
- (void)userLogin:(NSNotification *)notifi
{
    NSLog(@"登录消息返回");
    NSString *txt = @"";
    if ([notifi.object intValue] > 0) {
        txt = @"登录成功";
        
    }else{
        txt = @"密码错误！";
    }
    
    NSLog(@"%@", txt);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserLogin object:nil];
    });
}

/// 退出
- (void)userLoginOut:(NSNotification *)notifi
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _tabBarC.tabBarController.selectedIndex = 0;
        [_messageVC goLogin];
    });
}

- (void)initTabBar
{
    _messageVC = [[MessageViewController alloc] init];
    UINavigationController *messageNavC = [[UINavigationController alloc] initWithRootViewController:_messageVC];
    ContactsViewController *contactsVC = [[ContactsViewController alloc] init];
    UINavigationController *contactsNavC = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    MeViewController *meVC = [[MeViewController alloc] init];
    UINavigationController *meNavC = [[UINavigationController alloc] initWithRootViewController:meVC];
    
    _tabBarC = [[UITabBarController alloc] init];
    _tabBarC.viewControllers = @[messageNavC, contactsNavC, meNavC];
    _tabBarC.selectedIndex = 0;
    self.window.rootViewController = _tabBarC;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
