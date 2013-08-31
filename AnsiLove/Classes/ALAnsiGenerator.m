//
//  ALAnsiGenerator.m
//  AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALAnsiGenerator.h"
#import "ALSauceMachine.h"
#import "ALConfig.h"
#import "ALAnsiLove.h"

@implementation ALAnsiGenerator

# pragma mark -
# pragma mark initialization

- (id)init
{
    if (self = [super init]) {}
    return self;
}

# pragma mark -
# pragma mark public

- (void)renderAnsiFile:(NSString *)inputFile
            outputFile:(NSString *)outputFile
                  font:(NSString *)font
                  bits:(NSString *)bits
             iceColors:(BOOL      )iceColors
               columns:(NSString *)columns
                retina:(BOOL      )generateRetina
{
    if (inputFile == nil || [inputFile isEqual: @""]){
        // No inputfile? This means we can't do anything. Get the hell outta here.
        return;
    }
    else {
        self.ansi_inputFile = inputFile;
    }
    
    if (outputFile == nil || [outputFile isEqual: @""]) {
        // In case the user provided no output file / path, just use the file name and
        // path from the inputFile value. AnsiLove adds a PNG suffix automatically.
        outputFile = inputFile;
    }
    
    // Keep our raw ANSi output string in mind. We need it later.
    self.rawOutputString = outputFile;
    
    // We need to keep our promise of adding a PNG suffix automatically.
    self.ansi_outputFile = [NSString stringWithFormat:@"%@.png", outputFile];
    
    // Resolve any tilde in path. The world could explode if we wouldn't do this.
    self.ansi_inputFile = [self.ansi_inputFile stringByExpandingTildeInPath];
    self.ansi_outputFile = [self.ansi_outputFile stringByExpandingTildeInPath];
    
    // Override the default font?
    if (font && ![font isEqualToString:@""]) {
        self.ansi_font = font;
        self.usesDefaultFont = NO;
    }
    else {
        self.usesDefaultFont = YES;
    }
    
    // Override bits?
    if (bits && ![bits isEqualToString:@""]) {
        self.ansi_bits = bits;
        self.usesDefaultBits = NO;
    }
    else {
        self.usesDefaultBits = YES;
    }
    
    // Make use of iCEColors?
    self.ansi_iceColors = NO;
    if (iceColors == YES) {
        self.ansi_iceColors = YES;
    }

    // Columns are generally relevant (and used) for .BIN files only.
    if (columns && ![columns isEqualToString:@""]) {
        self.ansi_columns = columns;
    }
    else {
        self.usesDefaultColumns = YES;
    }
    
    // Define if the Framework should generate a proper @2x retina image additionally.
    self.generatesRetinaFile = NO;
    if (generateRetina == YES) {
        self.generatesRetinaFile = YES;
    }
    
    // We possibly have to set some default values?
    if (self.usesDefaultFont == YES) {
        self.ansi_font = @"80x25";
    }
    if (self.usesDefaultBits == YES) {
        self.ansi_bits = @"8";
    }
    if (self.usesDefaultColumns == YES) {
        self.ansi_columns = @"160";
    }
    
    // SAUCE will be relevant for IDF files, we set that to NO for now.
    self.hasSauceRecord = NO;
    
    // Let's abuse Grand Central Dispatch for asynchronous wonders.
    dispatch_group_t render_group = dispatch_group_create();
    dispatch_queue_t lib_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Fire in order. We know the preceding block is complete before the next block executes.
    dispatch_group_async(render_group, lib_queue, ^{
        [self ALPRIVATE_invokeLibAndCreateOutput];
    });
    
    // Wait until GCD queue operations are finished.
    dispatch_group_wait(render_group, DISPATCH_TIME_FOREVER);
    
    // Finally post rendering finished notification.
    [self ALPRIVATE_postAnsiRenderingFinishedNote];
}

# pragma mark -
# pragma mark private

- (void)ALPRIVATE_postAnsiRenderingFinishedNote
{
    // Post a notification so any listener will know rendering has finished now.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AnsiLoveFinishedRendering" object:self];
}

