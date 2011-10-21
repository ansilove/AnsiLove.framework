//
//  ALAnsiGenerator.m
//  AnsiLove.framework
//
//  Copyleft (ɔ) 2011, Stefan Vogt. All wrongs reserved.
//  http://byteproject.net
//

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 * This program is free software; you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation; either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program; if not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "ALAnsiGenerator.h"

@implementation ALAnsiGenerator

- (id)init
{
    if (self == [super init]) {}
    return self;
}

+ (void)createPNGFromAnsiSource:(NSString *)inputFile 
                     outputFile:(NSString *)outputFile
                        columns:(NSString *)columns
                           font:(NSString *)font 
                           bits:(NSString *)bits
                      iceColors:(NSString *)iceColors
{ 
    if (inputFile == nil || inputFile == @"") {
        // No inputfile? This means we can't do anything. Get the hell outta here.
        return;
    }
    
    if (outputFile == nil || outputFile == @"") {
        // In case the user provided no output file / path, just use the file name and
        // path from the inputFile value but add .png as suffix.
        outputFile = [[NSString alloc] initWithFormat:@"%@.png", inputFile];
    }
    
    // Initialize the arguments array.
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    // Add the two most necessary arguments to the array.
    [arguments addObject:inputFile];
    [arguments addObject:outputFile];
    
    // The following if statements check if a string is nil or empty. That way we can
    // be sure only strings with proper contents will be added to the arguments array.
    if (columns && ![columns isEqualToString:@""]) {
        [arguments addObject:columns];
    }
    if (font && ![font isEqualToString:@""]) {
        [arguments addObject:font];
    }
    if (bits && ![bits isEqualToString:@""]) {
        [arguments addObject:bits];
    }
    if (iceColors && [iceColors isEqualToString:@"1"]) {
        [arguments addObject:iceColors];
    }
    
    // Finally start the task with the flags we gathered.
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ansilove" ofType:nil]];
    [task setArguments:arguments];
    [task setStandardOutput:pipe];
    
    [task launch];
}

@end
