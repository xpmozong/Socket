//
//  RightVoiceTableViewCell.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-29.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSocket.h"
#import "RightTableViewCell.h"

@protocol RightVoiceTableViewCellDelegate <NSObject>

@optional
/// 重新发送消息
- (void)resendMsg:(int)rowIndex;
/// 播放语音
- (void)playVoice:(NSIndexPath *)indexPath;

@end

@interface RightVoiceTableViewCell : RightTableViewCell

@property (assign, nonatomic) id<RightVoiceTableViewCellDelegate>delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIButton *voiceBtn;
@property (strong, nonatomic) UIImageView *voiceImage;
@property (strong, nonatomic) UILabel *timeLabel;

/// 设置消息内容
- (void)setMsgContent:(MsgObject *)msgObj;

/// 获得高度
+ (float)getMsgHeight:(MsgObject *)msgObj;

@end
