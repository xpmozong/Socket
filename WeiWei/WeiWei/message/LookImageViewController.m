//
//  LookImageViewController.m
//  WeiWei
//
//  Created by 许 萍 on 15/2/28.
//  Copyright (c) 2015年 许 萍. All rights reserved.
//

#import "LookImageViewController.h"

@interface LookImageViewController ()

@end

@implementation LookImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _aImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _aImageView.image = [UIImage imageWithContentsOfFile:_imgPath];
    [self.view addSubview:_aImageView];
    
    float w = _aImageView.image.size.width;
    float h = _aImageView.image.size.height;
    float sw = _aImageView.image.size.width / self.view.frame.size.width;
    float sh = _aImageView.image.size.height / self.view.frame.size.height;
    float scaleSize = sw > sh ? sw : sh;
    if (scaleSize > 1) {
        w = _aImageView.image.size.width / scaleSize;
        h = _aImageView.image.size.height / scaleSize;
    }
    NSLog(@"%f %f", w, h);
    _aImageView.frame = CGRectMake((self.view.frame.size.width - w) / 2, (self.view.frame.size.height - h) / 2, w, h);
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage)];
    [self.view addGestureRecognizer:tapGes];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideImage
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
