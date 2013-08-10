//
//  ALSubStr.m
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALSubStr.h"

char *substr(char *str, size_t begin, size_t len)
{ 
    if (str == 0 || strlen(str) == 0) 
        return 0; 
    
    return strndup(str + begin, len);
} 
