//
//  t_time.c
//  Client
//
//  Created by tw001 on 14/11/6.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#include "t_time.h"
#include "t_base.h"

#include <time.h>
#include <sys/time.h>

unsigned int time_GetSecSince1970()
{
    return (int)time(NULL);
}

unsigned int time_GetCurrentMs()
{
    struct timeval dwNow;
    gettimeofday(&dwNow, NULL);
    return dwNow.tv_usec;
}