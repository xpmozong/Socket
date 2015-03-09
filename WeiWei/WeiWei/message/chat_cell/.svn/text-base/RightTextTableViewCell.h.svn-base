//
//  RightTextTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightTableViewCell.h"

@protocol RightTextTableViewCellDelegate <NSObject>

@optional
/// 重新发送消息
- (void)resendMsg:(int)rowIndex;
/// 点击链接
- (void)clickFollowLink:(NSTextCheckingResult *)linkInfo;
/// 长按开始
- (void)longPressBegin:(NSIndexPath *)indPath;
/// 长按弹出显示菜单
- (void)longPressShowMenu:(NSIndexPath *)indPath;

@end

@interface RightTextTableViewCell : RightTableViewCell

@property (assign, nonatomic) int rowIndex;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) id<RightTextTableViewCellDelegate>delegate;

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj;

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj;

@end
