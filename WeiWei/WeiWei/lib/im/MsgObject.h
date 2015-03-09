//
//  MsgObject.h
//  Ershixiong
//
//  Created by tw001 on 14-8-29.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M80AttributedLabel.h"

enum MsgType {
    MsgText = 1,
    MsgTime = 2,
    MsgImage = 3,
    MsgVoice = 4,
    MsgSystemTip = 5,
    MsgEmpty = 6
};

enum MsgChatRefrashType {
    MsgChatRefrashTypePageNoFinish  = 0,    // 分页没结束
    MsgChatRefrashTypePageIsFinish  = 1,    // 分页已结束
    MsgChatRefrashTypeSendSuccess   = 2,    // 发送消息添加
    MsgChatRefrashTypeReciveMsg     = 3,    // 接收消息添加
    MsgChatRefrashTypeNormal        = 4,    // 普通刷新表
    MsgChatRefrashTypeDeleteMsg     = 5,    // 删除聊天消息
    MsgChatRefrashTypeSendFailue    = 6,    // 发送消息失败
    MsgChatRefrashTypeSendVoice     = 7,    // 发送语音
};

@interface MsgObject : NSObject

@property (nonatomic, assign) int mid;                  // 消息id
@property (nonatomic, strong) NSString *date;           // 日期时间
@property (nonatomic, assign) long mtimestamp;          // 日期时间戳
@property (nonatomic, assign) BOOL direction;           // 消失是发出 还是 接收
@property (nonatomic, strong) NSString *localUser;      // 本地使用用户
@property (nonatomic, strong) NSString *foreignUser;    // 外来消息用户
@property (nonatomic, strong) NSString *messageStr;     // 消息
@property (nonatomic, assign) int delivery_status;      // 发送状态 1-发送中 2-发送成功 3-发送失败 4-是否可点
@property (nonatomic, strong) NSString *file_url;       // 文件目录
@property (nonatomic, assign) BOOL isread;              // 该消息是否已读
@property (nonatomic, assign) int m_type;               // 消息类型 1-文本 2-时间 3-图片 4-语音 5-系统消息
@property (nonatomic, assign) int voice_time;           // 语音时间
@property (nonatomic, assign) float f_voice_time;       // 录音时间
@property (nonatomic, copy) NSString *serial_id;        // 发送消息，返回的发送码
@property (nonatomic, assign) BOOL voice_read;          // 语音是否已读

@property (nonatomic, strong) NSString *foreignNickname;// 对方昵称
@property (nonatomic, strong) NSString *foreignAvatar;  // 对方头像

@property (nonatomic, assign) int upload_progress;      // 上传进度
@property (nonatomic, assign) int download_progress;    // 下载进度

@property (nonatomic, copy) NSString *imgPath;          // 图片的全路径

@property (nonatomic, assign) int resend_count;         // 记录重发的次数
@property (nonatomic, assign) int send_count;

@property (nonatomic, strong) M80AttributedLabel *msgLabel;
@property (nonatomic, assign) float msgRowHeight;

@end
