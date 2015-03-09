//
//  ChatViewController.m
//  BDMapDemo
//
//  Created by tw001 on 14-9-23.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LookImageViewController.h"

#define MULITTHREEBYTEUTF16TOUNICODE(x,y) (((((x ^ 0xD800) << 2) | ((y ^ 0xDC00) >> 8)) << 8) | ((y ^ 0xDC00) & 0xFF)) + 0x10000

@interface ChatViewController ()
{
    WSocket *ws;
}

@end

@implementation ChatViewController

- (void)backButtonClick
{
    [self voicePlayFinish];
    [self hideBotton];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonClick2
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
//    [ws.messagesList removeAllObjects];
    [_timer invalidate];
    _timer = nil;
    [_uploadTimer invalidate];
    _uploadTimer = nil;
    [_downloadTimer invalidate];
    _downloadTimer = nil;
    _localAvatar = nil;
    _foreignAvatar = nil;
    NSLog(@"聊天界面释放");
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)hideKeyboard
{
    [_msgTextView resignFirstResponder];
}

/// 刷新列表
- (void)msgListMessage:(NSNotification *)notifi
{
    NSLog(@"shuaxin %d %d", [[notifi object] intValue], (int)ws.messagesList.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        int noti = [[notifi object] intValue];
        [self fixLabelArray:noti];
        switch (noti) {
            case MsgChatRefrashTypePageNoFinish:
            {
                break;
            }
            case MsgChatRefrashTypePageIsFinish:
            {
                _prevCount = (int)ws.messagesList.count;
                _isPageFinish = YES;
                break;
            }
            case MsgChatRefrashTypeSendSuccess:
            {
                [self refrashTableViewNormal];
                break;
            }
            case MsgChatRefrashTypeReciveMsg:
            {
                _srmsgCount++;
                [_tableView reloadData];
                _prevCount = (int)ws.messagesList.count;
                [UIView animateWithDuration:0.25 animations:^{
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [UIView setAnimationCurve:0];
                    [self refrashTableView];
                }];
                break;
            }
            case MsgChatRefrashTypeNormal:
            {
                _prevCount = (int)ws.messagesList.count;
                [_tableView reloadData];
                _msgTextView.contentSize = CGSizeMake(_msgTextView.frame.size.width, _msgTextView.frame.size.height);
                break;
            }
            case MsgChatRefrashTypeDeleteMsg:
            {
                [self refrashTableViewNormal];
                break;
            }
            case MsgChatRefrashTypeSendFailue:
            {
                _srmsgCount--;
                [self refrashTableViewNormal];
                break;
            }
            case MsgChatRefrashTypeSendVoice:
            {
                [self refrashTableViewNormal];
                break;
            }
            default:
                break;
        }
    });
}

- (void)msgChatHideKeyBoard:(NSNotification *)notifi
{
    [self hideBotton];
}

- (void)refrashTableViewNormal
{
    [_tableView reloadData];
    _prevCount = (int)ws.messagesList.count;
    [UIView animateWithDuration:0.25 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:0];
        if (_prevCount >= 1) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_prevCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }];
}

