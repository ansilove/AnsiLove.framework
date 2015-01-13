//
//  ALAnsiLove.h
//  AnsiLove.framework
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <gd.h>
#import "ALConfig.h"
#import "ALBinFonts.h"
#import "ALSubStr.h"
#import "ALExplode.h"
#import "ALFileSize.h"
#import "ALSauceMachine.h"

#if !defined(MIN)
#define MIN(A,B) ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

// prototypes
void alDrawChar(gdImagePtr im, const unsigned char *font_data, int32_t int_bits, 
                int32_t font_size_x, int32_t font_size_y, int32_t position_x, int32_t position_y, 
                int32_t color_background, int32_t color_foreground, unsigned char character);

void alAnsiLoader(char *input, char output[], char retinaout[], char font[], char bits[], char icecolors[], char *fext, bool createRetinaRep);
void alPcBoardLoader(char *input, char output[], char retinaout[], char font[], char bits[], bool createRetinaRep);
void alBinaryLoader(char *input, char output[], char retinaout[], char columns[], char font[], char bits[], char icecolors[], bool createRetinaRep);
void alArtworxLoader(char *input, char output[], char retinaout[], char bits[], bool createRetinaRep);
void alIcedrawLoader(char *input, char output[], char retinaout[], char bits[], bool fileHasSAUCE, bool createRetinaRep);
void alTundraLoader(char *input, char output[], char retinaout[], char font[], char bits[], bool fileHasSAUCE, bool createRetinaRep);
void alXbinLoader(char *input, char output[], char retinaout[], char bits[], bool createRetinaRep);

// helper functions
char *str_replace(const char *string, const char *substr, const char *replacement);

// character structures
struct pcbChar {
    int32_t position_x;
    int32_t position_y;
    int32_t color_background;
    int32_t color_foreground;
    int32_t current_character;
};

struct ansiChar {
    int32_t position_x;
    int32_t position_y;
    int32_t color_background;
    int32_t color_foreground;
    int32_t current_character;
    bool bold;
    bool italics;
    bool underline;
};
