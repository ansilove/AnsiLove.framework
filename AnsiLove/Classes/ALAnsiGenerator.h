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

// Affecting supported output formats.
@property (nonatomic, assign) BOOL generatesRetinaFile;
@property (nonatomic, assign) BOOL mergesOutputToTIFF;

// Affecting implemented rendering options.
@property (nonatomic, assign) BOOL usesDefaultFont;
@property (nonatomic, assign) BOOL usesDefaultBits;
@property (nonatomic, assign) BOOL usesDefaultColumns;

@property (nonatomic, strong) NSString *ansi_inputFile;
@property (nonatomic, strong) NSString *ansi_outputFile;
@property (nonatomic, strong) NSString *ansi_font;
@property (nonatomic, strong) NSString *ansi_bits;
@property (nonatomic, assign) BOOL      ansi_iceColors;
@property (nonatomic, strong) NSString *ansi_columns;

// One method to make the magic happen.
- (void)renderAnsiFile:(NSString *)inputFile
            outputFile:(NSString *)outputFile
                  font:(NSString *)font
                  bits:(NSString *)bits
             iceColors:(BOOL      )iceColors
               columns:(NSString *)columns
                retina:(BOOL      )generateRetina
                  TIFF:(BOOL      )mergeToTIFF;

@end
