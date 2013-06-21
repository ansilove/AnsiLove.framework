//
//  ALAnsiGenerator.m
//  AnsiLove.framework
//
//  Copyright (c) 2011-2012, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALAnsiGenerator.h"

@implementation ALAnsiGenerator

- (id)init
{
    if (self = [super init]) {}
    return self;
}

+ (void)ansiFileToPNG:(NSString *)inputFile
           outputFile:(NSString *)outputFile
                 font:(NSString *)font
                 bits:(NSString *)bits
            iceColors:(NSString *)iceColors
              columns:(NSString *)columns;
{     
    if (inputFile == nil || [inputFile isEqual: @""]) {
        // No inputfile? This means we can't do anything. Get the hell outta here.
        return;
    }
    
    if (outputFile == nil || [outputFile isEqual: @""]) {
        // In case the user provided no output file / path, just use the file name and
        // path from the inputFile value. AnsiLove/C adds PNG suffix automatically.
        outputFile = inputFile;
    }
    
    // We need to resolve any tilde in path before passing this argument to NSTask.
    inputFile = [inputFile stringByExpandingTildeInPath];
    outputFile = [outputFile stringByExpandingTildeInPath];
    
    // Initialize the arguments array.
    NSMutableArray *arguments = [NSMutableArray new];
    
    // Option flag for generating a single, regular-sized PNG with AnsiLove/C.
    NSString *optionFlag = @"-o";
    
    // Add the three most necessary arguments to the array.
    [arguments addObject:inputFile];
    [arguments addObject:optionFlag];
    [arguments addObject:outputFile];
    
    // The following if statements check if a string is nil or empty. That way we can
    // be sure only strings with proper contents will be added to the arguments array.
    if (font && ![font isEqualToString:@""]) {
        [arguments addObject:font];
    }
    if (bits && ![bits isEqualToString:@""]) {
        [arguments addObject:bits];
    }
    if (iceColors && ([iceColors isEqualToString:@"1"] || [iceColors isEqualToString:@"0"])) {
        [arguments addObject:iceColors];
    }
    if (columns && ![columns isEqualToString:@""]) {
        [arguments addObject:columns];
    }
    
    // Finally start the task with the flags we gathered.
    NSPipe *libPipe;
    libPipe = [NSPipe pipe];
    
    NSTask *libTask = [NSTask new];
    [libTask setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ansilove" ofType:nil]];
    [libTask setArguments:arguments];
    [libTask setStandardOutput:libPipe];
    
    // Ready for launch in 3... 2... 1...
    [libTask launch];
    
    // Stay in limbo until rendering is finished.
    [libTask waitUntilExit];
    
    // Post a notification so any listener will know rendering has finished now.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AnsiLoveFinishedRendering" object:self];
}

+ (void)ansiFileToRetinaPNG:(NSString *)inputFile
                 outputFile:(NSString *)outputFile
                       font:(NSString *)font
                       bits:(NSString *)bits
                  iceColors:(NSString *)iceColors
                    columns:(NSString *)columns
{
    if (inputFile == nil || [inputFile isEqual:@""]) {
        // No inputfile? This means we can't do anything. Get the hell outta here.
        return;
    }
    
    if (outputFile == nil || [outputFile isEqual:@""]) {
        // In case the user provided no output file / path, just use the file name and
        // path from the inputFile value. AnsiLove/C adds PNG suffix automatically.
        outputFile = inputFile;
    }
    
    // We need to resolve any tilde in path before passing this argument to NSTask.
    inputFile = [inputFile stringByExpandingTildeInPath];
    outputFile = [outputFile stringByExpandingTildeInPath];
    
    // Initialize the arguments array.
    NSMutableArray *arguments = [NSMutableArray new];
    
    // Option flag for generating additional @2x.PNG output with AnsiLove/C.
    NSString *optionFlag = @"-or";
    
    // Add the three most necessary arguments to the array.
    [arguments addObject:inputFile];
    [arguments addObject:optionFlag];
    [arguments addObject:outputFile];
    
    // The following if statements check if a string is nil or empty. That way we can
    // be sure only strings with proper contents will be added to the arguments array.
    if (font && ![font isEqualToString:@""]) {
        [arguments addObject:font];
    }
    if (bits && ![bits isEqualToString:@""]) {
        [arguments addObject:bits];
    }
    if (iceColors && ([iceColors isEqualToString:@"1"] || [iceColors isEqualToString:@"0"])) {
        [arguments addObject:iceColors];
    }
    if (columns && ![columns isEqualToString:@""]) {
        [arguments addObject:columns];
    }
    
    // Finally start the task with the flags we gathered.
    NSPipe *libPipe;
    libPipe = [NSPipe pipe];
    
    NSTask *libTask = [NSTask new];
    [libTask setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ansilove" ofType:nil]];
    [libTask setArguments:arguments];
    [libTask setStandardOutput:libPipe];
    
    // Ready for launch in 3... 2... 1...
    [libTask launch];
    
    // Stay in limbo until rendering is finished.
    [libTask waitUntilExit];
    
    // Post a notification so any listener will know rendering has finished now.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AnsiLoveFinishedRendering" object:self];
}

+ (void)ansiFileToRetinaTIFF:(NSString *)inputFile
                  outputFile:(NSString *)outputFile
                        font:(NSString *)font
                        bits:(NSString *)bits
                   iceColors:(NSString *)iceColors
                     columns:(NSString *)columns
{
    if (inputFile == nil || [inputFile isEqual:@""]) {
        // No inputfile? This means we can't do anything. Get the hell outta here.
        return;
    }
    
    if (outputFile == nil || [outputFile isEqual:@""]) {
        // In case the user provided no output file / path, just use the file name and
        // path from the inputFile value. AnsiLove/C adds PNG suffix automatically.
        outputFile = inputFile;
    }
    
    // We need to resolve any tilde in path before passing this argument to NSTask.
    inputFile = [inputFile stringByExpandingTildeInPath];
    outputFile = [outputFile stringByExpandingTildeInPath];
    
    // Initialize the arguments array.
    NSMutableArray *arguments = [NSMutableArray new];
    
    // Option flag for generating additional @2x.PNG output with AnsiLove/C.
    NSString *optionFlag = @"-or";
    
    // Add the three most necessary arguments to the array.
    [arguments addObject:inputFile];
    [arguments addObject:optionFlag];
    [arguments addObject:outputFile];
    
    // The following if statements check if a string is nil or empty. That way we can
    // be sure only strings with proper contents will be added to the arguments array.
    if (font && ![font isEqualToString:@""]) {
        [arguments addObject:font];
    }
    if (bits && ![bits isEqualToString:@""]) {
        [arguments addObject:bits];
    }
    if (iceColors && ([iceColors isEqualToString:@"1"] || [iceColors isEqualToString:@"0"])) {
        [arguments addObject:iceColors];
    }
    if (columns && ![columns isEqualToString:@""]) {
        [arguments addObject:columns];
    }
    
    // Finally start the task with the flags we gathered.
    NSPipe *libPipe;
    libPipe = [NSPipe pipe];
    
    NSTask *libTask = [NSTask new];
    [libTask setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ansilove" ofType:nil]];
    [libTask setArguments:arguments];
    [libTask setStandardOutput:libPipe];
    
    // Ready for launch in 3... 2... 1...
    [libTask launch];
    
    // Stay in limbo until rendering is finished.
    [libTask waitUntilExit];
    
    // Generate path / suffix strings for all files involved.
    NSString *outputPNG = [[NSString alloc] initWithFormat:@"%@.png", outputFile];
    NSString *retinaOutputPNG = [[NSString alloc] initWithFormat:@"%@@2x.png", outputFile];
    NSString *retinaOutputTIFF = [[NSString alloc] initWithFormat:@"%@.tiff", outputFile];
    
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
    
    // Post a notification so any listener will know rendering has finished now.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AnsiLoveFinishedRendering" object:self];
}

@end
