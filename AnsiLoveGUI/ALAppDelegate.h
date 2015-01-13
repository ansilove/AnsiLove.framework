//
//  ALAppDelegate.h
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
//
//  Copyright (C) 2011-2015 Stefan Vogt.
//  All rights reserved.
//
//  This source code is licensed under the BSD 3-Clause License.
//  See the file LICENSE for details.
//

#import <Cocoa/Cocoa.h>
#import <Ansilove/AnsiLove.h>
// See that!? Import the AnsiLove.framework as done above.

@interface ALAppDelegate : NSObject <NSApplicationDelegate>

// Instances
@property (strong) ALAnsiGenerator *ansigen;

// outlets
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *inputField;
@property (strong) IBOutlet NSTextField *columnsField;
@property (strong) IBOutlet NSTextField *fontsField;
@property (strong) IBOutlet NSTextField *bitsField;
@property (strong) IBOutlet NSButton *iceColorsCheck;
@property (strong) IBOutlet NSButton *columnsCheck;
@property (strong) IBOutlet NSMatrix *outputMatrix;

// strings
@property (strong) NSString *inputFile;
@property (strong) NSString *outputFile;
@property (strong) NSString *columns;
@property (strong) NSString *font;
@property (strong) NSString *bits;

// integer and float values
@property (assign) BOOL shouldUseIceColors;
@property (assign) BOOL enableColumnsField;

// general actions and methods
- (IBAction)createImagefromANSi:(id)sender;
- (IBAction)clearColumnsField:(id)sender;
- (void)postFinishedRenderingToLog:(NSNotification *)notification;

// sandboxing related actions
- (IBAction)userDefinedInputFile:(id)sender;

@end
