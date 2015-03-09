//
//  ChatViewController.h
//  BDMapDemo
//
//  Created by tw001 on 14-9-23.
//  Copyright (c) 2014年 ESX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "IMRefrashViewController.h"
#import "LeftTextTableViewCell.h"
#import "LeftImageTableViewCell.h"
#import "LeftVoiceTableViewCell.h"
#import "RightTextTableViewCell.h"
#import "RightImageTableViewCell.h"
#import "RightVoiceTableViewCell.h"
#import "TipTableViewCell.h"
#import "TimeTableViewCell.h"
#import "ExpressionView.h"
#import "MoreView.h"
#import "RecordView.h"
#import "MBProgressHUD.h"

#define kDefaultHeight          9.209999
#define kWriteMsgViewHeight     50.0f
#define kMsgTextViewHeight      35.0f
#define kMsgTextViewFontSize    16.0f
#define kMsgTextViewMaxHeight   100.0f
#define kButtonHeight           35.0f
#define kWriteViewSubTop        7.0f
#define kButtonTop              7.5f
#define kVoiceTime              60
#define kPressString            @"按住 说话"
#define kLoosenString           @"松开 结束"

@interface ChatViewController : IMRefrashViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, ExpressionDelegate, MoreViewDelegate, LeftTextTableViewCellDelegate, LeftImageTableViewCellDelegate, LeftVoiceTableViewCellDelegate, RightTextTableViewCellDelegate, RightImageTableViewCellDelegate, RightVoiceTableViewCellDelegate, UIActionSheetDelegate, MBProgressHUDDelegate, AVAudioPlayerDelegate, M80AttributedLabelDelegate, UIGestureRecognizerDelegate, TipTableViewCellDelegate>

@property (assign, nonatomic) float             navHeight;
@property (strong, nonatomic) NSString          *navTitle;
@property (strong, nonatomic) UILabel           *titleLabel;

@property (strong, nonatomic) NSString          *local_user;
@property (strong, nonatomic) NSString          *local_head_portrait;
@property (strong, nonatomic) NSString          *foreign_user;
@property (strong, nonatomic) NSString          *foreign_nickname;
@property (strong, nonatomic) NSString          *foreign_head_portrait;
@property (strong, nonatomic) UIImage           *localAvatar;
@property (strong, nonatomic) UIImage           *foreignAvatar;
@property (assign, nonatomic) float             oldHeight;
@property (assign, nonatomic) float             keyboardHeight;
@property (strong, nonatomic) NSString          *localUserImgPath;
@property (strong, nonatomic) NSString          *foreignUserImgPath;
@property (strong, nonatomic) NSString          *foreignDir;

@property (assign, nonatomic) int               page;
@property (assign, nonatomic) int               pageCount;
@property (assign, nonatomic) int               srmsgCount;
@property (assign, nonatomic) int               timingCount;    // 计时
@property (assign, nonatomic) int               prevCount;
@property (assign, nonatomic) int               offsetCount;

@property (strong, nonatomic) UIView            *writeMsgView;
@property (strong, nonatomic) UITextView        *msgTextView;
@property (strong, nonatomic) UIButton          *voiceBtn;
@property (strong, nonatomic) UIButton          *recordBtn;
@property (strong, nonatomic) UIButton          *expressionBtn;
@property (strong, nonatomic) UIButton          *moreBtn;

@property (strong, nonatomic) ExpressionView    *eView;
@property (strong, nonatomic) MoreView          *mView;

@property (strong, nonatomic) NSArray           *m_emojiArray;
@property (strong, nonatomic) NSMutableDictionary *m_emojiDictionary;
@property (strong, nonatomic) UIView            *hideBgView;
@property (strong, nonatomic) RecordView        *recordView;

@property (strong, nonatomic) AVAudioPlayer     *avPlay;
@property (strong, nonatomic) AVAudioRecorder   *recorder;
@property (strong, nonatomic) NSTimer           *timer;
@property (strong, nonatomic) NSURL             *urlPlay;
@property (strong, nonatomic) NSDictionary      *setting;
@property (strong, nonatomic) NSString          *wavFilePath;
@property (strong, nonatomic) NSString          *amrFilePath;
@property (strong, nonatomic) NSString          *wavName;
@property (strong, nonatomic) NSString          *amrName;
@property (strong, nonatomic) NSFileManager     *fileManager;

@property (strong, nonatomic) NSArray           *senderVoiceArray;
@property (strong, nonatomic) NSArray           *receiverVoiceArray;
@property (strong, nonatomic) NSIndexPath       *prevIndexPath;
@property (assign, nonatomic) int               playVoiceNowIndex;

@property (assign, nonatomic) int               rowIndex;
@property (assign, nonatomic) BOOL              isShowMenu;
@property (strong, nonatomic) MBProgressHUD     *HUD;

@property (strong, nonatomic) NSString          *emailStr;
@property (strong, nonatomic) NSString          *phoneStr;

@property (strong, nonatomic) NSTimer           *uploadTimer;   // 监听图片上传进度
@property (strong, nonatomic) NSTimer           *downloadTimer; // 监听图片下载进度

@property (assign, nonatomic) float             textViewHeight; // 文本框里有字时的高度
@property (assign, nonatomic) BOOL              isKeyBoadShow;

@property (strong, nonatomic) dispatch_queue_t  sendQueue;
@property (strong, nonatomic) dispatch_queue_t  getMsgQueue;

@property (strong, nonatomic) MsgObject         *voiceTimeMsgObj;   // 录音上一级添加的时间
@property (strong, nonatomic) MsgObject         *voiceMsgObj;       // 正在录音的对象
@property (strong, nonatomic) NSIndexPath       *voiceIndexPath;    // 正在录音的某一行


@end