- (void)refrashTableView
{
    MsgObject *msgObj = [ws.messagesList lastObject];
    [self updateMsgAlreadyRead:msgObj];
    if (_prevCount >= 1) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_prevCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - 刷新
/// 获得新数据
- (void)waveRefrashNewData
{
    if (_pageCount > 1) {
        dispatch_sync(_getMsgQueue, ^{
            _page++;
            [ws getMsgList:_foreign_user page:_page srmsgCount:_srmsgCount foreignDir:_foreignDir];
        });
    }
}

- (void)EndTriggerRefresh
{
    int nowCount = (int)ws.messagesList.count;
    _offsetCount = nowCount - _prevCount;
    _prevCount = nowCount;
    [_tableView reloadData];
    if (_offsetCount >= 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_offsetCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - 处理近距离监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    // 如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES){
        // 黑屏
        NSLog(@"Device is close to user");
        // 切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }else {
        // 没黑屏幕
        NSLog(@"Device is not close to user");
        // 切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

/// 对方把我删除后，如果我当前界面是在聊天，退出聊天界面
- (void)fromDeleteToPopChat:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *foreign_ph = [noti object];
        if ([foreign_ph isEqualToString:_foreign_user]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        // 通知中心键盘即将显示时刻触发事件
        [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        // 通知中心键盘即将消失时刻触发事件
        [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        // 通知刷新列表
        [center addObserver:self selector:@selector(msgListMessage:) name:kMsgListMessage object:nil];
        // 通知隐藏键盘
        [center addObserver:self selector:@selector(msgChatHideKeyBoard:) name:kMsgChatHideKeyBoard object:nil];
        
        [center addObserver:self selector:@selector(toTheTelphone:) name:UIApplicationWillResignActiveNotification object:nil];
        
        [center addObserver:self selector:@selector(fromDeleteToPopChat:) name:kFromDeleteToPopChat object:nil];
        _sendQueue = dispatch_queue_create("com.leiren.sendmsg", DISPATCH_QUEUE_CONCURRENT);
        _getMsgQueue = dispatch_queue_create("com.leiren.msgchatlist", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

#pragma mark - 监听是否来电话
- (void)toTheTelphone:(NSNotificationCenter *)notification
{
    // 来电话将语音发送掉
    NSLog(@"来电话啦》》》》》》》》");
    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordBtn setTitle:kPressString forState:UIControlStateNormal];
    [_timer setFireDate:[NSDate distantFuture]];
    float cTime = _recorder.currentTime;
    if (_voiceIndexPath.row > 0 && cTime > 1) {
        MsgObject *msgObj = [ws.messagesList objectAtIndex:_voiceIndexPath.row];
        RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
        cell.activityView.hidden = NO;
        cell.timeLabel.hidden = NO;
        int voice_time = ceilf(_recorder.currentTime);
        msgObj.voice_time = voice_time;
        float timeWidth = 16.0f;
        if (voice_time >= 10) {
            timeWidth = 24.0f;
        }
        cell.timeLabel.text = [NSString stringWithFormat:@"%d\"", voice_time];
        float voiceWidth = 40.0f;
        if (voice_time > 1) {
            voiceWidth = voiceWidth + voice_time * 2.66f;
        }
        float orginX = self.view.frame.size.width - 55 - voiceWidth - timeWidth;
        cell.bgImageView.alpha = 1;
        cell.activityView.frame = CGRectMake(orginX - 30, cell.activityView.frame.origin.y, 30, 30);
        cell.voiceBtn.backgroundColor = [UIColor clearColor];
        cell.timeLabel.frame = CGRectMake(orginX, 20, timeWidth, 20);
        cell.msgView.frame = CGRectMake(orginX + timeWidth, cell.msgView.frame.origin.y, voiceWidth + 15, 40);
        cell.bgImageView.frame = CGRectMake(0, 0, voiceWidth + 15, 40);
        cell.voiceBtn.frame = CGRectMake(4, 1.5, cell.msgView.frame.size.width - 18, cell.msgView.frame.size.height - 3);
        cell.voiceImage.frame = CGRectMake(_voiceBtn.frame.size.width - 25, 9, 20, 20);
        [cell.activityView startAnimating];
        
        NSLog(@"cTime=%f", cTime);
        if (cTime > 0.6) { //如果录制时间 < 0.6 不发送
            NSLog(@"发出去");
            MsgObject *msgTimeMsgObj = _voiceTimeMsgObj;
            if (_voiceIndexPath.row >= 1) {
                MsgObject *vmsgTimeMsgObj = [ws.messagesList objectAtIndex:(_voiceIndexPath.row - 1)];
                if (vmsgTimeMsgObj.m_type == MsgTime && vmsgTimeMsgObj.direction == YES) {
                    msgTimeMsgObj = vmsgTimeMsgObj;
                }
            }
            //如果录制时间 < 0.6 不发送
            _srmsgCount++;
            dispatch_sync(_sendQueue, ^{
//                [ws sendVoice:_foreign_user mType:MsgVoice wavFilePath:_wavFilePath wavName:_wavName amrFilePath:_amrFilePath voiceTime:voice_time foreignNickname:_foreign_nickname foreignAvatar:_foreign_head_portrait msgObj:msgObj timeMsgObj:msgTimeMsgObj];
            });
            
        }else {
            [ws.messagesList removeObject:_voiceTimeMsgObj];
            for (int i = (int)ws.messagesList.count - 1; i >= 0; i--) {
                MsgObject *msgObj = [ws.messagesList objectAtIndex:i];
                if (msgObj.m_type == MsgVoice && msgObj.f_voice_time <= 0.6 && msgObj.delivery_status == 4 && msgObj.direction == YES) {
                    [ws.messagesList removeObjectAtIndex:i];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeDeleteMsg]];
            
            _HUD.labelText = @"录音时间太短！";
            [_HUD show:YES];
            [_HUD hide:YES afterDelay:1];
            
            // 删除存储的
            [_fileManager removeItemAtPath:_wavFilePath error:nil];
        }
        [_recorder stop];
    }
    
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
}

#pragma mark - 聊天详情
- (void)goChatDetail
{
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (isIos7) {
        self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    }
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    
    _navTitle = _foreign_nickname;
    if ([_foreign_nickname isEqualToString:@""]) {
        _navTitle = @"雷友";
    }
    
    ws = [WSocket shareWSocket];
    _local_user = ws.wJid.username;
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    
    self.navigationItem.title = _foreign_user;
    
    _oldHeight = 30;
    _page = 1;
    _prevIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    _isKeyBoadShow = NO;
    _playVoiceNowIndex = -1;
    
    _pageCount = [ws getMsgPageCount:_foreign_user];
    if (_pageCount <= 1) {
        _isPageFinish = YES;
    }
    if (ws.messagesList.count < kPageSize) {
        _isPageFinish = YES;
    }
    
    _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - kWriteMsgViewHeight);
    _tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBotton)];
    [_tableView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideBotton)];
    swipeGes.direction = UISwipeGestureRecognizerDirectionDown;
    [_tableView addGestureRecognizer:swipeGes];
    
    UISwipeGestureRecognizer *swipeGes2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideBotton)];
    swipeGes2.direction = UISwipeGestureRecognizerDirectionUp;
    [_tableView addGestureRecognizer:swipeGes2];
    
    _writeMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, _navHeight + _tableView.frame.size.height, self.view.frame.size.width, kWriteMsgViewHeight)];
    _writeMsgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_writeMsgView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_writeMsgView addSubview:lineView];
    
    _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceBtn.frame = CGRectMake(2, kButtonTop, kButtonHeight, kButtonHeight);
    _voiceBtn.tag = 202;
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [_voiceBtn addTarget:self action:@selector(showVoice:) forControlEvents:UIControlEventTouchUpInside];
    [_writeMsgView addSubview:_voiceBtn];
    
    _msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(kButtonHeight + 5, kWriteViewSubTop, self.view.frame.size.width - 120, kMsgTextViewHeight)];
    _textViewHeight = _msgTextView.frame.size.height;
    _msgTextView.layer.borderWidth = 0.5;
    _msgTextView.font = [UIFont systemFontOfSize:kMsgTextViewFontSize];
    _msgTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _msgTextView.layer.cornerRadius = 5;
    _msgTextView.returnKeyType = UIReturnKeySend;
    _msgTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    _msgTextView.scrollEnabled = YES;
    _msgTextView.delegate = self;
    _msgTextView.enablesReturnKeyAutomatically = YES;
    _msgTextView.showsHorizontalScrollIndicator = NO;
    _msgTextView.showsVerticalScrollIndicator = YES;
    [_writeMsgView addSubview:_msgTextView];
    
    _expressionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _expressionBtn.frame = CGRectMake(_msgTextView.frame.origin.x + _msgTextView.frame.size.width + 5, kButtonTop, kButtonHeight, kButtonHeight);
    _expressionBtn.tag = 200;
    [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    [_expressionBtn addTarget:self action:@selector(showExpression:) forControlEvents:UIControlEventTouchUpInside];
    [_writeMsgView addSubview:_expressionBtn];
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreBtn.frame = CGRectMake(_expressionBtn.frame.origin.x + kButtonHeight + 2, kButtonTop, kButtonHeight, kButtonHeight);
    [_moreBtn setBackgroundImage:[UIImage imageNamed:@"multiMedia"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.tag = 205;
    [_writeMsgView addSubview:_moreBtn];
    
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = CGRectMake(kButtonHeight + 5, kWriteViewSubTop, self.view.frame.size.width - 120, 35);
    _recordBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _recordBtn.layer.cornerRadius = 5;
    _recordBtn.layer.borderWidth = 0.5;
    [_recordBtn setTitle:kPressString forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordBtn addTarget:self action:@selector(handlePress) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(handleLoosen) forControlEvents:UIControlEventTouchUpInside];
    [_recordBtn addTarget:self action:@selector(handleCancelPress) forControlEvents:UIControlEventTouchUpOutside];
    [_recordBtn addTarget:self action:@selector(handleDragOut) forControlEvents:UIControlEventTouchDragOutside];
    [_recordBtn addTarget:self action:@selector(handleDragIn) forControlEvents:UIControlEventTouchDragInside];
    [_writeMsgView addSubview:_recordBtn];
    _recordBtn.hidden = YES;
    
    _localUserImgPath = [NSString stringWithFormat:@"%@%@.jpeg", ws.wJid.userDir, @"me"];
    if ([_foreign_user isEqualToString:_local_user]) {
        _foreignUserImgPath = _localUserImgPath;
    }else{
        _foreignUserImgPath = [NSString stringWithFormat:@"%@%@.jpeg", ws.wJid.userDir, [ws upper16_MD5:_foreign_head_portrait]];
    }
    if ([_fileManager fileExistsAtPath:_localUserImgPath]) {
        _localAvatar = [UIImage imageWithData:[NSData dataWithContentsOfFile:_localUserImgPath]];
    }else{
        _localAvatar = kDefaultImage;
    }
    if ([_fileManager fileExistsAtPath:_foreignUserImgPath]) {
        _foreignAvatar = [UIImage imageWithData:[NSData dataWithContentsOfFile:_foreignUserImgPath]];
    }else{
        _foreignAvatar = kDefaultImage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self fixLabelArray:-1];
    _prevCount = (int)ws.messagesList.count;
    [_tableView reloadData];
    [self refrashTableView];
//    [self hideBotton];
    
    [self listeningUploadProgress];
    [self listeningDownloadProgress];
    
    if (_writeMsgView.frame.origin.y < self.view.frame.size.height-60) {
        [_msgTextView becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear _eView=====%@", _eView);
    _msgTextView.contentSize = CGSizeMake(_msgTextView.frame.size.width, _msgTextView.frame.size.height);
    
    // 在这里初始化视图，为了解决在viewDidLoad初次加载速度慢的问题
    if (_eView == nil) {
        
        [self.view addSubview:_hideBgView];
        [_hideBgView addSubview:_recordView];
        
        _eView = [[ExpressionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216) m_emojiArray:_m_emojiArray m_emojiDictionary:_m_emojiDictionary];
        _eView.delegate = self;
        [self.view addSubview:_eView];
        _mView = [[MoreView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216)];
        _mView.delegate = self;
        [self.view addSubview:_mView];
        
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        _HUD.delegate = self;
        _HUD.margin = 50.f;
        _HUD.dimBackground = YES;
        _HUD.mode = MBProgressHUDModeText;
        [self.view addSubview:_HUD];
    }
    
    if ([_timer isValid] == NO) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    
    if ([_uploadTimer isValid] == NO) {
        _uploadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(listeningUploadProgress) userInfo:nil repeats:YES];
    }
    
    if ([_downloadTimer isValid] == NO) {
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(listeningDownloadProgress) userInfo:nil repeats:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 删除近距离事件监听
    [self deleteTheCloseEvent];
    
    [_timer invalidate];
    [_uploadTimer invalidate];
    [_downloadTimer invalidate];
    _timer = nil;
    _uploadTimer = nil;
    _downloadTimer = nil;
}

#pragma mark - 跳转至用户详情页
- (void)goSelfUserDetail
{
    [self hideBotton];
    [self goUserDetail:_local_user];
}

- (void)goForeignUserDtail
{
    [self hideBotton];
    [self goUserDetail:_foreign_user];
}

- (void)goUserDetail:(NSString *)userPhone
{
    [self hideBotton];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ws.messagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgObject *msgObj = [ws.messagesList objectAtIndex:indexPath.row];
    if (msgObj.m_type == MsgTime) {
        static NSString *identifier1 = @"chat_time_cell";
        TimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[TimeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setMsgContent:msgObj.messageStr];
        return cell;
        
    }else if(msgObj.m_type == MsgEmpty) {
        static NSString *identifier = @"chat_empty_cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else {
        if (msgObj.direction) {
            if (msgObj.m_type == MsgText) {
                static NSString *identifier3 = @"chat_right_text_cell";
                RightTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = (int)indexPath.row;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_localAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
                
            }else if (msgObj.m_type == MsgImage) {
                static NSString *identifier3 = @"chat_right_image_cell";
                RightImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = (int)indexPath.row;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_localAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
                
            }else if (msgObj.m_type == MsgVoice) {
                static NSString *identifier3 = @"chat_right_voice_cell";
                RightVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[RightVoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_localAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goSelfUserDetail) forControlEvents:UIControlEventTouchUpInside];
                if (_playVoiceNowIndex == indexPath.row) {
                    [cell.voiceImage startAnimating];
                }
                return cell;
                
            }else{
                static NSString *identifier4 = @"chat_right_tip_cell";
                TipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if (cell == nil) {
                    cell = [[TipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell setMsgContent:msgObj.messageStr];
                return cell;
            }
            
        }else{
            if (msgObj.m_type == MsgText) {
                static NSString *identifier3 = @"chat_left_text_cell";
                LeftTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = (int)indexPath.row;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_foreignAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goForeignUserDtail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
                
            }else if (msgObj.m_type == MsgImage) {
                static NSString *identifier3 = @"chat_left_image_cell";
                LeftImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.rowIndex = (int)indexPath.row;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_foreignAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goForeignUserDtail) forControlEvents:UIControlEventTouchUpInside];
                return cell;
                
            }else if(msgObj.m_type == MsgVoice) {
                static NSString *identifier3 = @"chat_left_voice_cell";
                LeftVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if (cell == nil) {
                    cell = [[LeftVoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.indexPath = indexPath;
                cell.delegate = self;
                [cell setMsgContent:msgObj];
                [cell.avatarBtn setImage:_foreignAvatar forState:UIControlStateNormal];
                [cell.avatarBtn addTarget:self action:@selector(goForeignUserDtail) forControlEvents:UIControlEventTouchUpInside];
                if (_playVoiceNowIndex == indexPath.row) {
                    [cell.voiceImage startAnimating];
                }
                return cell;
                
            }else{
                static NSString *identifier4 = @"chat_left_tip_cell";
                TipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if (cell == nil) {
                    cell = [[TipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell setMsgContent:msgObj.messageStr];
                return cell;
            }
        }
    }
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0f;
    MsgObject *msgObj = [ws.messagesList objectAtIndex:indexPath.row];
    if (msgObj.m_type == MsgTime) {
        height = [TimeTableViewCell getMsgHeight];
    }else{
        if (msgObj.direction) {
            if (msgObj.m_type == MsgText) {
                height = [RightTextTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgImage) {
                height = [RightImageTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgVoice) {
                height = [RightVoiceTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgSystemTip) {
                height = [TipTableViewCell getMsgHeight:msgObj.messageStr];
            }
        }else{
            if (msgObj.m_type == MsgText) {
                height = [LeftTextTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgImage) {
                height = [LeftImageTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgVoice) {
                height = [LeftVoiceTableViewCell getMsgHeight:msgObj];
            }else if (msgObj.m_type == MsgSystemTip) {
                height = [TipTableViewCell getMsgHeight:msgObj.messageStr];
            }
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideBotton];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _eView.frame = CGRectMake(0, self.view.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
    _mView.frame = CGRectMake(0, self.view.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
    [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    _expressionBtn.tag = 200;
    _voiceBtn.tag = 202;
    
    _msgTextView.contentSize = CGSizeMake(_msgTextView.frame.size.width, _msgTextView.frame.size.height);
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] == NO) {
        _msgTextView.enablesReturnKeyAutomatically = NO;
    }
    [self changeFrame];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self changeFrame];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return NO;
}

- (void)sendMsg
{
//    NSMutableString *text = [NSMutableString stringWithFormat:@"%@", _msgTextView.text];
    
    int len = (int)_msgTextView.text.length;
    int limit = 499;
    
    if (len > limit) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"每次最多发送499字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    NSLog(@"sendMsg============len======%d", len);
    
//    if (len > limit) {
//        len = limit;
//    }
//    NSRange range = NSMakeRange(0, len);
//    NSString *sendText = [text substringWithRange:range];
    
    _srmsgCount += 1;
    dispatch_sync(_sendQueue, ^{
        [ws sendMsgToUser:_foreign_user mType:MsgText msgStr:_msgTextView.text];
    });
    _textViewHeight = 0.0f;
    _msgTextView.text = @"";
    _textViewHeight = kMsgTextViewHeight;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    if ([text isEqualToString:@"\n"]) {
        if ([_msgTextView.text isEqualToString:@""] == NO) {
            [self sendMsg];
        }
        return NO;
    }else if ([text length] == 0){
        [self delMsgTextViewText:1];
        return YES;
    }else{
//        [self changeFrame];
    }
    return YES;
}

- (int)delMsgTextViewText:(int)type
{
    int offset = 0;
    if (type == 1) {
        offset = 0;
        NSInteger length = [_msgTextView.text length];
        if (length > 0) {
            if (![[_msgTextView.text substringFromIndex:length - 1] isEqualToString:@"]"]) {
                return 1;
            }
        }
        
    }else{
        offset = -1;
    }
    
    NSString *text = [_msgTextView textInRange:[_msgTextView textRangeFromPosition:_msgTextView.beginningOfDocument toPosition:_msgTextView.selectedTextRange.start]];
    NSLog(@"text=======%@", text);
    NSString *e = [text substringWithRange:NSMakeRange(text.length - 3, 3)];
    BOOL isPix = NO;
    for (NSString *emoji in _m_emojiArray) {
        NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
        if ([e isEqualToString:emojiStr]) {
            offset = -2 + offset;
            isPix = YES;
            break;
        }
    }
    BOOL isPix2 = NO;
    if (isPix == NO) {
        NSString *e2 = [text substringWithRange:NSMakeRange(text.length - 4, 4)];
        for (NSString *emoji in _m_emojiArray) {
            NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
            if ([e2 isEqualToString:emojiStr]) {
                offset = -3 + offset;
                isPix2 = YES;
                break;
            }
        }
    }
    if (isPix2 == NO) {
        NSString *e3 = [text substringWithRange:NSMakeRange(text.length - 5, 5)];
        for (NSString *emoji in _m_emojiArray) {
            NSString *emojiStr = [NSString stringWithFormat:@"%@", emoji];
            if ([e3 isEqualToString:emojiStr]) {
                offset = -4 + offset;
                break;
            }
        }
    }
    
    UITextRange *range = [_msgTextView textRangeFromPosition:[_msgTextView positionFromPosition:_msgTextView.selectedTextRange.start offset:offset] toPosition:_msgTextView.selectedTextRange.start];
    [_msgTextView replaceRange:range withText:@""];
    
    return NO;
}

#pragma mark - ExpressionDelegate 表情
- (void)selectedExpression:(NSString *)str
{
    NSString *str2 = [NSString stringWithFormat:@"%@%@", _msgTextView.text, str];
    _msgTextView.text = str2;
    
    [self changeFrame];
}

- (void)delClicked
{
    [self delMsgTextViewText:2];
}

- (void)sendClicked
{
    if ([_msgTextView.text isEqualToString:@""] == NO) {
        [self sendMsg];
    }
}

#pragma mark - MoreViewDelegate 更多
- (void)selectedPhoto
{
    // 从相册中选取
    if ([self isPhotoLibraryAvailable]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"从相册中选取");
                         }];
    }
}

- (void)selectedShooting
{
    // 拍照
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
//        if ([self isFrontCameraAvailable]) {
//            controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//        }
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"拍照");
                         }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        image = [Common imageByScalingToMaxSize:image];
        NSLog(@"%f %f", image.size.width, image.size.height);
//        dispatch_sync(_sendQueue, ^{
//            [ws sendImage:_foreign_user image:image foreignDir:_foreignDir];
//        });
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"暂时不能发送图片" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 301){
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", _phoneStr]]];
        }else if (buttonIndex == 1) {
            UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
            [gpBoard setString:_phoneStr];
        }
        _phoneStr = nil;
        
    }else if (actionSheet.tag == 300){
        if (buttonIndex == 0) {
            NSString *email = [NSString stringWithFormat:@"mailto:%@", _emailStr];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
        _emailStr = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
//    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"MoreView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"ExpressionView"]) {
        return NO;
    }
    
    return  YES;
}


#pragma mark - 键盘
/// 显示键盘
-(void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    menuController.menuItems = [NSArray arrayWithObjects:nil];
    
    _tableView.scrollEnabled = NO;
    _isKeyBoadShow = YES;
    CGRect keyboardBounds;
    NSDictionary *userInfo = [paramNotification userInfo];
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    _keyboardHeight = keyboardBounds.size.height;
    float textHeight = _textViewHeight;
    [UIView animateWithDuration:duration.floatValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
        float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
        _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
        _voiceBtn.frame = CGRectMake(_voiceBtn.frame.origin.x, _writeMsgView.frame.size.height - _voiceBtn.frame.size.height - kButtonTop, _voiceBtn.frame.size.width, _voiceBtn.frame.size.height);
        _expressionBtn.frame = CGRectMake(_expressionBtn.frame.origin.x, _voiceBtn.frame.origin.y, _expressionBtn.frame.size.width, _expressionBtn.frame.size.height);
        _moreBtn.frame = CGRectMake(_moreBtn.frame.origin.x, _voiceBtn.frame.origin.y, _moreBtn.frame.size.width, _moreBtn.frame.size.height);
        _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _keyboardHeight - _writeMsgView.frame.size.height);
        [self fixTableViewOffset];
    }];
}

/// 隐藏键盘
- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSLog(@"隐藏键盘");
    _tableView.scrollEnabled = YES;
    _isKeyBoadShow = NO;
}

/// 修改位置
- (void)changeFrame
{
    float textHeight = 0.0f;
    textHeight = [Common getContentSize:_msgTextView.text withCGSize:CGSizeMake(_msgTextView.frame.size.width - 10, 1000) withSystemFontOfSize:kMsgTextViewFontSize].height;
    
    if (textHeight < kMsgTextViewHeight) {
        textHeight = kMsgTextViewHeight;
    }else{
        textHeight += kDefaultHeight;
    }
    _textViewHeight = textHeight;
    
    /// 最大高度
    if (_textViewHeight > kMsgTextViewMaxHeight) {
        _textViewHeight = kMsgTextViewMaxHeight;
    }
    
    _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, _textViewHeight);
    if (_textViewHeight > kMsgTextViewHeight) {
        _msgTextView.contentInset = UIEdgeInsetsMake(-5, 0, -2, 0);
    }else{
        _msgTextView.contentInset = UIEdgeInsetsZero;
    }
    if (textHeight < kMsgTextViewMaxHeight) {
        _msgTextView.scrollEnabled = NO;
        _msgTextView.contentSize = CGSizeMake(_msgTextView.frame.size.width, _msgTextView.frame.size.height);
    }else{
        _msgTextView.scrollEnabled = YES;
        _msgTextView.contentSize = CGSizeMake(_msgTextView.frame.size.width, textHeight);
    }
    if (_oldHeight != _textViewHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:0];
            float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
            _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
            _voiceBtn.frame = CGRectMake(_voiceBtn.frame.origin.x, _writeMsgView.frame.size.height - _voiceBtn.frame.size.height - kButtonTop, _voiceBtn.frame.size.width, _voiceBtn.frame.size.height);
            _expressionBtn.frame = CGRectMake(_expressionBtn.frame.origin.x, _voiceBtn.frame.origin.y, _expressionBtn.frame.size.width, _expressionBtn.frame.size.height);
            _moreBtn.frame = CGRectMake(_moreBtn.frame.origin.x, _voiceBtn.frame.origin.y, _moreBtn.frame.size.width, _moreBtn.frame.size.height);
            _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _keyboardHeight - _writeMsgView.frame.size.height);
            [self fixTableViewOffset];
        }];
    }
    

    if (textHeight < kMsgTextViewMaxHeight) {

    }else{
        CGPoint offset = _msgTextView.contentOffset;
        [_msgTextView setContentOffset:offset animated:NO];
        [_msgTextView scrollRangeToVisible:_msgTextView.selectedRange];
        CGPoint offset1 = _msgTextView.contentOffset;
        [_msgTextView setContentOffset:CGPointMake(offset1.x, offset1.y+12) animated:NO];
    }

    _oldHeight = _textViewHeight;
}

