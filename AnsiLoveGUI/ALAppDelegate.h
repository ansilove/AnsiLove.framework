//
//  ALAppDelegate.h
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
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

#import <Cocoa/Cocoa.h>
#import <Ansilove/AnsiLove.h>
// See that!? Import the AnsiLove.framework as done above.

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
