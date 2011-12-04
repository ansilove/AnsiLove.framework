# AnsiLove.framework

This is Cocoa framework I consider as modern approach of bringing back the good old days™. It's capable of rendering ANSi art, interpreting SAUCE records and it consists of two Classes: `ALAnsiGenerator` and `ALSauceMachine`. As it's name implies, `ALAnsiGenerator` creates PNG images from ANSi source files by using a modified version of [Frederic Cambus'](http://www.cambus.net) awesome [AnsiLove](http://ansilove.sourceforge.net) as library. While `ALAnsiGenerator` is more likely a Cocoa layer, the [AnsiLove](http://ansilove.sourceforge.net) library under the surface is a PHP commandline utility. PHP CLI (installed by default on Mac OS X Lion) is used to process given files. What with one thing and another, PNG images are read-only. `ALSauceMachine` is retrieving SAUCE records from files and provides these values as Objective-C 2.0 properties. Being nearly a hundred percent Cocoa (with some C magic), I built `ALSauceMachine` on solid ground. It's foundation is based on [libsauce](https://github.com/bricas/libsauce) by [Brian Cassidy](http://blog.alternation.net/).

# Version info

Current framework release: `1.4.0` - rendering library forked from: [AnsiLove](http://ansilove.sourceforge.net) `1.09`

# Features

- Automatic Reference Counting (ARC)
- Mac App Store conform
- App Sandboxing support
- ANSi (.ANS) rendering
- PCBOARD (.PCB) rendering
- BiNARY (.BIN) rendering
- ADF (.ADF) rendering (Artworx)
- iDF (.IDF) rendering (iCE Draw)
- TUNDRA (.TND) rendering [details](http://sourceforge.net/projects/tundradraw)
- XBiN (.XB) rendering [details](http://www.acid.org/info/xbin/xbin.htm)
- RELEASE info (.NFO/.DIZ) rendering
- ASCII (.ASC) rendering
- SAUCE records support
- DOS fonts support
- Amiga fonts support
- iCE colors support
- Small output file size (4-bit PNG)

# Charsets

IBM PC (Code page 437), Baltic (Code page 775), Cyrillic (Code page 855), French Canadian (Code page 863), Greek (Code pages 737 and 869), Hebrew (Code page 862), Icelandic (Code page 861), Latin-1 (Code page 850), Latin-2 (Code page 852), Nordic (Code page 865), Portuguese (Code page 860), Russian (Code page 866), Turkish (Code page 857), Armenian (unofficial), Persian / Iran system encoding (unofficial)

# Documentation

Let's talk about using this framework in your own projects. First of all, you have to download the sources and compile the framework. You need at least Mac OS X Lion and Xcode 4.2 for this purpose. The project contains two build targets, the framework itself and a test app `AnsiLoveGUI`, the latter is optional. Select `AnsiLoveGUI` from the Schemes dropdown in Xcode if you desire to compile that one too. The test app is a good example of implementing the AnsiLove.framework, it does not contain much code and what you find there is well commented. So `AnsiLoveGUI` might be your first place to play with the framework after studying this documentation. Basically this is an ARC framework. As far as I can estimate it will compile just fine with Garbage Collector enabled, though the test app is a pure ARC project. 

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

To transform any ANSi source file into a beautiful PNG image, there is only one method you need to know:

	+ (void)createPNGFromAnsiSource:(NSString *)inputFile 
						 outputFile:(NSString *)outputFile
						 	columns:(NSString *)columns
						 	   font:(NSString *)font 
						 	   bits:(NSString *)bits
						  iceColors:(NSString *)iceColors

You can call said method like this:

	[ALAnsiGenerator createPNGFromAnsiSource:self.myInputFile 
                                  outputFile:self.myOutputFile 
                                     columns:self.myColumns 
                                        font:self.myFont 
                                        bits:self.myBits 
                                   iceColors:self.myIceColors];

Keep in mind that ALAnsiGenerator needs all it's flags as `NSString` instances. You can work internally with numeric types like `NSInteger` or `BOOL` but you need to convert them to strings before you pass these values to ALAnsiGenerator. For example, the `iceColors` flag (I'm going to explain all flags in detail below) can only be `0` or `1`, so it's perfect to have that as `BOOL` type in your app. I did this in `AnsiLoveGUI` as well. To pass this value to ALAnsiGenerator you can do it something like this:

	NSString *iceColors;
	BOOL	 shouldUseIceColors;

	if (shouldUseIceColors == NO) {
        	self.iceColors = @"0";
    	}
    	else {
        	self.iceColors = @"1";
    	}

Note that all flags except `inputFile` are optional. You can either decide to pass `nil` to flags you don't need (AnsiLove.framework will then work with it's default values) or you just pass empty strings like:

	self.myFontString = @"";
	
The AnsiLove.framework will silently consume `nil` and empty string values but it will rely on it's built-in defaults in both cases. Clever? I think so, too. Now that you know the basics, let's head over to the details. The `createPNGFromAnsiSource:` seems like a pretty simple method but in fact it's so damn powerful if you know how to deal with the flags and that is what I'm going to teach you now.

## (NSString *)inputFile

The only necessary flag you need to pass to ALAnsiGenerator. Well, that's logic. If there is no input file, what should be the output? I see you get it. Here is an example for a proper `inputFile` string:

	/Users/Stefan/Desktop/MyAnsiArtwork.ans
	
I recommend treating this string case-sensitive.  As you can see, that string explicitly needs to contain the path and the file name. That's pretty cool because it means you can work either with `NSStrings` or `NSURLs` internally. Just keep in mind that any `NSURL` needs to be converted to a string before passing to ALAnsiGenerator. NSURL has a method called `absoluteString` that can be used for easy conversion.
	
	NSURL 	 *myURL;
	NSString *urlString = [myURL absoluteString];

But the AnsiLove.framework can do even more at this point, it will resolve a tilde in any provided `inputFile` string instance without a problem. So let's have a look at the proper `inputFile` string again, this would be the same:

	~/Desktop/MyAnsiArtwork.ans

Simple, elegant, comfortable, just working. That's what Cocoa is all about.

## (NSString *)outputFile

Formatting of the `outputFile` string is identical to the `inputFile` string. There is only one difference: `outputFile` is optional. If you don't set this flag, the framework will use the same path / file name you passed as `inputFile` string, but it will add .PNG as suffix. If you plan to output your PNG into a different directory and / or under a different filename, then of course you have to set this flag.

## (NSString *)columns

`columns` are only for ANSi source files with `.bin` extension and even for those files optional. In most cases conversion will work fine if you don't set this flag, the default value is `160` then. So please pass `columns` only to .bin files and only if you exactly know what you're doing. A KITTEN MAY DIE SOMEWHERE.

## (NSString *)font

The AnsiLove.framework generates the most accurate rendering of ANSi sources you've ever seen on a modern computer. Not aiming, it does. That's a fact. It comes with two font families both originating from the golden age of ANSi artists. These font families are `PC` and `AMIGA`, the latter restricted to 8-bit only. Let's have a look at the flags you can pass as `font` string.

`PC` fonts can be (all case-sensitive):

- `80x25` (code page 437)
- `80x50` (code page 437, 80x50 mode)
- `armenian`
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
- `persian` (Iran System encoding standard)
- `portuguese` (Code page 860)
- `russian` (code page 866)
- `terminus` (modern font, code page 437)
- `turkish` (code page 857)

`AMIGA` fonts can be (all case-sensitive):

- `amiga` (alias to Topaz)
- `b-strict` (Original B-Strict font)
- `b-struct` (Original B-Struct font)
- `microknight` (Original MicroKnight version)
- `microknightplus` (Modified MicroKnight version)
- `mosoul` (Original mO'sOul font)
- `pot-noodle` (Original P0T-NOoDLE font)
- `topaz` (Original Topaz Kickstart 2.x version)
- `topazplus` (Modified Topaz Kickstart 2.x+ version)
- `topaz500` (Original Topaz Kickstart 1.x version)
- `topaz500plus` (Modified Topaz Kickstart 1.x version)

If you don't set the `font` flag by either passing `nil` or an empty string to ALAnsiGenerator, the AnsiLove.framework will generate the PNG with `80x25`, which is the default `font` value.

## (NSString *)bits

Bits can be (all case-sensitive): 

- `8` (8-bit)
- `9` (9-bit)
- `ced`
- `transparent`
- `workbench`

Now what's this all about you may ask? I will tell you. 

Setting the bits to `9` will render the 9th column of block characters, so the output will look like it is displayed in real textmode. 

Setting the bits to `ced` will cause the input file to be rendered in black on gray, and limit the output to 78 columns (only available for `.ans` files). Used together with an `AMIGA` font, the output will look like it is displayed on Amiga.

Setting the bits to `workbench` will cause the input file to be rendered using Amiga Workbench colors (only available for `.ans` files).

Settings the bits to `transparent` will produce output files with transparent background (only available for `.ans` files).

## (NSString *)iceColors

As I have already written above, `iceColors` can only be `0` or `1`. All other string values for `iceColors` will be silently consumed and thankfully ignored. Setting `iceColors` to `1` will enable them. On the opposite `0` means that that `iceColors` are disabled, which is the default value. So if you don't want to enable them, there's no need to pass a value to ALAnsiGenerator. To understand how to handle this flag you need to know more about iCE colors. So what is iCE colors? Are we talking about something that renders my ANSi source in an alternative color scheme? Well, yes and no, but more no than yes. Huh? Okay, I'll explain. When an ANSi source was created using iCE color codes, it was done with a special mode where the blinking was disabled, and you had 16 background colors available. Basically, you had the same choice for background colors as for foreground colors, that's iCE colors. But now the important part: when the ANSi source does not make specific use of iCE colors, you should NOT set this flag. The file could look pretty weird in normal mode. So in most cases it's fine to leave this flag alone. 

## Supported options for each file type

Now that you know about the different flags, you may also want to have a simple overview of which file type supports which flag. No problem, here you are:

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

You may wonder how the rendered output looks like? You'll find an example [here](http://cl.ly/1G2i2x3v2Z0n3u28433e/o).

# Reading SAUCE records

Let's head over to `ALSauceMachine`, the framework's class for dealing with SAUCE records. Before we continue, here's your opportunity to introduce yourself to the [SAUCE specifications](http://www.acid.org/info/sauce/s_spec.htm). Plenty values retrieved from SAUCE records can be passed as flags to `ALAnsiGenerator`, so it absolutely makes sense to check for a SAUCE record before you start rendering a file. However, this is just a hint of mine. It's convenient but by no means necessary to check for SAUCE before you start rendering. Enough theory, I'm sure you want to know how to finally use the class. First we need to create an instance of `ALSauceMachine`:

	 ALSauceMachine *sauce = [[ALSauceMachine alloc] init];
	 
Now you can call `readRecordFromFile:`, this should be self-explanatory:

	[sauce readRecordFromFile:myInputFile];

You probably guess that not all files contain SAUCE and you're right. Many ANSi files actually contain SAUCE (like [this file](http://sixteencolors.net/pack/acid-56/W7-R666.ANS)) and some just don't. But how do I know what's going on afterwards? I've implemented three handy BOOL values, an effective way for you to get all feedback you need concerning the file: 

	BOOL fileHasRecord;
	BOOL fileHasComments;
	BOOL fileHasFlags;
	
The first property, `fileHasRecord` is above the others, which means if a given file doesn't have a SAUCE record at all, it's evident it doesn't have SAUCE comments and flags. My advice: don't check `fileHasComments` and `fileHasFlags` if you already know there is no SAUCE record. Don't get my wrong, nothing will explode if you do so. Anyway, we are talking about a pure waste of time because the answer will always be NO in that case. What if a file contains a SAUCE record on the other hand? It's nevertheless possible it doesn't have comments and flags. So if `fileHasRecord` is YES, you should try the other two BOOL values as well. Let's assume your class instance is still `*sauce` and you now checked for all three BOOL types, knowing the details. How to retrieve the SAUCE? Easy. `ALSauceMachine` stores the SAUCE record into properties, right at your feet:

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
	
That's it. If you feel like this introduction to AnsiLove.framework's SAUCE implementation left some of your questions unanswered, I suggest you take a closer look at the sample app. `AnsiLoveGUI` contains a full featured yet simple example how to use `ALSauceMachine`. 

# App Sandboxing

Basically the framework works great in sandboxed apps. `AnsiLoveGUI` comes with App Sandboxing enabled and the interface is designed to aquire user selected read.write permission through NSOpenPanel and NSSavePanel instances. You may want to investigate the file `AnsiLoveGUI.entitlements` to see what kind of entitlements your app explicitly needs when using AnsiLove.framework. You should notice two temporary exceptions, these are not directly related to the framework. When invoking `/usr/bin/php` in sandboxed environments you get sandboxd violations for `/private/etc/protocols` and `/private/var/db/net-snmp`. This is caused by the PHP CLI and I filed rdar://10436809 regarding the issue.

# Todo

Implementation for writing and deleting SAUCE records.

# Last words

Even though the AnsiLove.framework works well, I suggest you visit this repository now and then. It's very likely I'm adding new stuff to it. New [AnsiLove](http://ansilove.sourceforge.net) releases will be forked into the codebase as well as any other ANSi related stuff I might consider as useful addition. The AnsiLove.framwork was created with the vision of implementing it into one of my own apps, most of you know [Ascension](http://byteproject.net/ascension) already. You can imagine it's my goal to constantly improve this framework.

# Credits

I bow to [Frederic Cambus](http://www.cambus.net). Without his passion and his work on [AnsiLove](http://ansilove.sourceforge.net) this framework would never have been possible. He spent countless hours and years with coding and testing. I, for one, adapted his work and created a Cocoa layer on top of it, which took me effectively three days in it's inital form. So first of all: don't thank me, please thank [Frederic](http://www.cambus.net) and if you find the AnsiLove.framework useful please consider making a donation to [AnsiLove](http://ansilove.sourceforge.net). 

I also admire [Brian Cassidy](http://blog.alternation.net/) for his efforts, not only for his work on [libsauce](https://github.com/bricas/libsauce), which helped me a lot to understand how to handle SAUCE, but also for what he's doing over at [sixteencolors](http://sixteencolors.net).

Thanks fly out to the all you people around the world that are downloading [Ascension](http://byteproject.net/ascension) more than hundred times a day since I released it. You guys are the reason I did this. 

Also, cheers to all the great ASCII / ANSi artists around the world. You are the artscene. You keep alive what was not meant to die years ago. YOU ROCK!

# License

Ascension is released under a MIT-style license. See the file `LICENSE` for details.
