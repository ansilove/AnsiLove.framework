# AnsiLove.framework

This is a Cocoa framework I consider as modern approach of bringing back the good old days™. It's capable of rendering ANSi / ASCII art and it also handles SAUCE records. There are two classes responsible for all the magic: `ALAnsiGenerator` and `ALSauceMachine`. The former, `ALAnsiGenerator` creates Retina-ready PNG and TIFF images from ANSi source files. What with one thing and another, images are read-only. So if you're looking for something that generates output in real textmode, maybe as a NSAttributedString instance, you're wrong. However, if you're seeking the most complete and accurate rendering of ANSi art sources available these days, you came to the right place. While `ALAnsiGenerator` acts more like a Cocoa layer, there is a specifc library under the surface. It's called [AnsiLove/C](https://github.com/ByteProject/AnsiLove-C) and we spent countless hours developing it. The latter, `ALSauceMachine` is reading SAUCE records and returns these values as Objective-C properties. 

# Version info

Current framework release: `3.0.0` - rendering library: [AnsiLove/C](https://github.com/ByteProject/AnsiLove-C) `2.0.1`

# Features

Rendering of all known ANSi / ASCII art file types:

- ANSi (.ANS)
- Binary (.BIN)
- Artworx (.ADF)
- iCE Draw (.IDF)
- Xbin (.XB) [details](http://www.acid.org/info/xbin/xbin.htm)
- PCBoard (.PCB)
- Tundra (.TND) [details](http://sourceforge.net/projects/tundradraw)
- ASCII (.ASC)
- Release info (.NFO)
- Description in zipfile (.DIZ)

Files with custom suffix default to the ANSi renderer (e.g. ICE or CIA).

AnsiLove.framework is capabable of processing: 

- SAUCE records
- DOS and Amiga fonts (embedded binary dump) 
- iCE colors

Still not enough?

- Output files are highly optimized 4-bit images.
- Optionally generate proper Retina @2x.PNG files.
- Merge output as TIFF, containing regular and Retina resolutions. 
- Use custom objects for adjusting output results.
- Built-in support for rendering Amiga ASCII.
- Everything's Mac App Store conform and sandboxing compliant.
- This is an Automatic Reference Counting (ARC) project.

# Documentation

Let's talk about using the framework in your own projects. First of all, AnsiLove.framework is intended to run on `OS X`, it won't work on `iOS`. Yeah, sorry for that. Not even my fault, it's simply not possible at this point. You have to download the sources and compile the framework. At least OS X Mountain Lion and Xcode 4.x are necessary for compiling the framework `as is`. Generally, targeting older SDKs is supported, but for said purpose you will also have to recompile all contents in the `Library` folder, including [AnsiLove/C](https://github.com/ByteProject/AnsiLove-C). While [AnsiLove/C](https://github.com/ByteProject/AnsiLove-C) sources are up in a separate repository here on GitHub (just follow the link), sources for contained dylibs are not provided. Well, I never said it's easy to target older systems, at least it's possible. The project file contains two build targets, the framework itself and a test app `AnsiLoveGUI`, the latter is optional. Select `AnsiLoveGUI` from the Schemes dropdown in Xcode if you desire to compile that one too. The test app is a good example of implementing AnsiLove.framework, it does not contain much code and what you find there is well commented. So `AnsiLoveGUI` might be your first place to play with the framework after reading this documentation. Being an ARC framework, the test app is a pure ARC project as well. What else. 

## Adding the framework to your projects

Place the compiled framework in a folder inside your project, I recommend creating a `Frameworks` folder, if not existing. In Xcode go to the File menu and select `Add Files to "MyProject"`, select the AnsiLove.framework you just dropped in the `Frameworks` folder and then drag the framework to the other frameworks in your project hierarchy. The last steps are pretty easy:

- In the project navigator, select your project
- Select your target
- Select the `Build Phases` tab
- Open `Link Binaries With Libraries` expander
- Click the `+` button and select AnsiLove.framework
- Hit `Add Build Phase` at the bottom
- Add a `Copy Files` build phase with `Frameworks` as destination
- Once again select AnsiLove.framework

Now AnsiLove.framework is properly linked to your target and will be added to compiled binaries.

## Implementing the framework in your own sources

Go to the header of the class you want to use the framework with. Import the framework like this:

	#import <Ansilove/AnsiLove.h>

To transform ANSi source files into a beautiful images, `ALAnsiGenerator` comes with three methods you should know:

	+ (void)ansiFileToPNG:
	+ (void)ansiFileToRetinaPNG:
	+ (void)ansiFileToRetinaTIFF:

Method `ansiFileToPNG:` creates a single PNG image in regular resolution from any given ANSi source. `ansiFileToRetinaPNG:` generates the regular PNG and additionally creates a properly named (and sized) Retina @2x.PNG variant. `ansiFileToRetinaTIFF:` generates the two PNGs and merges them to a Retina-ready TIFF, containing both resolutions. The PNG cache files will be automatically deleted after TIFF output is done.

You can call said methods like this:

	[ALAnsiGenerator ansiFileToRetinaTIFF:self.myInputFile 
                               outputFile:self.myOutputFile 
                                     font:self.myFont 
                                     bits:self.myBits 
                                iceColors:self.myIceColors
                                  columns:self.myColumns];

Keep in mind that `ALAnsiGenerator` needs all it's objects as `NSString` instances. You can work internally with numeric types like `NSInteger` or `BOOL` but you need to convert them to strings before you pass these values to `ALAnsiGenerator`. For example, `iceColors` (I'm going to explain all objects in detail below) can only be `0` or `1`, so it's perfect to have that as `BOOL` type in your app. I did this in `AnsiLoveGUI` as well. To pass this value to ALAnsiGenerator you can do it something like this:

	NSString *iceColors;
	BOOL	 shouldUseIceColors;

	if (shouldUseIceColors == NO) {
        	self.iceColors = @"0";
    	}
    	else {
        	self.iceColors = @"1";
    	}

Note that generally all objects except `inputFile` are optional. You can either decide to pass `nil` (AnsiLove.framework will then work with it's default values) or pass empty strings like:

	self.myFontString = @"";
	
AnsiLove.framework will silently consume `nil` and empty string values but it will rely on it's built-in defaults in both cases. Clever? Sure. So much for the basics, let's head over to the details. The three methods seem pretty simple, but in fact they're so damn powerful if you know how to deal with objects you pass and that is what I'm going to teach you now.

## (NSString *)inputFile

The only necessary object you need to pass to ALAnsiGenerator. Well, that's logic. If there is no input file, what should be the output? I see you get it. Here is an example for a proper `inputFile` string:

	/Users/Stefan/Desktop/MyAnsiArtwork.ans
	
I recommend treating this string case-sensitive.  As you can see, that string explicitly needs to contain the path and the file name. That's pretty cool because it means you can work either with `NSStrings` or `NSURLs` internally. Just keep in mind that any `NSURL` needs to be converted to a string before passing to ALAnsiGenerator. NSURL has a method called `absoluteString` that can be used for easy conversion.
	
	NSURL 	 *myURL;
	NSString *urlString = [myURL absoluteString];

But AnsiLove.framework is even more flexible and it will automatically resolve any tilde in `inputFile` string instances. Now you know that this is a proper `inputFile` string, too:

	~/Desktop/MyAnsiArtwork.ans

Simple, elegant, comfortable, just working? You decide.

## (NSString *)outputFile

Formatting of string `outputFile` is identical to string `inputFile`. Only one difference: `outputFile` is optional. If you don't set this object, the framework will use the same path / file name you passed as `inputFile` string, but it adds .PNG or .TIFF as suffix, depending on what method you fired. However, if you plan to write your images into a different directory and / or under a different filename, go ahead and customize this object. Just keep in mind that for custom paths the suffix will be added automatically as well.

## (NSString *)font

AnsiLove.framework comes with two font families both originating from the golden age of ANSi artists. These font families are `PC` and `AMIGA`, the latter restricted to 8-bit only. Let's have a look at the values you can pass as `font` string.

`PC` fonts can be (all case-sensitive):

- `80x25` (code page 437)
- `80x50` (code page 437, 80x50 mode)
- `baltic` (code page 775)
- `cyrillic` (code page 855)
- `french-canadian` (code page 863)
- `greek` (code page 737)
- `greek-869` (code page 869)
- `hebrew` (code page 862)
- `icelandic` (Code page 861)
- `latin1` (code page 850)
- `latin2` (code page 852)
- `nordic` (code page 865)
- `portuguese` (Code page 860)
- `russian` (code page 866)
- `terminus` (modern font, code page 437)
- `turkish` (code page 857)

`AMIGA` fonts can be (all case-sensitive):

- `amiga` (alias to Topaz)
- `microknight` (Original MicroKnight version)
- `microknight+` (Modified MicroKnight version)
- `mosoul` (Original mO'sOul font)
- `pot-noodle` (Original P0T-NOoDLE font)
- `topaz` (Original Topaz Kickstart 2.x version)
- `topaz+` (Modified Topaz Kickstart 2.x+ version)
- `topaz500` (Original Topaz Kickstart 1.x version)
- `topaz500+` (Modified Topaz Kickstart 1.x version)

If you don't set a `font` object either passing `nil` or an empty string to ALAnsiGenerator, AnsiLove.framework will generate images using `80x25`, which is the default DOS font.

## (NSString *)bits

Bits can be (all case-sensitive): 

- `8` (8-bit)
- `9` (9-bit)
- `ced`
- `transparent`
- `workbench`

Setting the bits to `9` will render the 9th column of block characters, so the output will look like it is displayed in real textmode. 

Setting the bits to `ced` will cause the input file to be rendered in black on gray, and limit the output to 78 columns (only available for `.ans` files). Used together with an `AMIGA` font, the output will look like it is displayed on Amiga.

Setting the bits to `workbench` will cause the input file to be rendered using Amiga Workbench colors (only available for `.ans` files).

Settings the bits to `transparent` will produce output files with transparent background (only available for `.ans` files).

## (NSString *)iceColors

Setting `iceColors` to `1` will enable iCE color codes. On the opposite `0` means that that `iceColors` are disabled, which is the default value. When an ANSi source was created using iCE colors, it was done with a special mode where the blinking was disabled, and you had 16 background colors available. Basically, you had the same choice for background colors as for foreground colors, that's iCE colors. But now the important part: when the ANSi source does not make specific use of iCE colors, you should NOT enable them. The file could look pretty weird in normal mode. So in most cases it's fine to turn iCE colors off. 

## (NSString *)columns

`columns` is only relevant for ANSi source files with `.BIN` extension and even for those files optional. In most cases conversion will work fine if you don't set this flag, the default value is `160` then. So please pass `columns` only to `.BIN` files and only if you exactly know what you're doing. The sun could explode or even worse: A KITTEN MAY DIE SOMEWHERE.

## Supported options for each file type

Here's a simple overview of which file type supports which object. Note that ADF, IDF and XB sources don't support custom font objects as they come with embedded fonts:

	 ___________________________________________
	|     |         |       |       |           |
	|     | columns |  font |  bits | icecolors |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |	
	| ANS |         |   X   |   X   |     X     |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |	
	| PCB |         |   X   |   X   |     X     |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |
	| BIN |    X    |   X   |   X   |     X     |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |
	| ADF |         |       |       |           |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |
	| IDF |         |       |       |           |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |
	| TND |         |   X   |   X   |           |
	|_____|_________|_______|_______|___________|
	|     |         |       |       |           |
	| XB  |         |       |       |           |
	|_____|_________|_______|_______|___________|

## Rendering Process Feedback

AnsiLove.framework will post a notification once processing of given source files is finished. In most cases it's pretty important to know when rendering is done. One might want to present an informal dialog or update the UI afterwards. For making your app listen to the `AnsiLoveFinishedRendering` note, all you need is adding this to the `init` method of the class you consider as relevant:

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(addYourCustomSelectorHere:)
               name:@"AnsiLoveFinishedRendering"
             object:nil];

The test app `AnsiLoveGUI` has a simple implementation that posts a message to NSLog as soon as the rendering is completed. 

## Output file example

You may wonder how the rendered output looks like? You'll find an example in regular resolution [here](http://cl.ly/1D0o1M2t2Y190v33462F/o).

# Reading SAUCE records

The framework's class for dealing with SAUCE records is `ALSauceMachine`. But before we continue, here's your opportunity to introduce yourself to the [SAUCE specifications](http://www.acid.org/info/sauce/s_spec.htm). Plenty values retrieved from SAUCE records can be passed as objects to `ALAnsiGenerator`, so it makes sense indeed to check for a SAUCE record before you start rendering. Anyway, it's just a hint. Convenient yes, but by no means necessary. Enough theory, here is how to use the class. First we need to create an instance of `ALSauceMachine`:

	 ALSauceMachine *sauce = [ALSauceMachine new];

Of course `[[ALSaucemachine alloc] init],` will work fine as well. Now call `readRecordFromFile:`, this should be self-explanatory:

	[sauce readRecordFromFile:myInputFile];

You probably guess that not all files contain SAUCE and you're right. Many ANSi files actually contain SAUCE (like [this file](http://sixteencolors.net/pack/acid-56/W7-R666.ANS)) and some just don't. So how do you know? I've implemented three handy BOOL values, they give you all the feedback you need: 

	BOOL fileHasRecord;
	BOOL fileHasComments;
	BOOL fileHasFlags;
	
The first property, `fileHasRecord` stands above the others, which means if a file doesn't have a SAUCE record, it's evident it doesn't have SAUCE comments and objects. My advice: don't check `fileHasComments` and `fileHasFlags` if you already know there is no SAUCE record. Don't get my wrong, nothing will explode if you do so (not even the sun). But the answer will always be NO in that case so it's a waste of time. What if a file contains a SAUCE record on the other hand? It's nevertheless possible it doesn't have comments and objects. So if `fileHasRecord` is YES, you should try the other two BOOL values as well. Let's assume your class instance is still `*sauce` and you now checked for all three BOOL types, knowing the details. How to retrieve the SAUCE? Easy. `ALSauceMachine` stores the SAUCE record into properties, right at your fingertips:

	NSString  *ID;
	NSString  *version;
	NSString  *title;
	NSString  *author;
	NSString  *group;
	NSString  *date;
	NSInteger dataType;
	NSInteger fileType;
	NSInteger tinfo1;
	NSInteger tinfo2;
	NSInteger tinfo3;
	NSInteger tinfo4;
	NSString  *comments;
	NSInteger flags;

Now imagine you want to print SAUCE title and author in NSLog:

	NSLog(@"This is: %@ by %@.", sauce.title, sauce.author);
	
That's it. If you feel like this introduction to AnsiLove.framework's SAUCE implementation left some of your questions unanswered, I suggest you take a closer look at `AnsiLoveGUI` (the sample app). It contains a full featured yet simple example how to use `ALSauceMachine`. 

# App Sandboxing

The framework runs great in sandboxed apps. That is because I handcrafted it to be like that. No temporary exceptions, no hocus-pocus, just you on your lonely island. AnsiLove.framework comes with it's own tiny subsystem to achieve sandboxing compliance. Sounds like no big deal? Go sit on a tack. Actually that was the hardest part of the whole framework.

# Retina support

By investigating `ALAnsiGenerators` methods you already know this framework comes with full Retina support. Assuming you are familiar with Apple's [High Resolution Guidelines for OS X](http://developer.apple.com/library/mac/#documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Introduction/Introduction.html), there is not much more to say about the matter. Now it's up to you as developer.

# Why?

AnsiLove.framework was created for my app [Escapes](http://escapes.byteproject.net).

# Credits

I'd like to thank my friends [Frederic Cambus](http://www.cambus.net) and [Brian Cassidy](http://blog.alternation.net/) for their ongoing support. Both had a major impact on [AnsiLove/C](https://github.com/ByteProject/AnsiLove-C) and thus on AnsiLove.framework. While Fred is also responsible for [AnsiLove/C's](https://github.com/ByteProject/AnsiLove-C) well-known ancestor [AnsiLove/PHP](http://ansilove.sourceforge.net/), significant parts of Brian's [libsauce](https://github.com/bricas/libsauce) breathe life into `ALSauceMachine`. Finally I bow to all the great ANSi / ASCII lovers and artists around the world. You are the artscene. You keep alive what was not meant to die years ago. YOU ARE ROCKSTARS!

# License

Ascension is released under a MIT-style license. See the file `LICENSE` for details.
