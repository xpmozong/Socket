//
//  TipTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14/11/6.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TipTableViewCellDelegate <NSObject>

@optional
/// 点击查看好友资料资料
- (void)tapShowUserDetail;
@end

@interface TipTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *tipLabel;
@property (assign, nonatomic) id<TipTableViewCellDelegate>delegate;

/// 设置内容
- (void)setMsgContent:(NSString *)str;

/// 获得高度
+ (float)getMsgHeight:(NSString *)str;

@end
