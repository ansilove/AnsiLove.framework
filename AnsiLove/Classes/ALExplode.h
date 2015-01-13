//
//  ALExplode.h
//  AnsiLove.framework
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

// Converts a delimited string into a string array. Other than PHP's
// explode() function it will return an integer of strings found. I
// consider this as much better approach as you can access the strings
// via array pointer and you don't have to determine how many string
// instances were stored overall as this is what you're getting.

int32_t explode(char ***arr_ptr, char delimiter, char *str);
