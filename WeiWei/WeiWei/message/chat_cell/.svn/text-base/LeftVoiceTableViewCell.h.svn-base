//
//  LeftVoiceTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftTableViewCell.h"

@protocol LeftVoiceTableViewCellDelegate <NSObject>

@optional
/// 播放语音
- (void)playVoice:(NSIndexPath *)indexPath;

@end

@interface LeftVoiceTableViewCell : LeftTableViewCell

@property (assign, nonatomic) id<LeftVoiceTableViewCellDelegate>delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIButton *voiceBtn;
@property (strong, nonatomic) UIImageView *voiceImage;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *noReadImageView;

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj;

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj;

@end
