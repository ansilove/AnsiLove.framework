//
//  ALAppDelegate.m
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
//
//  Copyleft (ɔ) 2011, Stefan Vogt. All wrongs reserved.
//  http://byteproject.net
//

#import "ALAppDelegate.h"

@implementation ALAppDelegate

@synthesize window = _window, inputField, outputField, columnsField, fontsField, bitsField,
            iceColorsCheck, columnsCheck, inputFile, outputFile, columns, font, bits, iceColors,
            shouldUseIceColors, enableColumnsField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // When the ANSi source does not make specific use of iCE colors,
    // you should NOT set this flag. Also: NO is default in AnsiLove. Comprende?  
    self.shouldUseIceColors = NO;
    
    // The property is bound to the enabled binding of the columnsField. If you check 
    // columns in the GUI, the field gets enabled and you can enter a column value.
    // Note that this has no educational purpose for the AnsiLove.framework, it's
    // just a nice feature I recommend as the columns flag is only needed for .bin files.
    self.enableColumnsField = NO;
}

// This method gets invoked by the 'Generate' button. It collects all the content the user
// entered into the text fields and calls the framework. The synthesized string values above
// (inputFile, outputFile, columns, font and bits) are all bound to the corresponding 
// value binding of the text field instances you can see in the UI.
- (IBAction)createPNGfromANSi:(id)sender 
{
    if (shouldUseIceColors == NO) {
        // AnsiLove needs all flags as strings, that's why we can't pass the bool value 
        // (or any other integer) directly. You can do something like I did below.
        self.iceColors = @"0";
    }
    else {
        self.iceColors = @"1";
    }
    
    // Let's finally pass all we got to the AnsiLove.framework, it will do the rest.
    // If you don't want to set a specific flag, like the font flag for example, just
    // pass nil or an empty NSString like @"". Both will work and AnsiLove will use
    // it's built-in default values for generating the output PNG.
    [ALAnsiGenerator createPNGFromAnsiSource:self.inputFile 
                                  outputFile:self.outputFile 
                                     columns:self.columns 
                                        font:self.font 
                                        bits:self.bits 
                                   iceColors:self.iceColors];
}

- (IBAction)clearColumnsField:(id)sender 
{
    // The method clears the columns field as soon as it get's disabled. That way
    // we make sure that no content is passed when the columns flag is not needed.
    if ([columnsField isEnabled] == NO) {
        self.columns = @"";
    }
}

@end
