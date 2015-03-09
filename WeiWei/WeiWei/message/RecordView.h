//
//  RecordView.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-26.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kVoiceRecordPauseString @"手指上滑，取消发送"
#define kVoiceRecordResaueString @"松开手指，取消发送"

@interface RecordView : UIView

@property (strong, nonatomic) UIImageView   *microPhoneImageView;
@property (strong, nonatomic) UIImageView   *recordingHUDImageView;
@property (strong, nonatomic) UILabel       *remindLabel;
@property (strong, nonatomic) UIImageView   *cancelRecordImageView;
@property (strong, nonatomic) UILabel       *timingCountLabel;

@end