#pragma mark - 显示录音
- (void)showVoice:(UIButton *)sender
{
    if (sender.tag == 202) {
        NSLog(@"显示录音");
        sender.tag = 203;
        _moreBtn.tag = 205;
        _expressionBtn.tag = 200;
        [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"keyborad"] forState:UIControlStateNormal];
        _msgTextView.hidden = YES;
        _recordBtn.hidden = NO;
        if (_isKeyBoadShow == YES) {
            [_msgTextView resignFirstResponder];
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationCurve:7];
                _keyboardHeight = 0;
                float textHeight = kMsgTextViewHeight;
                _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
                float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
                _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
                _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _writeMsgView.frame.size.height);
                
                _voiceBtn.frame = CGRectMake(_voiceBtn.frame.origin.x, kButtonTop, _voiceBtn.frame.size.width, _voiceBtn.frame.size.height);
                _expressionBtn.frame = CGRectMake(_expressionBtn.frame.origin.x, _voiceBtn.frame.origin.y, _expressionBtn.frame.size.width, _expressionBtn.frame.size.height);
                _moreBtn.frame = CGRectMake(_moreBtn.frame.origin.x, _voiceBtn.frame.origin.y, _moreBtn.frame.size.width, _moreBtn.frame.size.height);
            }];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationCurve:7];
                _eView.frame = CGRectMake(0, self.view.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
                _mView.frame = CGRectMake(0, self.view.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
                [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
                _keyboardHeight = 0;
                float textHeight = kMsgTextViewHeight;
                _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
                float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
                _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
                _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _writeMsgView.frame.size.height);
                
                _voiceBtn.frame = CGRectMake(_voiceBtn.frame.origin.x, kButtonTop, _voiceBtn.frame.size.width, _voiceBtn.frame.size.height);
                _expressionBtn.frame = CGRectMake(_expressionBtn.frame.origin.x, _voiceBtn.frame.origin.y, _expressionBtn.frame.size.width, _expressionBtn.frame.size.height);
                _moreBtn.frame = CGRectMake(_moreBtn.frame.origin.x, _voiceBtn.frame.origin.y, _moreBtn.frame.size.width, _moreBtn.frame.size.height);
                
                [self fixTableViewOffset];
            }];
        }
    }else{
        sender.tag = 202;
        [sender setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        _recordBtn.hidden = YES;
        _msgTextView.hidden = NO;
        [_msgTextView becomeFirstResponder];
    }
}

