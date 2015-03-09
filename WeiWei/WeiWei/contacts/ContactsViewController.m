//
//  ContactsViewController.m
//  WeiWei
//
//  Created by tw001 on 14/11/18.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "ContactsViewController.h"
#define kTitle @"通讯录"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTitle;
        self.tabBarItem.title = kTitle;
        self.tabBarItem.image = [UIImage imageNamed:@"my"];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
