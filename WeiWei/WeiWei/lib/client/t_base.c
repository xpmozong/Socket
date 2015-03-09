//
//  t_base.c
//  Server
//
//  Created by tw001 on 14/11/5.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#include "t_base.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>

#ifdef DEBUG_ON
int dbgprintf(unsigned int handle, char* pszfmt, ...)
{
    
    va_list struAp;
    time_t now;
    struct tm tm_now;
    int ret;
    char* format= NULL;
    
    if(pszfmt == NULL)
    {
        return -1;
    }
    
    format = calloc(strlen(pszfmt) + 3, 1);
    
    if(format == NULL)
    {
        return -2;
    }
    
    strcpy(format,pszfmt);
    
    if(format[strlen(pszfmt) - 1]=='\n')
    {
        format[strlen(pszfmt)] = format[strlen(pszfmt) - 2] == '\r' ?  '\0' : '\r';
    }
    else if(format[strlen(pszfmt) - 1] == '\r')
    {
        format[strlen(pszfmt)] = format[strlen(pszfmt)-2]=='\n' ? '\0' : '\n';
    }
    else
    {
        format[strlen(pszfmt)] = '\r';
        format[strlen(pszfmt) + 1] = '\n';
    }
    
    now = time(&now);
    
#if 0 //加入时区后，时间值差时区值
    ptm_now = gmtime(&now);
#else
    localtime_r(&now, &tm_now);
#endif
    
    switch (handle) {
        case 0:
        {
            printf(RED"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 1:
        {
            printf(GREEN"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 2:
        {
            printf(YELLOW"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 3:
        {
            printf(BLUE"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 4:
        {
            printf(MAGENTA"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 5:
        {
            printf(CYAN"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 6:
        {
            printf(WHITE"[%04d/%02d/%02d %02d:%02d:%02d]"NORMAL,
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        case 7:
        {
            printf("[%04d/%02d/%02d %02d:%02d:%02d]",
                   tm_now.tm_year + 1900,
                   tm_now.tm_mon + 1,
                   tm_now.tm_mday,
                   (tm_now.tm_hour) % 24,
                   tm_now.tm_min,
                   tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vprintf(format, struAp);
            va_end(struAp);
            break;
        }
        default:
        {
            FILE *file;
            file = fopen("printf.txt", "a+");
            
            fprintf(file,"[%04d/%02d/%02d %02d:%02d:%02d]",
                    tm_now.tm_year + 1900,
                    tm_now.tm_mon + 1,
                    tm_now.tm_mday,
                    (tm_now.tm_hour) % 24,
                    tm_now.tm_min,
                    tm_now.tm_sec);
            
            va_start(struAp, pszfmt);
            ret = vfprintf(file, format, struAp);
            va_end(struAp);
            fclose(file);
            break;
        }
    }
    
    free(format);
    return ret;
}

void hexprint(const char* _string, int _len)
{
    int i = 0;
    
    if (NULL == _string || _len <= 0)
    {
        return;
    }
    
    for (i = 0; i < _len; i++)
    {
        printf("%02x%s", _string[i], (i + 1) % 16 == 0 ? "\n" : " ");
    }
    
    printf("\n");
    
    return;
}


#endif
