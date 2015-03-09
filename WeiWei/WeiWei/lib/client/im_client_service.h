//
//  im_client_service.h
//  Server
//
//  Created by tw001 on 14/11/5.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#ifndef Server_im_client_service_h
#define Server_im_client_service_h

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <malloc/malloc.h>
#include "im_pub.h"

/// 客户端套接字
int client_sockfd;

static int g_file_serial = 0;  // 包从0开始
static int g_file_packet = IM_ONE_PACKAGE_SIZE;

/// 服务器端网络地址结构体
struct sockaddr_in remote_addr;

/// 发送消息返回
typedef int (*C_IM_RETURN)(const int m_fun, const char *user_id, const char *serial_id, const int m_state);
static C_IM_RETURN c_im_return;

/// 接收消息
typedef int (*C_IM_RECV)(const int m_fun, const int m_type, const char *user_id, char *pData, const char *serial_id);
static C_IM_RECV c_im_recv;

/// 操作返回
typedef int (*C_IM_STATE)(const int m_fun, const int m_state);
static C_IM_STATE c_im_state;

/// 监听服务器返回线程
pthread_t pth_client_service;

/// 初始化
int im_init(const char *server_ip,
            const int server_port,
            C_IM_RETURN im_return,
            C_IM_RECV im_recv,
            C_IM_STATE im_state);

/// 连接服务器
int im_connect(void);

/// 创建线程
int im_create_pthread(void);

/// 断开服务器
int im_disconnect(void);

/// 获得发送包id
char *im_get_serial_id(char *serial_id);

/// 登录
int im_login(const char *user_id, const char *user_pwd);

/// 发送消息
int im_send_user_data(const char *serial_id,
                      const char *user_id,
                      const char *p_data,
                      const int pdata_length,
                      const int m_type);

/// 发送图片
int im_send_user_image(const char *serial_id,
                       const char *user_id,
                       char *p_data,
                       const int pdata_length);


/// 客户端确认接收到消息
int im_client_confirm_msg(const int m_fun,
                          const char *user_id,
                          const char *serial_id);

/// 发送文件结束
void send_file_finash(void);

/// 发送文件
int send_file_data(const int file_type,
                   const char *serial_id,
                   const char *user_id,
                   char *pc_data,
                   int i_len);

#endif
