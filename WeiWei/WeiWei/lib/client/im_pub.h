//
//  im_pub.h
//  Server
//
//  Created by tw001 on 14/11/5.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#ifndef Server_im_pub_h
#define Server_im_pub_h

#include "t_base.h"
#include "t_char.h"
#include "t_time.h"

#define USER_ID_LENGTH          33
#define USER_PWD_LENGTH         17

#define ERR                     -1
#define IM_ONE_PACKAGE_SIZE		960         // 上传或下载，一包的大小

#define TMIN(X,Y) 	(((X) < (Y)) ? (X) : (Y))

// 帧的功能号
enum
{
    IM_FUN_LOGIN                    = 1,    // 登录
    IM_FUN_REGIST                   = 2,    // 注册
    IM_FUN_SEND_MSG                 = 3,    // 发送消息
    IM_FUN_RECV_MSG                 = 4,    // 接收消息
    IM_FUN_CONFIRM_RECV_MSG         = 5,    // 确认接收到消息
    IM_FUN_CONNECT                  = 6,    // 连接状态
    IM_FUN_LOGOUT                   = 7,    // 退出
    
}im_fun;

// 发送信息的类型
enum
{
    IM_DATA_TYPE_TEXT               = 1,    // 文字
    IM_DATA_TYPE_AMR                = 2,    // 音频
    IM_DATA_TYPE_JPEG               = 3,    // 图片
    IM_DATA_TYPE_SEND_END           = 4,    // 发送结束
}im_data_type;

// 状态
enum
{
    IM_STATE_CLOSE                  = -1,   // 连接已失效，关闭
}im_state;

// 失败功能码
enum
{
    IM_FAILUE_SIGN_TEXT_BEYOND      = -2,   // 内容长度超出
    IM_FAILUE_SIGN_SEND_TEXT        = -3,   // 发送文本失败
    IM_FAILUE_SIGN_USER_BEYOND      = -4,   // 用户长度超出
    IM_FAILUE_SIGN_PWD_BEYOND       = -5,   // 用户密码长度超出
}im_failue_sign;

// 操作失败功能码
enum
{
    IM_OPERATION_FAILURE_LOGIN      = -1,   // 登录失败
}im_operation_failure;

// 服务器返回状态
enum
{
    IM_SERVER_REBACK_FAILUE         = 0,    // 服务器返回失败
    IM_SERVER_REBACK_SUCCESS        = 1,    // 服务器返回成功
    IM_SERVER_REBACK_ING            = 2,    // 服务器返回正在接收中
    IM_SERVER_REBACK_REPEAT_LOGIN   = 3,    // 重复登录 退出
    IM_SERVER_REBACK_LOGINOUT       = 4,    // 正常退出
}im_server_reback_state;

// 登录 - 注册
typedef struct
{
    char m_user_id[USER_ID_LENGTH];         // 目标用户名
    char m_user_pwd[USER_PWD_LENGTH];       // 密码
    
}im_login_regist;

// 登录 - 注册 状态返回
typedef struct
{
    int m_state;                            // 返回状态
}im_recv_login_regist;

// 发送消息 - 接收消息
typedef struct
{
    int m_type;                             // 数据类型
    char m_serial_id[20];                   // 序列号
    char m_user_id[USER_ID_LENGTH];         // 对方用户
    char m_pdata[0];                        // 数据
}im_msg_data;

// 发送消息 - 接收消息 状态返回
typedef struct
{
    int m_state;                            // 返回状态
    char m_serial_id[20];                   // 序列号
    char m_user_id[USER_ID_LENGTH];         // 对方用户
}im_recv_msg_data;

// 请求头
typedef struct
{
    int m_im_fun;                           // 帧的功能号
    
}im_header;

// 登录 - 注册
typedef struct
{
    im_header c_im_header;
    im_login_regist login_regist;
}im_pkt_send_login_regist;

// 登录 - 注册 状态返回 联合体
typedef struct
{
    im_header c_im_header;
    im_recv_login_regist login_regist;
}im_pkt_recv_login_regist;

// 发送消息 - 接收消息 联合体
typedef struct
{
    im_header c_im_header;
    im_msg_data msg_data;
}im_pkt_msg_data;

// 发送消息 - 接收消息 状态返回 联合体
typedef struct
{
    im_header c_im_header;
    im_recv_msg_data recv_msg_data;
}im_pkt_recv_msg_data;


#endif
