//
//  RecordView.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-26.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import "RecordView.h"

@implementation RecordView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 114.0, 120.0, 21.0)];
        _remindLabel.textColor = [UIColor whiteColor];
        _remindLabel.font = [UIFont systemFontOfSize:13];
        _remindLabel.layer.masksToBounds = YES;
        _remindLabel.layer.cornerRadius = 4;
        _remindLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _remindLabel.backgroundColor = [UIColor clearColor];
        _remindLabel.text = kVoiceRecordPauseString;
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_remindLabel];
        
        _microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(27.0 + 20, 8.0, 50.0, 99.0)];
        _microPhoneImageView.image = [UIImage imageNamed:@"RecordingBkg"];
        _microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_microPhoneImageView];
        
        _recordingHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(82.0 + 20, 34.0, 18.0, 61.0)];
        _recordingHUDImageView.image = [UIImage imageNamed:@"RecordingSignal001"];
        _recordingHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _recordingHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_recordingHUDImageView];
        
        _cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 7.0, 100.0, 100.0)];
        _cancelRecordImageView.image = [UIImage imageNamed:@"RecordCancel"];
        _cancelRecordImageView.hidden = YES;
        _cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_cancelRecordImageView];
        
        _timingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 125)];
        _timingCountLabel.textColor = [UIColor whiteColor];
        _timingCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:100];
        _timingCountLabel.textAlignment = NSTextAlignmentCenter;
        _timingCountLabel.text = @"5";
        _timingCountLabel.hidden = YES;
        [self addSubview:_timingCountLabel];
        
    }
    
    return self;
}

@end
