//
//  RightImageTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightTableViewCell.h"

@protocol RightImageTableViewCellDelegate <NSObject>

@optional
/// 重新发送消息
- (void)resendMsg:(int)rowIndex;
/// 查看图片
- (void)lookImage:(int)rowIndex;
/// 销毁图片
- (void)destroyImage:(int)rowIndex;
@end

@interface RightImageTableViewCell : RightTableViewCell

@property (assign, nonatomic) int rowIndex;
@property (strong, nonatomic) UIView *picView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIImageView *picImageView;
@property (assign, nonatomic) id<RightImageTableViewCellDelegate>delegate;

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj;

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj;

@end
