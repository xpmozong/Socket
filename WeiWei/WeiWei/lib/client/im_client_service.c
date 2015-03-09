//
//  im_client_service.c
//  Client
//
//  Created by 许 萍 on 14/11/12.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#include "im_client_service.h"
#include <math.h>

pthread_mutex_t mut;

void *tsk_im_client()
{
    while(1)
    {
        pthread_mutex_lock(&mut);
        int need_recv = 102400;
        char p_recv[need_recv];
        im_header *i_header;
        i_header = (im_header *)p_recv;
        int len = (int)recv(client_sockfd, p_recv, need_recv, 0);
        dbgint(i_header->m_im_fun);
        dbgint(len);
        if (len > 0) {
            switch (i_header->m_im_fun) {
                case IM_FUN_LOGIN:
                {
                    im_pkt_recv_login_regist *pkt_recv;
                    pkt_recv = (im_pkt_recv_login_regist *)p_recv;
                    c_im_state(pkt_recv->c_im_header.m_im_fun, pkt_recv->login_regist.m_state);
                    break;
                }
                case IM_FUN_REGIST:
                {
                    im_pkt_recv_login_regist *pkt_recv;
                    pkt_recv = (im_pkt_recv_login_regist *)p_recv;
                    c_im_state(pkt_recv->c_im_header.m_im_fun, pkt_recv->login_regist.m_state);
                    break;
                }
                case IM_FUN_LOGOUT:
                {
                    im_pkt_recv_login_regist *pkt_recv;
                    pkt_recv = (im_pkt_recv_login_regist *)p_recv;
                    c_im_state(pkt_recv->c_im_header.m_im_fun, pkt_recv->login_regist.m_state);
                    break;
                }
                case IM_FUN_SEND_MSG:
                {
                    im_pkt_recv_msg_data *pkt_return;
                    pkt_return = (im_pkt_recv_msg_data *)p_recv;
                    
                    c_im_return(i_header->m_im_fun,
                                pkt_return->recv_msg_data.m_user_id,
                                pkt_return->recv_msg_data.m_serial_id,
                                pkt_return->recv_msg_data.m_state);
                    break;
                }
                case IM_FUN_RECV_MSG:
                {
                    im_pkt_msg_data *pkt_recv;
                    pkt_recv = (im_pkt_msg_data *)p_recv;
                    
                    c_im_recv(i_header->m_im_fun,
                              pkt_recv->msg_data.m_type,
                              pkt_recv->msg_data.m_user_id,
                              pkt_recv->msg_data.m_pdata,
                              pkt_recv->msg_data.m_serial_id);
                    
                    im_client_confirm_msg(IM_FUN_CONFIRM_RECV_MSG,
                                          pkt_recv->msg_data.m_user_id,
                                          pkt_recv->msg_data.m_serial_id);
                    break;
                }
                case IM_FUN_CONNECT:
                    c_im_state(IM_FUN_CONNECT, IM_STATE_CLOSE);
                    break;
                default:
                    break;
            }
        }else{
            im_disconnect();
            break;
        }
        
        pthread_mutex_unlock(&mut);
    }
    
    pthread_exit(NULL);
}

/// 初始化
int im_init(const char *server_ip,
            const int server_port,
            C_IM_RETURN im_return,
            C_IM_RECV im_recv,
            C_IM_STATE im_state)
{
    c_im_return = im_return;
    c_im_recv = im_recv;
    c_im_state = im_state;
    
    client_sockfd = IM_STATE_CLOSE;
    memset(&remote_addr, 0, sizeof(remote_addr)); //数据初始化--清零
    remote_addr.sin_family = AF_INET; //设置为IP通信
    remote_addr.sin_addr.s_addr = inet_addr(server_ip);//服务器IP地址
    remote_addr.sin_port = htons(server_port); //服务器端口号
    
    return 0;
}

/// 连接服务器
int im_connect(void)
{
    // 创建客户端套接字--IPv4协议，面向连接通信，TCP协议
    client_sockfd = socket(PF_INET, SOCK_STREAM, 0);
    dbgint(client_sockfd);
    
    // 将套接字绑定到服务器的网络地址上
    int con = connect(client_sockfd, (struct sockaddr *)&remote_addr,sizeof(struct sockaddr));
    dbgint(con);
    
    im_create_pthread();
    
    return con;
}

/// 创建线程
int im_create_pthread(void)
{
    pth_client_service = NULL;
    
    int iRet = pthread_create(&pth_client_service, NULL, tsk_im_client, NULL);
    if(iRet)
    {
        dbg();
        return ERR;
    }
    
    return iRet;
}

/// 断开服务器
int im_disconnect(void)
{
    c_im_state(IM_FUN_CONNECT, IM_STATE_CLOSE);
    
    // 关闭套接字
    close(client_sockfd);
    
    int con = im_connect();
    c_im_state(IM_FUN_CONNECT, con);
    
    return con;
}

