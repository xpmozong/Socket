//
//  MessageViewController.h
//  WeiWei
//
//  Created by tw001 on 14/11/18.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSocket.h"
#import "ChatViewController.h"

@interface MessageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView       *tableView;
@property (strong, nonatomic) NSMutableArray    *dataArray;

@property (strong, nonatomic) NSArray           *m_emojiArray;
@property (strong, nonatomic) NSMutableDictionary *m_emojiDictionary;
@property (strong, nonatomic) NSArray           *senderVoiceArray;
@property (strong, nonatomic) NSArray           *receiverVoiceArray;
@property (strong, nonatomic) AVAudioSession    *audioSession;
@property (strong, nonatomic) NSDictionary      *setting;

@property (strong, nonatomic) UIView            *hideBgView;
@property (strong, nonatomic) RecordView        *recordView;
@property (strong, nonatomic) NSFileManager     *fileManager;

- (void)goLogin;

@end
