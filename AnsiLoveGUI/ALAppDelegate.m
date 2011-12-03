//
//  ALAppDelegate.m
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
//
//  Copyright (c) 2011, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALAppDelegate.h"

@implementation ALAppDelegate

@synthesize window = _window, inputField, outputField, columnsField, fontsField, bitsField,
            iceColorsCheck, columnsCheck, inputFile, outputFile, columns, font, bits, iceColors,
            shouldUseIceColors, enableColumnsField;

# pragma mark -
# pragma mark initialization

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // When the ANSi source does not make specific use of iCE colors,
    // you should NOT set this flag. Also: NO is default in AnsiLove. Comprende?  
    self.shouldUseIceColors = NO;
    
    // The property is bound to the enabled binding of the columnsField. If you check 
    // columns in the GUI, the field gets enabled and you can enter a column value.
    // Note that this has NO educational purpose for the AnsiLove.framework, it's
    // just a nice feature I recommend as the columns flag is only needed for .bin files.
    self.enableColumnsField = NO;
    
    // AnsiLove.framework fires a notification once rendering of given ANSi source files
    // completed. If this is relevant for your app (e.g. you can't load an instance of an
    // image as long as it's not created) it should listen to AnsiLoveFinishedRendering.
    // In this example app I've implemented a simple selector that just posts a message
    // to NSLog once it recieved the finishedRendering note.
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(postFinishedRenderingToLog:)
               name:@"AnsiLoveFinishedRendering"
             object:nil];
}

# pragma mark -
# pragma mark general actions

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

- (void)postFinishedRenderingToLog:(NSNotification *)notification
{
    // This selector gets invoked once the AnsiLove.framework finished rendering.
    NSLog(@"Rendering of the ANSi source file has finished.");
}

- (IBAction)clearColumnsField:(id)sender 
{
    // The method clears the columns field as soon as it get's disabled. That way
    // we make sure that no content is passed when the columns flag is not needed.
    if ([columnsField isEnabled] == NO) {
        self.columns = @"";
    }
}

# pragma mark -
# pragma mark sandboxing related actions

// Sandboxed applications require user interaction for opening and saving specific files.
// We register user-defined files via NSOpenPanel and NSSavePanel. Just entering a path
// into the corresponding textfield won't work. That's why the textfields for input and
// output are deactivated in AnsiLoveGUI. The user is forced to hit the button and thus 
// authenticating the whole operation.

- (IBAction)userDefinedInputFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    // Define a custom 'Open' button first.
    [openPanel setPrompt:@"Set as Input"];
    
    // We should limit the extensions available for open files to those supported by 
    // AnsiLove.framework...  everything else just doesn't make any sense!
    NSArray *reqInTypes = [NSArray arrayWithObjects:
                           @"nfo", @"diz", @"asc", @"xb", @"ans", @"idf", @"pcb", @"tnd",
                           @"adf", @"bin", nil];
    [openPanel setAllowedFileTypes:reqInTypes];
    [openPanel setAllowsOtherFileTypes:NO];
    
    // A better title is appreciated!
    [openPanel setTitle:@"Choose ANSI Source"];
    
    if ([openPanel runModal] == NSOKButton)
    {
        // Get openPanel's URL and create a string from it. Remember to pass strings 
        // to AnsiLove.framework and no URLs.
        NSURL *inputURL = [openPanel URL];
        self.inputFile = [inputURL path];
        
        // The following code will explain usage of ALSauceMachine, the framework's
        // class for handling SAUCE records. Please refer to the documentation for 
        // general specifications of SAUCE. You may wonder why I put this in the 
        // inputFile method? SAUCE records not only contain release informations, 
        // they also contain (among other things) variables that define the data 
        // type, file type, flags. The flag property e.g. can tell you if an ANSi 
        // source uses iCE colors. So it's locical to put it somewhere before
        // ALAnsiGenerator starts it's rendering process. Many informations you
        // retrieve from SAUCE records can be passed as flags to ALAnsiGenerator.
        
        // We create an instance of ALSauceMachine first.
        ALSauceMachine *sauce = [[ALSauceMachine alloc] init];
        
        // Now try read SAUCE information from our given file.
        [sauce readRecordFromFile:self.inputFile];
        
        // ALSauceMachine comes with some handy BOOL properties, an effective way
        // for you to check what's going on after you instructed ALSauceMachine
        // to read SAUCE from a file.
        
        // The property 'fileHasRecord' will provide information if there is a 
        // SAUCE record in your file at all.
        if (sauce.fileHasRecord == NO) {
            // No record means there's no need to continue, we stop here.
            NSLog(@"%@ does not contain a SAUCE record.\n", self.inputFile);
            return;
        }
        else {
            // In case ALSauceMachine found a record in your file, we go on.
            NSLog(@"Found SAUCE record in file %@.\n", self.inputFile);
            
            // We gonna display the SAUCE in NSLog, we also use the two
            // properties 'fileHasComment' and 'fileHasFlags' for different
            // NSLog output, depending on whether the file has comments or
            // flags. ALSauceMachine already set this properties when it
            // investigated the file you passed. Convenient, isn't it?
            NSLog(@"id: %@\n", sauce.ID);
            NSLog(@"version: %@\n", sauce.version);
            NSLog(@"title: %@\n", sauce.title);
            NSLog(@"author: %@\n", sauce.author);
            NSLog(@"group: %@\n", sauce.group);
            NSLog(@"date: %@\n", sauce.date);
            NSLog(@"dataType: %ld\n", sauce.dataType);
            NSLog(@"fileType: %ld\n", sauce.fileType);
            NSLog(@"tinfo1: %ld\n", sauce.tinfo1);
            NSLog(@"tinfo2: %ld\n", sauce.tinfo2);
            NSLog(@"tinfo3: %ld\n", sauce.tinfo3);
            NSLog(@"tinfo4: %ld\n", sauce.tinfo4);
            if (sauce.fileHasComments == YES) {
                NSLog(@"comments:%@\n", sauce.comments);
            }
            else {
                NSLog(@"comments: no comments\n");
            }
            if (sauce.fileHasFlags == YES) {
                NSLog(@"flags:%ld\n", sauce.flags);
            }
            else {
                NSLog(@"flags: none\n");
            }
        }
    }
}

- (IBAction)userDefinedOutputFile:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    // We want a custom 'Save' button.
    [savePanel setPrompt:@"Set as Output"];
    
    // AnsiLove.framework generates PNG images from ANSi sources. The user should not
    // be able to specify an extension other than PNG, hence we add a limitation.
    NSArray *reqOutTypes = [NSArray arrayWithObjects:@"png", nil];
    [savePanel setAllowedFileTypes:reqOutTypes];
    [savePanel setAllowsOtherFileTypes:NO];
    
    // Let's optionally see the PNG extension in savePanel.
    [savePanel setCanSelectHiddenExtension:YES];
    
    // There's some need for a better title (though not much better).
    [savePanel setTitle:@"Save PNG"];
    
    if ([savePanel runModal] == NSOKButton)
    {   
        // We need a string, so get the path as string value from savepanel's URL.
        // The string is now ready for passing to ALAnsiGenerator.
        NSURL *outputURL = [savePanel URL];
        self.outputFile = [outputURL path];
    }
}

@end
