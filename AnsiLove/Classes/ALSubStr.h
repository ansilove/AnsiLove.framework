//
//  ALSubStr.h
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

// Returns portion of a string specified by start and length parameters.

char *substr(char *str, size_t begin, size_t len);
