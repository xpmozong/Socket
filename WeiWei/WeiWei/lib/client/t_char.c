//
//  t_char.c
//  Client
//
//  Created by tw001 on 14/11/6.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#include "t_char.h"
#include "t_base.h"

int char_ncopy(char *_pcDst, const char *_pcSrc, int _iMaxLen)
{
    if(NULL == _pcDst)
    {
        dbg();
        return ERR;
    }
    
    if(NULL == _pcSrc || _iMaxLen < 1)
    {
        _pcDst[0] = 0;
        
        return 0;
    }
    
    int i = 0;
    for(i = 0; i < _iMaxLen - 1; i++)
    {
        if(_pcSrc[i])
        {
            _pcDst[i] = _pcSrc[i];
        }
        else
        {
            break;
        }
    }
    
    _pcDst[i] = '\0';
    
    return i;
}