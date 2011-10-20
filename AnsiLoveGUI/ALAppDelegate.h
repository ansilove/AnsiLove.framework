//
//  ALAppDelegate.h
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
//
//  Copyleft (ɔ) 2011, Stefan Vogt. All wrongs reserved.
//  http://byteproject.net
//

#import <Cocoa/Cocoa.h>
#import <Ansilove/AnsiLove.h>
// See that? Import the AnsiLove.framework as done above.

@interface ALAppDelegate : NSObject <NSApplicationDelegate>

// outlets
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *inputField;
@property (strong) IBOutlet NSTextField *outputField;
@property (strong) IBOutlet NSTextField *columnsField;
@property (strong) IBOutlet NSTextField *fontsField;
@property (strong) IBOutlet NSTextField *bitsField;
@property (strong) IBOutlet NSButton *iceColorsCheck;
@property (strong) IBOutlet NSButton *columnsCheck;

// strings
@property (strong) NSString *inputFile;
@property (strong) NSString *outputFile;
@property (strong) NSString *columns;
@property (strong) NSString *font;
@property (strong) NSString *bits;
@property (strong) NSString *iceColors;

// integer and float values
@property (assign) BOOL shouldUseIceColors;
@property (assign) BOOL enableColumnsField;

// actions
- (IBAction)createPNGfromANSi:(id)sender;
- (IBAction)clearColumnsField:(id)sender;

@end
