//
//  ALAnsiGenerator.h
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>

@interface ALAnsiGenerator : NSObject

// Creates single PNG image from ANSi source.
+ (void)ansiFileToPNG:(NSString *)inputFile
           outputFile:(NSString *)outputFile
                 font:(NSString *)font
                 bits:(NSString *)bits
            iceColors:(NSString *)iceColors
              columns:(NSString *)columns;

// Creates regular and @2x Retina PNG image from ANSi source.
+ (void)ansiFileToRetinaPNG:(NSString *)inputFile
                 outputFile:(NSString *)outputFile
                       font:(NSString *)font
                       bits:(NSString *)bits
                  iceColors:(NSString *)iceColors
                    columns:(NSString *)columns;

// Creates single TIFF image from ANSi source, all sizes embedded.
+ (void)ansiFileToRetinaTIFF:(NSString *)inputFile
                  outputFile:(NSString *)outputFile
                        font:(NSString *)font
                        bits:(NSString *)bits
                   iceColors:(NSString *)iceColors
                     columns:(NSString *)columns;

@end