- (void)ALPRIVATE_invokeLibAndCreateOutput
{
    // Get the current file extension and make it lowercase.
    NSString *currentPathExtension = [self.ansi_inputFile pathExtension];
    NSString *fileExtension = [currentPathExtension lowercaseString];
    
    // Define path for @2x PNG image.
    self.ansi_retinaOutputFile = [NSString stringWithFormat:@"%@@2x.png", self.rawOutputString];
    
    // Create NSString from self.iceColors BOOL value.
    NSString *ansi_iceColorsString = (self.ansi_iceColors) ? @"1" : @"0";
    
    // Parsing and generating output via blocks.
    dispatch_group_t private_render_group = dispatch_group_create();
    dispatch_queue_t private_lib_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Fire private lib methods based on the file extension string.
    if ([fileExtension isEqualToString:@"pcb"])
    {
        // PCBOARD
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alPcBoardLoader((char *)[self.ansi_inputFile UTF8String],
                            (char *)[self.ansi_outputFile UTF8String],
                            (char *)[self.ansi_retinaOutputFile UTF8String],
                            (char *)[self.ansi_font UTF8String],
                            (char *)[self.ansi_bits UTF8String],
                            self.generatesRetinaFile);
        });
    }
    
    else if ([fileExtension isEqualToString:@"bin"])
    {
        // BiNARY
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alBinaryLoader((char *)[self.ansi_inputFile UTF8String],
                           (char *)[self.ansi_outputFile UTF8String],
                           (char *)[self.ansi_retinaOutputFile UTF8String],
                           (char *)[self.ansi_columns UTF8String],
                           (char *)[self.ansi_font UTF8String],
                           (char *)[self.ansi_bits UTF8String],
                           (char *)[ansi_iceColorsString UTF8String],
                           self.generatesRetinaFile);
        });
    }
    
    else if ([fileExtension isEqualToString:@"adf"])
    {
        // ARTWORX
        dispatch_group_async(private_render_group, private_lib_queue, ^{
             alArtworxLoader((char *)[self.ansi_inputFile UTF8String],
                             (char *)[self.ansi_outputFile UTF8String],
                             (char *)[self.ansi_retinaOutputFile UTF8String],
                             (char *)[self.ansi_bits UTF8String],
                             self.generatesRetinaFile);
        });
    }
    
    else if ([fileExtension isEqualToString:@"idf"])
    {
        // iCEDRAW
        sauce *record = sauceReadFileName((char *)[self.ansi_inputFile UTF8String]);
        // ...this is checking the file war a valid SAUCE record, needed for IDF.
        
        // Update our property in case we found a SAUCE record.
        if (strcmp(record->ID, SAUCE_ID) == 0) {
            self.hasSauceRecord = YES;
        }
        
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alIcedrawLoader((char *)[self.ansi_inputFile UTF8String],
                            (char *)[self.ansi_outputFile UTF8String],
                            (char *)[self.ansi_retinaOutputFile UTF8String],
                            (char *)[self.ansi_bits UTF8String],
                            self.hasSauceRecord,
                            self.generatesRetinaFile);
        });
    }
    
    else if ([fileExtension isEqualToString:@"tnd"])
    {
        // TUNDRA
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alTundraLoader((char *)[self.ansi_inputFile UTF8String],
                           (char *)[self.ansi_outputFile UTF8String],
                           (char *)[self.ansi_retinaOutputFile UTF8String],
                           (char *)[self.ansi_font UTF8String],
                           (char *)[self.ansi_bits UTF8String],
                           self.generatesRetinaFile);
        });
    }
    
    else if ([fileExtension isEqualToString:@"xb"])
    {
        // XBiN
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alXbinLoader((char *)[self.ansi_inputFile UTF8String],
                         (char *)[self.ansi_outputFile UTF8String],
                         (char *)[self.ansi_retinaOutputFile UTF8String],
                         (char *)[self.ansi_bits UTF8String],
                         self.generatesRetinaFile);
        });
    }
    
    else {
        // ANSi
        NSString *fext = [[NSString alloc] initWithFormat:@".%@", fileExtension];
        // ...transforms the file extension into readable format for our sublib.
        
        dispatch_group_async(private_render_group, private_lib_queue, ^{
            alAnsiLoader((char *)[self.ansi_inputFile UTF8String],
                         (char *)[self.ansi_outputFile UTF8String],
                         (char *)[self.ansi_retinaOutputFile UTF8String],
                         (char *)[self.ansi_font UTF8String],
                         (char *)[self.ansi_bits UTF8String],
                         (char *)[ansi_iceColorsString UTF8String],
                         (char *)[fext UTF8String],
                         self.generatesRetinaFile);
        });
    }
    
    // Wait until file is parsed and PNG images are generated.
    dispatch_group_wait(private_render_group, DISPATCH_TIME_FOREVER);
}

@end