#pragma mark - 显示表情
- (void)showExpression:(UIButton *)sender
{
    if (sender.tag == 200) {
        sender.tag = 201;
        _moreBtn.tag = 205;
        _voiceBtn.tag = 202;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"keyborad"] forState:UIControlStateNormal];
        _recordBtn.hidden = YES;
        _msgTextView.hidden = NO;
        _mView.frame = CGRectMake(0, self.view.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
        
        [_msgTextView resignFirstResponder];
        _tableView.scrollEnabled = NO;
        
        _keyboardHeight = _eView.frame.size.height;
        float textHeight = _textViewHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            _eView.frame = CGRectMake(0, self.view.frame.size.height - _eView.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
            _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
            float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
            _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
            _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _keyboardHeight - _writeMsgView.frame.size.height);
            [self fixTableViewOffset];
        }];
        
    }else {
        sender.tag = 200;
        [sender setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        _eView.frame = CGRectMake(0, self.view.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
        [_msgTextView becomeFirstResponder];
    }
}

#pragma mark - 显示更多操作
- (void)showMore:(UIButton *)sender
{
    if (sender.tag == 205) {
        sender.tag = 206;
        _voiceBtn.tag = 202;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        _recordBtn.hidden = YES;
        _msgTextView.hidden = NO;
        _expressionBtn.tag = 200;
        [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
        _eView.frame = CGRectMake(0, self.view.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
        [_msgTextView resignFirstResponder];
        _tableView.scrollEnabled = NO;
        
        _keyboardHeight = _mView.frame.size.height;
        
        float textHeight = _textViewHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            _mView.frame = CGRectMake(0, self.view.frame.size.height - _mView.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
            _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
            float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
            _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - _keyboardHeight - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
            _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _navHeight - _keyboardHeight - _writeMsgView.frame.size.height);
            [self fixTableViewOffset];
        }];
    }else{
        sender.tag = 205;
        _mView.frame = CGRectMake(0, self.view.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
        [_msgTextView becomeFirstResponder];
    }
}

/// 处理tableview contentOffset
- (void)fixTableViewOffset
{
    if (_prevCount >= 1) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_prevCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - M80AttributedLabelDelegate
- (void)m80AttributedLabel:(M80AttributedLabel *)label clickedOnLink:(M80AttributedLabelURL *)linkInfo
{
    NSLog(@"isShowMenu===%d", _isShowMenu);
    if (_isShowMenu == NO) {
        _isShowMenu = NO;
        if (linkInfo.linkType == LinkTypeURL) {
//            WebViewController *webVC = [[WebViewController alloc] init];
//            webVC.webUrl = linkInfo.linkInfo;
//            [self.navigationController pushViewController:webVC animated:YES];
        }else if (linkInfo.linkType == LinkTypeEmail) {
            _emailStr = [NSString stringWithFormat:@"%@", linkInfo.linkInfo];
            NSString *title = [NSString stringWithFormat:@"向%@发送邮件", _emailStr];
            UIActionSheet *emailSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"使用默认邮件账户", nil];
            emailSheet.tag = 300;
            [emailSheet showInView:self.view];
        }else if (linkInfo.linkType == LinkTypePhone) {
            _phoneStr = [NSString stringWithFormat:@"%@", linkInfo.linkInfo];
            NSString *title = [NSString stringWithFormat:@"%@可能是一个电话号码，你可以", _phoneStr];
            UIActionSheet *phoneSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"呼叫", @"复制", nil];
            phoneSheet.tag = 301;
            [phoneSheet showInView:self.view];
        }
    }
}

/// 消息处理
- (int)fixLabelArray:(int)type
{
//    NSLog(@"消息处理===%d", ws.messagesList.count);
    for (int i = (int)ws.messagesList.count - 1; i >= 0; i--) {
        MsgObject *msgObj = [ws.messagesList objectAtIndex:i];
        if (msgObj.msgRowHeight > 0) {
            
        }else{
            if (msgObj.m_type == MsgText) {
                M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
                label.delegate = self;
                label.autoDetectLinks = NO;
                label.underLineForLink = NO;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:kFontSize];
                [self updateLabel:label text:msgObj.messageStr];
                float labelHeight = label.frame.size.height;
                if (label.frame.size.height < 30) {
                    labelHeight = 30 + kTextTop * 2 + 3;
                }else{
                    labelHeight = labelHeight + kTextTop * 3;
                }
                msgObj.msgLabel = label;
                msgObj.msgRowHeight = labelHeight;
            }else if (msgObj.m_type == MsgTime) {
                msgObj.msgLabel = nil;
                msgObj.msgRowHeight = 0.0f;
            }else if (msgObj.m_type == MsgImage) {
                msgObj.msgLabel = nil;
                msgObj.msgRowHeight = 0.0f;
            }else if (msgObj.m_type == MsgVoice) {
                msgObj.msgLabel = nil;
                msgObj.msgRowHeight = 0.0f;
            }else if (msgObj.m_type == MsgSystemTip) {
                msgObj.msgLabel = nil;
                msgObj.msgRowHeight = 0.0f;
            }
        }
    }
    
    if (type == MsgChatRefrashTypePageNoFinish) {
        [self performSelector:@selector(doneDownReLoadingTableViewData) withObject:nil afterDelay:0.5];
        
    }else if(type == MsgChatRefrashTypePageIsFinish) {
        [self performSelector:@selector(doneDownReLoadingTableViewData2) withObject:nil afterDelay:0.5];
        
    }
    
    return 0;
}

