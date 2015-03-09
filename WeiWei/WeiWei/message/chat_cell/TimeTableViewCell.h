//
//  TimeTableViewCell.h
//  LeiRen
//
//  Created by tw001 on 14-9-17.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel;

/// 设置内容
- (void)setMsgContent:(NSString *)timeStr;

/// 获得高度
+ (float)getMsgHeight;

@end
