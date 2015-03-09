//
//  t_base.h
//  Server
//
//  Created by tw001 on 14/11/5.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#ifndef Server_t_base_h
#define Server_t_base_h

#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <string.h>
#include <sys/time.h>

#define DEBUG_ON 1

#define TTRUE			(1)
#define TFALSE			(0)

// 函数返回值
enum
{
    ERR_NEXT	= -2,	// 可以重试的错误
    ERR 		= -1,	// 不可恢复的错误
    OK 			= 0,    // 正确返回
    OK_IDLE,			// 不需要执行核心业务，空闲状态
    OK_WAIT,			// 缺乏某种条件，未执行核心业务，等待重试
    OK_FINISH,			// 完成了该类处理，可以进入下一类处理
};

#define INVALID_SOCKET 		(-1)            // 无效的网络套接字
#define NO_USE(x)			((void *)(x))

#define		CRE 	"^M^[[K"
#define     NORMAL	"[0;39m"
#define		RED		"[1;31m"
#define		GREEN	"[1;32m"
#define		YELLOW	"[1;33m"
#define		BLUE	"[1;34m"
#define		MAGENTA	"[1;35m"
#define		CYAN	"[1;36m"
#define		WHITE	"[1;37m"

#ifdef DEBUG_ON
int dbgprintf(unsigned int handle, char* pszfmt, ...);
void hexprint(const char* _string, int _len);

#define dbg() dbgprintf(7, "%s,%s,LINE:%d err", __FILE__, __func__, __LINE__)
#define dbgx(i) dbgprintf(7, "%s,%s,%d "#i" = 0x%x", __FILE__, __func__, __LINE__, i)
#define dbgl(l) dbgprintf(7, "%s,%s,%d "#l" = %ld", __FILE__, __func__, __LINE__, l)
#define dbgll(ll) dbgprintf(7, "%s,%s,%d "#ll" = %lld", __FILE__, __func__, __LINE__, ll)
#define dbgint(i) dbgprintf(7, "%s,%s,%d "#i" = %d", __FILE__, __func__, __LINE__, i)
#define dbgstr(s) dbgprintf(7, "%s,%s,%d "#s" = %s", __FILE__, __func__, __LINE__, s)


#define func_info()\
do{\
    time_t tUniqueName = time(NULL);\
    printf(BLUE"---------------------------------------------------------------------------------\r\n"NORMAL);\
    printf(BLUE"%s"NORMAL, ctime(&tUniqueName));\
    printf(BLUE"PID = %d, PPID = %d, Thread ID = %lu, Thread Name: %s\r\n"NORMAL, getpid(),getppid(), pthread_self(), __func__);\
    printf(BLUE"Created at line %d, file %s\r\n"NORMAL, __LINE__, __FILE__);\
    printf(BLUE"=================================================================================\r\n\r\n"NORMAL);\
}while(0)

#define func_exit()\
do{\
    time_t tUniqueName = time(NULL);\
    printf(RED"---------------------------------------------------------------------------------\r\n"NORMAL);\
    printf(RED"%s"NORMAL, ctime(&tUniqueName));\
    printf(RED"PID = %d, PPID = %d, Thread ID = %lu, Thread Name: %s\r\n"NORMAL, getpid(),getppid(), pthread_self(), __func__);\
    printf(RED"Exit at line %d, file %s\r\n"NORMAL, __LINE__, __FILE__);\
    printf(RED"=================================================================================\r\n\r\n"NORMAL);\
}while(0)


#else
#define dbgprintf(a,b,...)
#define func_info()
#define func_exit()
#define hexprint(a,...)
#define dbgint(i)
#define dbgx(i)
#define dbgl(l)
#define dbgll(ll)
#define dbgstr(s)
#define dbg()
#endif


#endif
