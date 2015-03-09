//
//  WSocket.h
//  WeiWei
//
//  Created by tw001 on 14/11/18.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "im_client_service.h"
#import "MsgObject.h"
#import "WJID.h"
#import "DBConnect.h"

#define kConnectFailue -1
#define kPageSize 10
#define kBetweenTime 300
#define kPageSize 10
#define kDefaultNull                @"(null)"

#define kMsgChatTableName           @"msgchat"
#define kUserLogin                  @"user login"
#define kUserLoginOut               @"user loginout"
#define kMsgListMessage             @"chat msg list"
#define kMsgChatHideKeyBoard        @"msg chat hide keyboard"
#define kFromDeleteToPopChat        @"from delete to pop chat"
#define kConnectState               @"connect state"

enum {
    ConnectStateFailue = -2,
    ConnectStateSuccess = 1,
    ConnectStateConnecting = 2
}ConnectState;

@interface WSocket : NSObject

@property (nonatomic, assign) int isConnect;
@property (nonatomic, strong) WJID *wJid;
@property (nonatomic, strong) NSMutableArray *messagesList;
@property (nonatomic, assign) int loginCount;

+(WSocket *)shareWSocket;

#pragma mark - 实例方法
/// 获得表情数组
- (NSArray *)getEmojiArray;

/// 获得表情字典
- (NSMutableDictionary *)getEmojiDictionary;

/// 获得缓存文件夹路径
- (NSString *)getCachesDirPath:(NSString *)cachesDir;

/// 创建对方文件夹
- (NSString *)getCreateForeignDirPath:(NSString *)cachesDir foreignUser:(NSString *)foreignUser;

// MD5加密 32位加密（小写）
- (NSString *)lower32_MD5:(NSString *)str;

// md5 16位加密 （大写）
- (NSString *)upper16_MD5:(NSString *)str;

/// 时间戳转时间
- (NSString *)turnTime:(NSString *)timestamp nowtime:(long)nowtime isShowHM:(BOOL)isShowHM;

#pragma mark - 建表
/// 建表
- (void)createTables;

#pragma mark - 登录、注册、重置密码
/// 登录
- (int)logining:(NSString *)username passwd:(NSString *)passwd isRetry:(BOOL)isRetry;

#pragma mark - 聊天
/// 获得消息列表
- (int)getMsgList:(NSString *)foreignUser
             page:(int)page
       srmsgCount:(int)srmsgCount
       foreignDir:foreignDir;

/// 获得消息页数
- (int)getMsgPageCount:(NSString *)foreignUser;

/// 加时间
- (void)addNowTime:(long)timestamp;

/// 向其他用户发送数据 mType 1-文本 3-图片 4-语音
- (int)sendMsgToUser:(NSString *)foreignUser
               mType:(int)mType
              msgStr:(NSString *)msgStr;

/// 发送图片
- (void)sendImage:(NSString *)foreignUser
            image:(UIImage *)image
       foreignDir:(NSString *)foreignDir;

/// 发送失败的消息
- (int)resendFailueMsg:(MsgObject *)msgObjt
            foreignDir:(NSString *)foreignDir;

@end
