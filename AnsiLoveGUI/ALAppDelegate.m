//
//  ALAppDelegate.m
//  AnsiLoveGUI
//
//  Test app for the AnsiLove.framework
//
//  Copyright (c) 2011-2013, Stefan Vogt. All rights reserved.
//  http://byteproject.net
//
//  Use of this source code is governed by a MIT-style license.
//  See the file LICENSE for details.
//

#import "ALAppDelegate.h"

@implementation ALAppDelegate

@synthesize window = _window, inputField, columnsField, fontsField, bitsField, iceColorsCheck,
            columnsCheck, inputFile, outputFile, columns, font, bits, shouldUseIceColors,
            enableColumnsField, outputMatrix, ansigen;

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
    
    // For using ALAnisGenerator, you need to create an instance of it like this.
    self.ansigen = [ALAnsiGenerator new];
    
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
- (IBAction)createImagefromANSi:(id)sender
{
    // It's necessary to tell AnsiLove where to generate it's output. In this sample app
    // all output will be thrown into the user's Downloads folder. We keep it simple by
    // naming output after the input file. It's no problem to specify custom names/paths
    // for output with the framework. There's just one thing you should take care of: don't
    // add any .PNG or .TIFF suffix to the output file string as AnsiLove will handle that
    // for you. Allright? Here we go!
    
    // Get the input file name without path components.
    NSString *fileWithoutPath = [self.inputFile lastPathComponent];
    
    // Merge file name with destination path (Downloads folder).
    NSString *fileMergedDLPath =[[NSString alloc]
                                 initWithFormat:@"~/Downloads/%@", fileWithoutPath];
    
    // Voila, this is our outputFile string. Easy.
    self.outputFile = [fileMergedDLPath stringByExpandingTildeInPath];
    
    // Let's finally pass all we got to AnsiLove.framework, it will do the rest.
    // If you don't want to set a specific flag, like the font flag for example, just
    // pass nil or an empty NSString like @"". Both will work and AnsiLove will use
    // it's built-in default values for generating the output PNG.
    switch ([self.outputMatrix selectedRow]) {
        case 0:
            // regular PNG image
            [ansigen renderAnsiFile:self.inputFile
                         outputFile:self.outputFile
                               font:self.font
                               bits:self.bits
                          iceColors:self.shouldUseIceColors
                            columns:self.columns
                             retina:NO];
            break;
        case 1:
            // regular and Retina @2x.PNG image
            [ansigen renderAnsiFile:self.inputFile
                         outputFile:self.outputFile
                               font:self.font
                               bits:self.bits
                          iceColors:self.shouldUseIceColors
                            columns:self.columns
                             retina:YES];
            break;
        default:
            break;
    }
}

- (void)postFinishedRenderingToLog:(NSNotification *)notification
{
    // This selector gets invoked once the AnsiLove.framework finished rendering.
    NSLog(@"Rendering of the ANSi source file has finished. Yay!");
}

- (IBAction)clearColumnsField:(id)sender 
{
    // The method clears the columns field as soon as it get's disabled. That's how
    // we make sure no content is passed when the columns flag is not needed.
    if ([columnsField isEnabled] == NO) {
        self.columns = @"";
    }
}

# pragma mark -
# pragma mark sandboxing related actions

// Sandboxed applications require user interaction for opening and saving specific files.
// We register user-defined files via NSOpenPanel. Just entering a path into the corresponding
// textfield won't work. That's why the textfield for input is deactivated in AnsiLoveGUI. The
// user is forced to hit the button and thus authenticating the whole operation. For output,
// I'm taking a simple approach by adding a read/write entitlement to the user's Downloads
// folder. All generated output will be put in there. Note that in certain situations, AnsiLove
// needs to gain access to additional files. For instance, if you decide to generate a regular
// and a Retina PNG variant, your sandboxed app needs to be allowed to write both. If you're
// creating output in yoursandox itself (e.g. Application Support), everything's fine as in
// your sandbox you are the master and allowed to do whatever you want to. I know, dealing
// with sandboxing is a pain in the ass. That's why I wanted this sample app to work outside
// it's app sandbox so you can take a glimpse look and see it is definitely possible.

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
        ALSauceMachine *sauce = [ALSauceMachine new];
        
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

@end
