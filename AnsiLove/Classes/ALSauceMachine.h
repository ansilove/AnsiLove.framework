//
//  ALSauceMachine.h
//  AnsiLove.framework
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//
//  Based on libsauce. Copyright (c) 2010, Brian Cassidy. 
//

#import <Foundation/Foundation.h>

#define RECORD_SIZE  128
#define COMMENT_SIZE 64
#define SAUCE_ID     "SAUCE"
#define COMMENT_ID   "COMNT"

typedef struct {
    char             id[6];
    char             version[3];
    char             title[36];
    char             author[21];
    char             group[21];
    char             date[9];
    int              filesize;
    unsigned char    datatype;
    unsigned char    filetype;
    unsigned short   tinfo1;
    unsigned short   tinfo2;
    unsigned short   tinfo3;
    unsigned short   tinfo4;
    unsigned char    comments;
    unsigned char    flags;
    char             filler[23];
    char             **comment_lines;
} sauce;

@interface ALSauceMachine : NSObject

// bridge methods (Cocoa)
+ (void)readSauceRecordFromFile:(NSString *)inputFile;

// class internal (ye good olde C)
sauce     *sauceReadFileName(char *fileName);
sauce     *sauceReadFile(FILE *file);
void      readRecord(FILE *file, sauce *record);
void      readComments(FILE *file, char **comment_lines, NSInteger comments);
NSInteger sauceWriteFileName(char *fileName, sauce *record);
NSInteger sauceWriteFile(FILE *file, sauce *record);
NSInteger writeRecord(FILE *file, sauce *record);
NSInteger sauceRemoveFileName(char *fileName);
NSInteger sauceRemoveFile(FILE *file);

@end
