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
#import "ALConfig.h"
#import "ALSubStr.h"
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
                  TIFF:(BOOL      )mergeToTIFF
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
    self.ansi_outputFile = outputFile;
    
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
    
    // Needless to say: we are only able to merge a TIFF if a retina file is created.
    self.mergesOutputToTIFF = NO;
    if (mergeToTIFF == YES && self.generatesRetinaFile == YES) {
        self.mergesOutputToTIFF = YES;
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
    
    // Let's abuse Grand Central Dispatch for asynchronous wonders.
    dispatch_group_t render_group = dispatch_group_create();
    dispatch_queue_t lib_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Fire in order. We know the preceding block is complete before the next block executes.
    dispatch_group_async(render_group, lib_queue, ^{
        [self ALPRIVATE_invokeLibAndCreateOutput];
    });
    
    if (self.mergesOutputToTIFF == YES) {
        dispatch_group_async(render_group, lib_queue, ^{
            [self ALPRIVATE_createTIFFimageFromOutput];
        });
    }
    
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
    NSString *ansi_retinaOutputFile = [[NSString alloc] initWithFormat:@"%@@2x.png", self.ansi_outputFile];
    
    // Create NSString from self.iceColors BOOL value.
    NSString *ansi_iceColorsString = (self.ansi_iceColors) ? @"1" : @"0";
    
    // Use determined file extension to fire appropiate lib method.
    if ([fileExtension isEqualToString:@"pcb"])
    {
        // PCBOARD
        alPcBoardLoader((char *)[self.ansi_inputFile UTF8String],
                        (char *)[self.ansi_outputFile UTF8String],
                        (char *)[ansi_retinaOutputFile UTF8String],
                        (char *)[self.ansi_font UTF8String],
                        (char *)[self.ansi_bits UTF8String],
                        self.generatesRetinaFile);
    }
    if ([fileExtension isEqualToString:@"bin"])
    {
        // BINARY
        alBinaryLoader((char *)[self.ansi_inputFile UTF8String],
                       (char *)[self.ansi_outputFile UTF8String],
                       (char *)[ansi_retinaOutputFile UTF8String],
                       (char *)[self.ansi_columns UTF8String],
                       (char *)[self.ansi_font UTF8String],
                       (char *)[self.ansi_bits UTF8String],
                       (char *)[ansi_iceColorsString UTF8String],
                       self.generatesRetinaFile);
    }
}

- (void)ALPRIVATE_createTIFFimageFromOutput
{
    // Generate path / suffix strings for all files involved.
    NSString *outputPNG = [[NSString alloc] initWithFormat:@"%@.png", self.ansi_outputFile];
    NSString *retinaOutputPNG = [[NSString alloc] initWithFormat:@"%@@2x.png", self.ansi_outputFile];
    NSString *retinaOutputTIFF = [[NSString alloc] initWithFormat:@"%@.tiff", self.ansi_outputFile];
    
    // We use tiffutil, there are two more strings needed for this purpose.
    NSString *dpiFlag = @"-cathidpicheck";
    NSString *outFlag = @"-out";
    
    // Create an array for flags we pass.
    NSMutableArray *tiffutilFlags = [NSMutableArray new];
    
    // This will be the hell of an argument array.
    [tiffutilFlags addObject:dpiFlag];
    [tiffutilFlags addObject:outputPNG];
    [tiffutilFlags addObject:retinaOutputPNG];
    [tiffutilFlags addObject:outFlag];
    [tiffutilFlags addObject:retinaOutputTIFF];
    
    // Note that tiffutil is outside any sandboxed environment.
    NSPipe *extPipe;
    extPipe = [NSPipe pipe];
    
    NSTask *extTask = [NSTask new];
    [extTask setLaunchPath:@"/usr/bin/tiffutil"];
    [extTask setArguments:tiffutilFlags];
    [extTask setStandardOutput:extPipe];
    
    // OMG lasergun, phew phew!
    [extTask launch];
    
    // Time stands still.
    [extTask waitUntilExit];
    
    // Remove temporary PNG files.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:outputPNG]) {
        [fileManager removeItemAtPath:outputPNG error:nil];
    }
    if ([fileManager fileExistsAtPath:retinaOutputPNG]) {
        [fileManager removeItemAtPath:retinaOutputPNG error:nil];
    }
}

@end