- (void)updateLabel:(M80AttributedLabel *)label text:(NSString *)text
{
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"(.*?)(\\[*+\\]|\\Z)"
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    NSArray* chunks = [regex matchesInString:text options:0
                                       range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *b in chunks) {
        NSString *bstr = [text substringWithRange:b.range];
        if (bstr.length > 0) {
            NSString *imgName = [_m_emojiDictionary objectForKey:bstr];
            if (imgName) {
                UIImage *image = [UIImage imageNamed:imgName];
                [label appendImage:image
                           maxSize:CGSizeMake(24, 24)
                            margin:UIEdgeInsetsZero
                         alignment:M80ImageAlignmentCenter];
            }else{
                NSArray *array = [bstr componentsSeparatedByString:@"["];
                int i = 0;
                for (NSString *str in array) {
                    if (i == 0) {
                        [label appendText:str];
                    }else{
                        NSString *astr = [NSString stringWithFormat:@"[%@", str];
                        NSString *imgName = [_m_emojiDictionary objectForKey:astr];
                        if (imgName) {
                            UIImage *image = [UIImage imageNamed:imgName];
                            [label appendImage:image
                                       maxSize:CGSizeMake(24, 24)
                                        margin:UIEdgeInsetsZero
                                     alignment:M80ImageAlignmentCenter];
                        }else{
                            [label appendText:astr];
                        }
                    }
                    i++;
                }
            }
        }
    }
    
    NSArray *rexArray = [M80AttributedLabel addRexArr:label.labelText];
    NSArray *httpArr = [rexArray objectAtIndex:0];
    NSArray *phoneNumArr = [rexArray objectAtIndex:1];
    NSArray *emailArr = [rexArray objectAtIndex:2];
    if ([emailArr count]) {
        for (NSString *emailStr in emailArr) {
            [label addCustomLink:[NSURL URLWithString:emailStr] forRange:[label.labelText rangeOfString:emailStr] linkType:LinkTypeEmail];
        }
    }
    if ([phoneNumArr count]) {
        for (NSString *phoneNum in phoneNumArr) {
            [label addCustomLink:[NSURL URLWithString:phoneNum] forRange:[label.labelText rangeOfString:phoneNum] linkType:LinkTypePhone];
        }
    }
    if ([httpArr count]) {
        for (NSString *httpStr in httpArr) {
            [label addCustomLink:[NSURL URLWithString:httpStr] forRange:[label.labelText rangeOfString:httpStr] linkType:LinkTypeURL];
        }
    }
    
    CGRect labelRect = label.frame;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 120, CGFLOAT_MAX)];
    labelRect.size.width = labelSize.width;
    labelRect.size.height = labelSize.height;
    label.frame = labelRect;
}

