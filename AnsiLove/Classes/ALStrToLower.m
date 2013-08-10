//
//  ALStrToLower.m
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALStrToLower.h"

char *strtolower(char *str)
{
    char *p;
    for (p = str; *p != '\0'; ++p) 
    {
        *p = tolower(*p);
    }
    return str;
}
