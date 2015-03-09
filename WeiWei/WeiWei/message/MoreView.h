//
//  MoreView.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-25.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreViewDelegate <NSObject>

@optional
/// 选择照片
- (void)selectedPhoto;
/// 选择拍摄
- (void)selectedShooting;

@end

@interface MoreView : UIView

@property (assign, nonatomic) id<MoreViewDelegate>delegate;

@end