#pragma mark - 录音
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"无法录音"
                                                     message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许雷Ta访问你的手机麦克风"
                                                    delegate:nil
                                           cancelButtonTitle:@"关闭"
                                           otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}
/// 按住 说话
- (void)handlePress
{
    if (_avPlay.playing) {
        [_avPlay stop];
    }
    
    if (![self canRecord]) {
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"暂时不能发送语音" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
    
    return;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    _timingCount = 0;
    _recordView.microPhoneImageView.hidden = NO;
    _recordView.recordingHUDImageView.hidden = NO;
    _recordView.timingCountLabel.hidden = YES;
    [_timer setFireDate:[NSDate date]];
    
    [_recordBtn setTitle:kLoosenString forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    NSLog(@"按住 说话");
    _hideBgView.hidden = NO;
    long timestamp = [[NSDate date] timeIntervalSince1970];
    _wavName = [NSString stringWithFormat:@"%ld.wav", timestamp];
    _amrName = [NSString stringWithFormat:@"%ld.amr", timestamp];
    _wavFilePath = [NSString stringWithFormat:@"%@%@", _foreignDir, _wavName];
    _amrFilePath = [NSString stringWithFormat:@"%@%@", _foreignDir, _amrName];
    
    _urlPlay = [NSURL fileURLWithPath:_wavFilePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:_urlPlay settings:_setting error:nil];
    _recorder.delegate = self;
    [_recorder peakPowerForChannel:0];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    
    // 创建录音文件，准备录音
    if ([_recorder prepareToRecord]) {
        // 开始
        [_recorder record];
        BOOL isTime = NO;
        self.voiceTimeMsgObj = nil;
        self.voiceMsgObj = nil;
        long timestamp = [[NSDate date] timeIntervalSince1970];
        if (ws.messagesList.count > 0) {
            MsgObject *lastMsgObj = [ws.messagesList lastObject];
            if (lastMsgObj.m_type != MsgTime) {
                if (timestamp - kBetweenTime > lastMsgObj.mtimestamp) {
                    MsgObject *msgObjt = [[MsgObject alloc] init];
                    msgObjt.messageStr = [ws turnTime:[NSString stringWithFormat:@"%ld", timestamp] nowtime:timestamp isShowHM:YES];
                    msgObjt.m_type = MsgTime;
                    msgObjt.mtimestamp = timestamp;
                    self.voiceTimeMsgObj = msgObjt;
                    [ws.messagesList addObject:msgObjt];
                    isTime = YES;
                }
            }
        }else{
            MsgObject *msgObjt = [[MsgObject alloc] init];
            msgObjt.messageStr = [ws turnTime:[NSString stringWithFormat:@"%ld", timestamp] nowtime:timestamp isShowHM:YES];
            msgObjt.m_type = MsgTime;
            msgObjt.mtimestamp = timestamp;
            self.voiceTimeMsgObj = msgObjt;
            [ws.messagesList addObject:msgObjt];
            isTime = YES;
        }
        
        MsgObject *msgObj = [[MsgObject alloc] init];
        msgObj.mtimestamp = timestamp;
        msgObj.direction = YES;
        msgObj.localUser = ws.wJid.username;
        msgObj.messageStr = @"[语音]";
        msgObj.delivery_status = 4;
        msgObj.isread = YES;
        msgObj.foreignUser = _foreign_user;
        msgObj.m_type = MsgVoice;
        msgObj.file_url = nil;
        msgObj.voice_time = 10;
        msgObj.f_voice_time = 0.0f;
        msgObj.foreignNickname = _foreign_nickname;
        msgObj.foreignAvatar = _foreign_head_portrait;
        if (ws.isConnect == kConnectFailue) {
            msgObj.serial_id = @"-2";
        }
        self.voiceMsgObj = msgObj;
        [ws.messagesList addObject:msgObj];
        _voiceIndexPath = [NSIndexPath indexPathForRow:(ws.messagesList.count - 1) inSection:0];
        NSLog(@"_voiceIndexPath===%d", (int)_voiceIndexPath.row);
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeSendSuccess]];
    }
}

/// 松开 结束
- (void)handleLoosen
{
    NSLog(@"松开 结束");
    float delayTime = 0.0f;
    
    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordBtn setTitle:kPressString forState:UIControlStateNormal];
    [_timer setFireDate:[NSDate distantFuture]];
    if ([_recorder isRecording] && _voiceIndexPath.row > 0) {
        MsgObject *msgObj = [ws.messagesList objectAtIndex:_voiceIndexPath.row];
        RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
        cell.activityView.hidden = NO;
        cell.timeLabel.hidden = NO;
        msgObj.f_voice_time = _recorder.currentTime + delayTime;
        int voice_time = ceilf(msgObj.f_voice_time);
        msgObj.voice_time = voice_time;
        float timeWidth = 16.0f;
        if (voice_time >= 10) {
            timeWidth = 24.0f;
        }
        cell.timeLabel.text = [NSString stringWithFormat:@"%d\"", voice_time];
        float voiceWidth = 40.0f;
        if (voice_time > 1) {
            voiceWidth = voiceWidth + voice_time * 2.66f;
        }
        float orginX = self.view.frame.size.width - 55 - voiceWidth - timeWidth;
        cell.bgImageView.alpha = 1;
        cell.activityView.frame = CGRectMake(orginX - 30, cell.activityView.frame.origin.y, 30, 30);
        cell.voiceBtn.backgroundColor = [UIColor clearColor];
        cell.timeLabel.frame = CGRectMake(orginX, 20, timeWidth, 20);
        cell.msgView.frame = CGRectMake(orginX + timeWidth, cell.msgView.frame.origin.y, voiceWidth + 15, 40);
        cell.bgImageView.frame = CGRectMake(0, 0, voiceWidth + 15, 40);
        cell.voiceBtn.frame = CGRectMake(4, 1.5, cell.msgView.frame.size.width - 18, cell.msgView.frame.size.height - 3);
        cell.voiceImage.frame = CGRectMake(cell.voiceBtn.frame.size.width - 25, 9, 20, 20);
        [cell.activityView startAnimating];
    }
    [self performSelector:@selector(delaySend) withObject:nil afterDelay:delayTime];
}

/// 延迟几秒发送
- (void)delaySend
{
    NSLog(@"_recorder=======%d", [_recorder isRecording]);
    if ([_recorder isRecording]) {
        float cTime = _recorder.currentTime;
        
        NSLog(@"cTime=%f", cTime);
        if (cTime > 0.6) {
            NSLog(@"发出去  _voiceIndexPath.row====%d", (int)_voiceIndexPath.row);
            if (_voiceIndexPath.row > 0) {
//                int voice_time = ceilf(cTime);
//                MsgObject *msgObj = [ws.messagesList objectAtIndex:_voiceIndexPath.row];
                MsgObject *msgTimeMsgObj = _voiceTimeMsgObj;
                if (_voiceIndexPath.row >= 1) {
                    MsgObject *vmsgTimeMsgObj = [ws.messagesList objectAtIndex:(_voiceIndexPath.row - 1)];
                    if (vmsgTimeMsgObj.m_type == MsgTime && vmsgTimeMsgObj.direction == YES) {
                        msgTimeMsgObj = vmsgTimeMsgObj;
                    }
                }
                //如果录制时间 < 0.6 不发送
                _srmsgCount++;
                dispatch_sync(_sendQueue, ^{
//                    [ws sendVoice:_foreign_user mType:MsgVoice wavFilePath:_wavFilePath wavName:_wavName amrFilePath:_amrFilePath voiceTime:voice_time foreignNickname:_foreign_nickname foreignAvatar:_foreign_head_portrait msgObj:msgObj timeMsgObj:msgTimeMsgObj];
                });
            }else{
                [ws.messagesList removeObject:_voiceTimeMsgObj];
                for (int i = (int)ws.messagesList.count - 1; i >= 0; i--) {
                    MsgObject *msgObj = [ws.messagesList objectAtIndex:i];
                    if (msgObj.m_type == MsgVoice && msgObj.f_voice_time <= 0.6 && msgObj.delivery_status == 4 && msgObj.direction == YES) {
                        [ws.messagesList removeObjectAtIndex:i];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeDeleteMsg]];
            }
            
        }else {
            [ws.messagesList removeObject:_voiceTimeMsgObj];
            for (int i = (int)ws.messagesList.count - 1; i >= 0; i--) {
                MsgObject *msgObj = [ws.messagesList objectAtIndex:i];
                if (msgObj.m_type == MsgVoice && msgObj.f_voice_time <= 0.6 && msgObj.delivery_status == 4 && msgObj.direction == YES) {
                    [ws.messagesList removeObjectAtIndex:i];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeDeleteMsg]];
            
            _HUD.labelText = @"录音时间太短！";
            [_HUD show:YES];
            [_HUD hide:YES afterDelay:1];
            
            // 删除存储的
            [_fileManager removeItemAtPath:_wavFilePath error:nil];
        }
        [_recorder stop];
    }
    
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
}

