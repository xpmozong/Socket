//
//  MessageViewController.m
//  WeiWei
//
//  Created by tw001 on 14/11/18.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableViewCell.h"
#import "LoginViewController.h"

#define kTitle @"消息"

@interface MessageViewController ()
{
    WSocket *ws;
}
@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTitle;
        self.tabBarItem.title = kTitle;
        self.tabBarItem.image = [UIImage imageNamed:@"recommend"];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (isIos7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    ws = [WSocket shareWSocket];
    _fileManager = [NSFileManager defaultManager];
    
    _m_emojiArray = [ws getEmojiArray];
    _m_emojiDictionary = [ws getEmojiDictionary];
    
    _senderVoiceArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                         [UIImage imageNamed:@"SenderVoiceNodePlaying003"],nil];
    _receiverVoiceArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                           [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"],nil];
    
    _setting = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat:8000], AVSampleRateKey,
                [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,//采样位数 默认 16
                [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                nil];
    
    _hideBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _hideBgView.hidden = YES;
    
    _recordView = [[RecordView alloc] initWithFrame:CGRectMake((_hideBgView.frame.size.width - 160)/2, (_hideBgView.frame.size.height - 160)/2, 160, 160)];
    _recordView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    _recordView.layer.cornerRadius = 5;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (isIos7) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        _tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 49, 0);
    }
    if (isIos8) {
        _tableView.layoutMargins = UIEdgeInsetsZero;
    }
    [self.view addSubview:_tableView];
    
    _dataArray = [[NSMutableArray alloc] init];
    Message *msg1 = [[Message alloc] init];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUsername] isEqualToString:@"xuping"]) {
        msg1.username = @"xuping2";
    }else{
        msg1.username = @"xuping";
    }
    msg1.type = @"chat";
    msg1.mAvatar = @"default";
    msg1.mDesc = @"俺们聊天吧";
    msg1.tipCount = 0;
    [_dataArray addObject:msg1];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
}

- (void)goLogin
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:NO];
}

- (void)goChat
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"message_cell";
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (isIos8) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    Message *msg = [_dataArray objectAtIndex:indexPath.row];
    [cell setContent:msg fileManager:_fileManager];
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *msg = [_dataArray objectAtIndex:indexPath.row];
    /// 创建对方文件夹
    NSString *foreignDir = [ws getCreateForeignDirPath:ws.wJid.userDir foreignUser:msg.username];
    [[ws messagesList] removeAllObjects];
    [ws getMsgList:msg.username page:1 srmsgCount:0 foreignDir:foreignDir];
    
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.foreign_user = msg.username;
    chatVC.m_emojiArray = _m_emojiArray;
    chatVC.m_emojiDictionary = _m_emojiDictionary;
    chatVC.senderVoiceArray = _senderVoiceArray;
    chatVC.receiverVoiceArray = _receiverVoiceArray;
    chatVC.setting = _setting;
    chatVC.hideBgView = _hideBgView;
    chatVC.recordView = _recordView;
    chatVC.fileManager = _fileManager;
    chatVC.foreignDir = foreignDir;
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
