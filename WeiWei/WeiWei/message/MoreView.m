//
//  MoreView.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-25.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "MoreView.h"

@implementation MoreView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
        
        NSArray *textArray = @[@"照片", @"拍摄"];
        NSArray *picArray = @[@"default", @"default"];
        NSArray *selectedArray = @[@"default", @"default"];
        
        for (int i = 0; i < [picArray count]; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15 + 60*i, 10, 50, 70)];
            [self addSubview:view];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 50, 50);
            btn.tag = i + 1;
            [btn setBackgroundImage:[UIImage imageNamed:[picArray objectAtIndex:i]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:[selectedArray objectAtIndex:i]] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 20)];
            label.text = [textArray objectAtIndex:i];
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
    }
    
    return self;
}

- (void)clicked:(UIButton *)btn
{
    if (btn.tag == 1) {
        [_delegate selectedPhoto];
    }else if (btn.tag == 2) {
        [_delegate selectedShooting];
    }else{
        
    }
}

@end