/// 松开手指 取消发送
- (void)handleCancelPress
{
    NSLog(@"松开手指 取消发送");
    
    _hideBgView.hidden = YES;
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    _recordView.remindLabel.backgroundColor = [UIColor clearColor];
    [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordBtn setTitle:kPressString forState:UIControlStateNormal];
    
    // 删除录制文件
    [_recorder stop];
    [_fileManager removeItemAtPath:_wavFilePath error:nil];
    [ws.messagesList removeObject:_voiceTimeMsgObj];
    [ws.messagesList removeObject:_voiceMsgObj];
    _voiceIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
    [_timer setFireDate:[NSDate distantFuture]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMsgListMessage object:[NSNumber numberWithInt:MsgChatRefrashTypeDeleteMsg]];
}

/// 拖出去
- (void)handleDragOut
{
    NSLog(@"松开手指，取消发送=======");
    _recordView.remindLabel.text = kVoiceRecordResaueString;
    _recordView.remindLabel.backgroundColor = [UIColor redColor];
}

/// 拖进来
- (void)handleDragIn
{
    NSLog(@"拖进来=======");
    _recordView.remindLabel.text = kVoiceRecordPauseString;
    _recordView.remindLabel.backgroundColor = [UIColor clearColor];
}

/// 音量
- (void)detectionVoice
{
    if ([_recorder isRecording]) {
        _timingCount++;
        [_recorder updateMeters];//刷新音量数据
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
//        NSLog(@"%lf",lowPassResults);
        //最大50  0
        //图片 小-》大
        if (0 < lowPassResults <= 0.06) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal001.png"]];
        }else if (0.06 < lowPassResults <= 0.16) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal002.png"]];
        }else if (0.16 < lowPassResults <= 0.26) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal003.png"]];
        }else if (0.26 < lowPassResults <= 0.36) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal004.png"]];
        }else if (0.36 < lowPassResults <= 0.46) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal005.png"]];
        }else if (0.46 < lowPassResults <= 0.56) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal006.png"]];
        }else if (0.56 < lowPassResults <= 0.66) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal007.png"]];
        }else if (0.66 < lowPassResults <= 0.76) {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal008.png"]];
        }else {
            [_recordView.recordingHUDImageView setImage:[UIImage imageNamed:@"RecordingSignal008.png"]];
        }
        
        NSLog(@"_timingCount=====%d", _timingCount);
        if (_voiceIndexPath.row >= 0) {
            [UIView animateWithDuration:0.2 animations:^{
                RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_voiceIndexPath];
                if (_timingCount % 2 == 0) {
                    cell.bgImageView.alpha = 0.5;
                }else{
                    cell.bgImageView.alpha = 1;
                }
            }];
        }
        
        if (_timingCount >= (kVoiceTime - 9)) {
            _recordView.microPhoneImageView.hidden = YES;
            _recordView.recordingHUDImageView.hidden = YES;
            _recordView.timingCountLabel.hidden = NO;
            _recordView.timingCountLabel.text = [NSString stringWithFormat:@"%d", kVoiceTime - _timingCount];
        }
        if (_timingCount > kVoiceTime) {
            [self handleLoosen];
        }
    }else{
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

#pragma mark - 隐藏底部
- (void)hideChatBotton
{
    [self hideBotton];
}

#pragma mark - 长按弹出显示菜单
- (void)longPressBegin:(NSIndexPath *)indPath
{
    _isShowMenu = YES;
    [self hideBotton];
    
    CGRect aFrame = CGRectZero;
    _rowIndex = (int)indPath.row;
    MsgObject *msgObj = [ws.messagesList objectAtIndex:_rowIndex];
    if (msgObj.m_type == MsgText) {
        if (msgObj.direction) {
            RightTextTableViewCell *cell = (RightTextTableViewCell *)[_tableView cellForRowAtIndexPath:indPath];
            float orginX = cell.frame.size.width - cell.bgImageView.frame.size.width - 50;
            aFrame = CGRectMake(orginX, cell.frame.origin.y + 13, 50, cell.frame.size.height);
        }else{
            LeftTextTableViewCell *cell = (LeftTextTableViewCell *)[_tableView cellForRowAtIndexPath:indPath];
            aFrame = CGRectMake(50, cell.frame.origin.y + 13, 50, cell.frame.size.height);
        }
    }
    
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem_1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(msgTextCopy)];
//    UIMenuItem *menuItem_2 = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(msgForwarding)];
    menuController.menuItems = [NSArray arrayWithObjects: menuItem_1, nil];
    [menuController setTargetRect:aFrame inView:_tableView];
    [menuController setMenuVisible:YES animated:YES];
}

- (void)msgTextCopy
{
    MsgObject *msgObj = [ws.messagesList objectAtIndex:_rowIndex];
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    [gpBoard setString:msgObj.messageStr];
}

- (void)msgForwarding
{
    
}

- (void)longPressShowMenu:(NSIndexPath *)indPath
{
    _isShowMenu = NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(msgTextCopy)) {
        return YES;//显示
    }else if (action == @selector(msgForwarding)) {
        return YES;
    }
    return NO;//不显示
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark - 单机系统消息提示显示好友信息
- (void)tapShowUserDetail
{
    [self goForeignUserDtail];
}

#pragma mark - 右侧代理/左侧代理
- (void)playVoice:(NSIndexPath *)indexPath
{
    MsgObject *msgObj = [ws.messagesList objectAtIndex:indexPath.row];
    if (msgObj.delivery_status != 4) {
        if (_playVoiceNowIndex == indexPath.row) {
            if (_avPlay.playing) {
                [_avPlay stop];
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage stopAnimating];
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage stopAnimating];
                }
            }else{
                [_avPlay play];
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage startAnimating];
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage startAnimating];
                }
            }
        }else{
            _playVoiceNowIndex = (int)indexPath.row;
            NSLog(@"播放语音====%@", msgObj.file_url);
            NSString *playPath = @"";
            if (msgObj.direction) {
                playPath = [NSString stringWithFormat:@"%@%@", _foreignDir, msgObj.file_url];
            }else{
                playPath = [NSString stringWithFormat:@"%@%@.wav", _foreignDir, [ws upper16_MD5:msgObj.file_url]];
            }
            if ([_fileManager fileExistsAtPath:playPath]) {
                NSLog(@"playPath===%@", playPath);
                NSURL *playUrl = [NSURL URLWithString:playPath];
                if (_avPlay.playing) {
                    [_avPlay stop];
                }
                if (_prevIndexPath.row >= 0) {
                    RightVoiceTableViewCell *rightCell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [rightCell.voiceImage stopAnimating];
                    LeftVoiceTableViewCell *leftCell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:_prevIndexPath];
                    [leftCell.voiceImage stopAnimating];
                }
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
                AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:playUrl error:nil];
                player.delegate = self;
                _avPlay = player;
                _avPlay.volume = 1;
                [_avPlay prepareToPlay];
                [_avPlay play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
                }
                if (msgObj.direction) {
                    RightVoiceTableViewCell *cell = (RightVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
                    cell.voiceImage.animationImages = _senderVoiceArray;
                    cell.voiceImage.animationDuration = 1;
                    cell.voiceImage.animationRepeatCount = [cell.timeLabel.text intValue];
                    [cell.voiceImage startAnimating];
                }else{
                    LeftVoiceTableViewCell *cell = (LeftVoiceTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];\
                    cell.noReadImageView.hidden = YES;
                    cell.voiceImage.animationImages = _receiverVoiceArray;
                    cell.voiceImage.animationDuration = 1;
                    cell.voiceImage.animationRepeatCount = [cell.timeLabel.text intValue];
                    [cell.voiceImage startAnimating];
                    [self updateVoiceMsgAlreadyRead:msgObj];
                }
            }else{
                NSLog(@"没有下载完毕");
            }
        }
        
        _prevIndexPath = indexPath;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完");
    [self voicePlayFinish];
}

