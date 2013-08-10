//
//  ALFileSize.m
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALFileSize.h"

size_t filesize(char *filepath) 
{
    // pointer to file at path
    size_t size;
    FILE *file;
    
    // To properly determine the size, we open it in binary mode.
    file = fopen(filepath, "rb");
    
    if(file != NULL)
    {
        // Error while seeking to end of file?
        if(fseek(file, 0, SEEK_END)) {
            rewind(file);
            fclose(file);
            return -1;
        }
        
        size = ftell(file);
        // Close file and return the file size.
        rewind(file);
        fclose(file);
        return size;
    } 
    
    // In case we encounter an error.
    return -1;
}
