//
//  ALAnsiGenerator.m
//  AnsiLove.framework
//
//  Copyleft (ɔ) 2011, Stefan Vogt. All wrongs reserved.
//  http://byteproject.net
//

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
    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:inputFile, outputFile, nil];
    if (columns != nil || columns != @"") {
        [arguments addObject:columns];
    }
    if (font != nil || font != @"") {
        [arguments addObject:font];
    }
    if (bits != nil || bits != @"") {
        [arguments addObject:bits];
    }
    if (iceColors != nil || iceColors != @"") {
        [arguments addObject:iceColors];
    }
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ansilove" ofType:nil]];
    [task setArguments:arguments];
    [task setStandardOutput:pipe];
    
    [task launch];
}

@end