- (void)voicePlayFinish
{
    _playVoiceNowIndex = -1;
    [self deleteTheCloseEvent];
}

/// 删除近距离事件监听
- (void)deleteTheCloseEvent
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - 更新消息为已读
- (void)updateMsgAlreadyRead:(MsgObject *)msgObj
{
//    for (Message *msg in [ws msgRemindList]) {
//        if ([msg.phone isEqualToString:msgObj.foreignUser]) {
//            msg.isread = YES;
//            UIViewController *tController = [self.tabBarController.viewControllers objectAtIndex:1];
//            int badgeValue = [tController.tabBarItem.badgeValue intValue];
//            int value = badgeValue - msg.tipCount;
//            if (value <= 0) {
//                tController.tabBarItem.badgeValue = nil;
//            }else{
//                tController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", value];
//            }
//            msg.tipCount = 0;
//        }
//    }
//    [ws updateAlreadyRead:msgObj.mid foreign_user:msgObj.foreignUser];
}

#pragma mark - 更新语音为已读
- (void)updateVoiceMsgAlreadyRead:(MsgObject *)msgObj
{
    if (msgObj.voice_read == NO) {
        msgObj.voice_read = YES;
//        for (Message *msg in [ws msgRemindList]) {
//            if ([msg.phone isEqualToString:msgObj.foreignUser]) {
//                msg.voice_read = YES;
//            }
//        }
//        [ws updateVoiceAlreadyRead:msgObj.mid foreign_user:msgObj.foreignUser];
    }
}

#pragma mark - 重新发送消息
- (void)resendMsg:(int)rowIndex
{
    MsgObject *msgObj = [[ws messagesList] objectAtIndex:rowIndex];
    dispatch_sync(_sendQueue, ^{
        [ws resendFailueMsg:msgObj foreignDir:_foreignDir];
    });
}

#pragma mark - 查看图片
- (void)lookImage:(int)rowIndex
{
    NSLog(@"查看图片");
    [self hideBotton];
    MsgObject *msgObj = [ws.messagesList objectAtIndex:rowIndex];
    LookImageViewController *lookImgVC = [[LookImageViewController alloc] init];
    lookImgVC.imgPath = msgObj.imgPath;
    [self presentViewController:lookImgVC animated:NO completion:nil];
}

#pragma mark - 隐藏底部
- (void)hideBotton
{
    _tableView.scrollEnabled = YES;
    if (_isKeyBoadShow == YES) {
        [_msgTextView resignFirstResponder];
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            if (_keyboardHeight > 0) {
                _keyboardHeight = 0;
                float textHeight = _textViewHeight;
                _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
                float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
                _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
                _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _writeMsgView.frame.size.height - _navHeight);
            }
        }];
        
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:7];
            _eView.frame = CGRectMake(0, self.view.frame.size.height, _eView.frame.size.width, _eView.frame.size.height);
            _mView.frame = CGRectMake(0, self.view.frame.size.height, _mView.frame.size.width, _mView.frame.size.height);
            [_expressionBtn setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
            _expressionBtn.tag = 200;
            _voiceBtn.tag = 202;
            if (_keyboardHeight > 0) {
                _keyboardHeight = 0;
                float textHeight = _textViewHeight;
                _msgTextView.frame = CGRectMake(_msgTextView.frame.origin.x, kWriteViewSubTop, _msgTextView.frame.size.width, textHeight);
                float writeMsgViewHeight = _msgTextView.frame.size.height + kWriteViewSubTop*2;
                _writeMsgView.frame = CGRectMake(0, self.view.frame.size.height - writeMsgViewHeight, _writeMsgView.frame.size.width, writeMsgViewHeight);
                _tableView.frame = CGRectMake(0, _navHeight, self.view.frame.size.width, self.view.frame.size.height - _writeMsgView.frame.size.height - _navHeight);
            }
        }];
    }
}

#pragma mark - 监听上传进度
- (void)listeningUploadProgress
{
//    if (ws.currentChatImageUpload.m_type == MsgImage) {
//        int progress = [ws getUploadProgress];
//        NSLog(@"上传图片进度=====%d", progress);
//        if (progress < 100) {
//            for (MsgObject *msgObj in [ws messagesList]) {
//                if (msgObj.m_type == MsgImage && msgObj.direction == YES && [msgObj.foreignUser isEqualToString:_foreign_user]) {
//                    if (msgObj.delivery_status == 1) {
//                        msgObj.upload_progress = progress;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [_tableView reloadData];
//                        });
//                        break;
//                    }
//                }
//            }
//        }
//    }
//    if (ws.currentChatVoiceUpload.m_type == MsgVoice) {
//        int voiceProgress = [ws getVoiceUploadProgress];
//        NSLog(@"音频上传进度========%d", voiceProgress);
//    }
//    
//    if (ws.current_uploadModel.m_type == MtypeImage && ws.current_uploadModel.upload_file_type == Messages) {
//        int progress = [ws getUploadProgress];
//        NSLog(@"上传图片进度=====%d", progress);
//        if (progress < 100) {
//            for (MsgObject *msgObj in [ws messagesList]) {
////                if (msgObj.m_type == MsgImage && msgObj.direction == YES && [msgObj.foreignUser isEqualToString:_foreign_user]) {
//                if (msgObj.mid == ws.current_uploadModel.mid) {
//                    if (msgObj.delivery_status == 1) {
//                        msgObj.upload_progress = progress;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [_tableView reloadData];
//                        });
//                        break;
//                    }
//                }
//            }
//        }
//    }

}

#pragma mark - 监听下载进度
- (void)listeningDownloadProgress
{
//    if (ws.currentChatImageDownload.m_type == MsgImage) {
//        int progress = [ws getDownloadProgress];
//        NSLog(@"图片下载进度=====%d", progress);
//        if (progress < 100) {
//            for (MsgObject *msgObj in [ws messagesList]) {
//                if (msgObj.m_type == MsgImage && msgObj.direction == NO && [msgObj.foreignUser isEqualToString:_foreign_user]) {
//                    if (msgObj.delivery_status == 1) {
//                        msgObj.download_progress = progress;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [_tableView reloadData];
//                        });
//                        break;
//                    }
//                }
//            }
//        }
//    }
    
//    if (ws.currentChatVoiceDownload.m_type == MsgVoice) {
//        int voiceProgress = [ws getVoiceDownloadProgress];
//        NSLog(@"音频下载进度========%d", voiceProgress);
//    }
//    
//    if (ws.current_downModel.msgObj.m_type == MsgImage) {
//        int progress = [ws getDownloadProgress];
//        NSLog(@"图片下载进度=====%d", progress);
//        if (progress < 100) {
//            for (MsgObject *msgObj in [ws messagesList]) {
////                if (msgObj.m_type == MsgImage && msgObj.direction == NO && [msgObj.foreignUser isEqualToString:_foreign_user]) {
//                if (msgObj.mid == ws.current_downModel.msgObj.mid) {
//                    if (msgObj.delivery_status == 1) {
//                        msgObj.download_progress = progress;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [_tableView reloadData];
//                        });
//                        break;
//                    }
//                }
//            }
//        }
//    }
}

@end