/// 获得发送包id
char *im_get_serial_id(char *serial_id)
{
//    return ((int)time_GetSecSince1970() - 1418021259) * 1000 + (int)time_GetCurrentMs();
    
    sprintf(serial_id, "%d_%d", (int)time_GetSecSince1970(), (int)time_GetCurrentMs());
    
    return serial_id;
}

/// 登录
int im_login(const char *user_id, const char *user_pwd)
{
    int userLen = (int)strlen(user_id);
    int pwdLen = (int)strlen(user_pwd);
    if (userLen > USER_ID_LENGTH) {
        return IM_FAILUE_SIGN_USER_BEYOND;
    }
    if (pwdLen > USER_PWD_LENGTH) {
        return IM_FAILUE_SIGN_PWD_BEYOND;
    }
    
    int need_send = sizeof(im_pkt_send_login_regist);
    char p_send[need_send];
    im_pkt_send_login_regist *pkt_send_data;
    pkt_send_data = (im_pkt_send_login_regist *)p_send;
    pkt_send_data->c_im_header.m_im_fun = IM_FUN_LOGIN;
    strcpy(pkt_send_data->login_regist.m_user_id, user_id);
    strcpy(pkt_send_data->login_regist.m_user_pwd, user_pwd);

    int len = (int)send(client_sockfd, p_send, need_send, 0);
    
    return len;
}

/// 发送消息
int im_send_user_data(const char *serial_id,
                      const char *user_id,
                      const char *p_data,
                      const int pdata_length,
                      const int m_type)
{
    int userLen = (int)strlen(user_id);
    if (userLen > USER_ID_LENGTH) {
        return IM_FAILUE_SIGN_USER_BEYOND;
    }
    int need_send = pdata_length + sizeof(im_pkt_msg_data);
    char p_send[need_send];
    im_pkt_msg_data *pkt_send_data;
    pkt_send_data = (im_pkt_msg_data *)p_send;
    pkt_send_data->c_im_header.m_im_fun = IM_FUN_SEND_MSG;
    pkt_send_data->msg_data.m_type = m_type;
    strcpy(pkt_send_data->msg_data.m_serial_id, serial_id);
    strcpy(pkt_send_data->msg_data.m_user_id, user_id);
    strcpy(pkt_send_data->msg_data.m_pdata, p_data);
    int len = (int)send(client_sockfd, pkt_send_data, need_send, 0);

    return len;
}

/// 发送图片
int im_send_user_image(const char *serial_id,
                       const char *user_id,
                       char *p_data,
                       const int pdata_length)
{
    int userLen = (int)strlen(user_id);
    if (userLen > USER_ID_LENGTH) {
        return IM_FAILUE_SIGN_USER_BEYOND;
    }
    
    g_file_serial = 0;
    int i_send = 0;
    
    while (1) {
        i_send = TMIN(g_file_packet, pdata_length - (g_file_serial * g_file_packet));
        if (i_send > 0) {
            int send_len = send_file_data(IM_DATA_TYPE_JPEG, serial_id, user_id, p_data + (g_file_serial * g_file_packet), i_send);
            if (send_len < 0) {
                dbg();
                return ERR;
            }
            g_file_serial++;
        }else{
            send_file_finash();
            break;
        }
    }
    
    return 0;
}

/// 客户端确认接收到消息
int im_client_confirm_msg(const int m_fun,
                          const char *user_id,
                          const char *serial_id)
{
    int need_send = sizeof(im_pkt_recv_msg_data);
    char p_send[need_send];
    im_pkt_recv_msg_data *pkt_recv_data;
    pkt_recv_data = (im_pkt_recv_msg_data *)p_send;
    pkt_recv_data->c_im_header.m_im_fun = m_fun;
    strcpy(pkt_recv_data->recv_msg_data.m_user_id, user_id);
    strcpy(pkt_recv_data->recv_msg_data.m_serial_id, serial_id);
    int len = (int)send(client_sockfd, p_send, need_send, 0);
    
    return len;
}


/// 发送文件
int send_file_data(const int file_type,
                   const char *serial_id,
                   const char *user_id,
                   char *pc_data,
                   int i_len)
{
    int pkt_size = (int)sizeof(im_pkt_msg_data);
    int need_send = i_len + pkt_size;
    
    char p_send[need_send];
    bzero(p_send, need_send);
    
    im_pkt_msg_data *pkt_send_data;
    pkt_send_data = (im_pkt_msg_data *)p_send;
    pkt_send_data->c_im_header.m_im_fun = IM_FUN_SEND_MSG;
    pkt_send_data->msg_data.m_type = IM_DATA_TYPE_JPEG;
    strcpy(pkt_send_data->msg_data.m_serial_id, serial_id);
    strcpy(pkt_send_data->msg_data.m_user_id, user_id);
    bzero(pkt_send_data->msg_data.m_pdata, i_len);
    memcpy(pkt_send_data->msg_data.m_pdata, pc_data, i_len);
    int len = send(client_sockfd, pkt_send_data, need_send, 0);
    bzero(p_send, need_send);

    return len;
}

/// 发送文件结束
void send_file_finash(void)
{
    printf("发送文件结束\n");
}





