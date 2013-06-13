//
//  AppleToGallery3AppDelegate.m

//  Created by Scott Selberg on 5/16/11.

/*
 Copyright (C) 2013 Scott Selberg
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 */

#import "AppleToGallery3AppDelegate.h"

@implementation AppleToGallery3AppDelegate
@synthesize gallery;
@synthesize galleryDirectory;
@synthesize rootGalleryAlbum;
@synthesize galleryApiKey;
@synthesize currentItem;
@synthesize waterMarkImageName;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (id)init
{
    self = [super init];
    if( self )
    { 
        addPhotoQueue    = [[NSMutableArray alloc] init];
        retryPhotoQueue  = [[NSMutableArray alloc] init];
        donePhotoQueue   = [[NSMutableArray alloc] init];
        errorPhotoQueue  = [[NSMutableArray alloc] init];
        uploadRetries    = [NSNumber numberWithInt:2];

        
        self.gallery  = [[RestfulGallery alloc] init]; 
        self.gallery.delegate = self;
        userDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
        if( userDefaults ){
            preferences = [userDefaults mutableCopy];
            if( [preferences objectForKey:@"GALLERY_DIRECTORY"] ){
                self.galleryDirectory =  [[NSKeyedUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"GALLERY_DIRECTORY"]] mutableCopy];                
            } else {
                self.galleryDirectory = [NSMutableArray arrayWithCapacity:0];
            }
            
            if( [preferences objectForKey:@"SELECTED_GALLERY_INDEX"] ){
                selectedGalleryIndex = [preferences objectForKey:@"SELECTED_GALLERY_INDEX"];
            } else {
                selectedGalleryIndex = [NSNumber numberWithInteger:0];                
            }
        } else {
            preferences = [[NSMutableDictionary alloc] init];
            self.galleryDirectory = [NSMutableArray arrayWithCapacity:0];
            selectedGalleryIndex = [NSNumber numberWithInteger:0];
        }
        
        tempDirectoryPath = [[NSString stringWithFormat:@"%@/AppleToGallery3Export/", NSTemporaryDirectory()] retain];
		
		// If it doesn't exist, create it
		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL isDirectory;
		if (![fileManager fileExistsAtPath:tempDirectoryPath isDirectory:&isDirectory])
		{
            [fileManager createDirectoryAtPath:tempDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		else if (isDirectory) // If a folder already exists, empty it.
		{
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempDirectoryPath error:nil];
			int i;
			for (i = 0; i < [contents count]; i++)
			{
				NSString *tempFilePath = [NSString stringWithFormat:@"%@%@", tempDirectoryPath, [contents objectAtIndex:i]];
                [fileManager removeItemAtPath:tempFilePath error:nil];
			}
		}
		else // Delete the old file and create a new directory
		{
            [fileManager removeItemAtPath:tempDirectoryPath error:nil];
            [fileManager createDirectoryAtPath:tempDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
    }
    return self;
}

- (void)dealloc
{
    
    self.gallery                  = nil;
    self.rootGalleryAlbum         = nil;
    self.galleryApiKey            = nil;
    self.galleryDirectory         = nil;
    self.currentItem              = nil;
    self.waterMarkImageName       = nil;
    [addPhotoQueue release];
    [retryPhotoQueue release];
    [donePhotoQueue release];
    [errorPhotoQueue release];

    // Clean up the temporary files
    [[NSFileManager defaultManager] removeItemAtPath:tempDirectoryPath error:nil];
	[tempDirectoryPath release];
    
    [preferences release];
    preferences = nil;
    
	[super dealloc];
}

- (void)awakeFromNib {
    if( [galleryDirectory count] > 0 )
    {
        [galleryDirectoryController setSelectionIndex:[selectedGalleryIndex integerValue]];
        selectedGallery            = [[galleryDirectoryController selectedObjects] objectAtIndex:0];
        self.gallery.galleryApiKey = selectedGallery.key;
        self.gallery.url           = selectedGallery.url;
        self.gallery.bGalleryValid = false;
        
        [currentProgresssIndicator setMinValue:0.0];
        [currentProgresssIndicator setMaxValue:1.0];
        [totalProgresssIndicator setMinValue:0.0];
        [totalProgresssIndicator setMaxValue:1.0];
    }
    
    if( [preferences valueForKey:@"SELECTED_WATERMARK_MODE"] )
    {
        [watermarkMenu selectItemAtIndex:[[preferences valueForKey:@"SELECTED_WATERMARK_MODE"] integerValue]];
        if( [[preferences valueForKey:@"SELECTED_WATERMARK_MODE"] intValue] == 0 )
        {
            [self enableWatermark:NO];
        }
    } else {
        [watermarkMenu selectItemAtIndex:0];                
        [self enableWatermark:NO];
    }
    
    if( [preferences valueForKey:@"SELECTED_WATERMARK_IMAGE"] )
    {
        [waterMarkImageNameTextField setStringValue:[preferences valueForKey:@"SELECTED_WATERMARK_IMAGE"]];
        self.waterMarkImageName = [preferences valueForKey:@"SELECTED_WATERMARK_IMAGE"];
    }
    
    
    Version *versionTracker = [[[Version alloc] init] autorelease];
    [versionLabel setStringValue:[NSString stringWithFormat:@"Version %03.1f-%03.1f", 
                                  [versionTracker.AppleToGalleryVersion doubleValue], 
                                  [versionTracker.RestfulGalleryVersion doubleValue] ] ];

}


- (IBAction)quit:(id)sender
{
    exit(0);
}

- (IBAction)cancel:(id)sender
{
    cancel = YES;
    [gallery cancel];
    [progressWindow orderOut:nil];
    [NSApp endSheet:progressWindow];     
}

- (IBAction)makeAlbum:(id)sender
{
    NSNumber *localEntityId;
    NSNumber *newColumn;
    NSString *newAlbumUrl;
    NSArray  *albumChildren;
    GalleryAlbum *selectedAlbum;
    
    selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
    
    if( selectedAlbum == nil ){
        [browser selectRow:0 inColumn:0];
        selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
    }
    
    localEntityId = [selectedAlbum entityId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:4];
    [parameters setObject:[albumName  stringValue] forKey:@"name"];
    [parameters setObject:[albumTitle stringValue] forKey:@"title"];
    
    [gallery createAlbumInEntity:localEntityId withParameters:parameters];
    newAlbumUrl= [[gallery results] objectForKey:@"url"];
    
    selectedAlbum.dataIsStale      = true;
    selectedAlbum.childrenAreStale = true;        
    newColumn = [NSNumber numberWithInteger:([browser selectedColumn]+1)];
    albumChildren = [selectedAlbum children];
    
    for (NSInteger col = [browser lastColumn]; col >= 0; col--) {
        [browser reloadColumn:col];
    }
    
    if( [browser lastColumn] < [newColumn integerValue] )
    {
        [browser addColumn];
        [browser scrollColumnsLeftBy:1];
    }
    
    for( int i = 0; i < [albumChildren count]; i++ )
    {
        GalleryAlbum *album = (GalleryAlbum *)[browser itemAtRow:i inColumn:[newColumn integerValue]];
        if( [newAlbumUrl isEqualToString:[album url]] )
        {
            [browser selectRow:i inColumn:[newColumn integerValue]];
            continue;
        }
    }
    
    // clear the text fields
    [albumName  setStringValue:@""];
    [albumTitle setStringValue:@""];
    
    [addAlbumWindow orderOut:nil];
    [NSApp endSheet:addAlbumWindow];     
}

- (IBAction) getApiKey:(id)sender
{
    GalleryInfo *galleryInfo = [[galleryDirectoryController selectedObjects] objectAtIndex:0];
    [gallery getApiKeyforGallery:galleryInfo.url AndUsername:galleryInfo.username AndPassword:[newGalleryPassword stringValue]];
    galleryInfo.key = [gallery.results objectForKey:@"GALLERY_RESPONSE"];
}
- (IBAction)clickDonate:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WAWEU2MMXXY4Q"]];
}

- (IBAction)clickGoGitHub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://saselberg.github.com/ApertureToGallery3"]];
}


/************************************************************
 /  Manage window sheets
 ************************************************************/
-(IBAction)showManageGalleries:(id)sender
{
    [NSApp beginSheet:manageGalleriesWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideManageGalleries:(id)sender
{
    selectedGallery = [[galleryDirectoryController selectedObjects] objectAtIndex:0];
    self.gallery.galleryApiKey = selectedGallery.key;
    self.gallery.url           = selectedGallery.url;
    self.gallery.bGalleryValid = false;
    
    if( ![selectedGalleryIndex isEqualToNumber:[NSNumber numberWithInteger:[galleryDirectoryController selectionIndex]]] )
    {
        rootGalleryAlbum.dataIsStale      = true;
        rootGalleryAlbum.childrenAreStale = true;        
        
        for (NSInteger col = [browser lastColumn]; col >= 0; col--) {
            [browser reloadColumn:col];
        }
    }
    
    selectedGalleryIndex = [NSNumber numberWithInteger:[galleryDirectoryController selectionIndex]];
    [self savePreferences];
    
    [manageGalleriesWindow orderOut:nil];
    [NSApp endSheet:manageGalleriesWindow];     
}

-(IBAction)addGalleryInformation:(id)sender
{
    [galleryDirectoryController add:self];
    [NSApp beginSheet:galleryInformationWindow modalForWindow:manageGalleriesWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)showGalleryInformation:(id)sender
{
    [NSApp beginSheet:galleryInformationWindow modalForWindow:manageGalleriesWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideGalleryInformation:(id)sender
{
    [newGalleryPassword setStringValue:@""];
    
    [galleryInformationWindow orderOut:nil];
    [NSApp endSheet:galleryInformationWindow];     
}

-(IBAction)showAddAlbum:(id)sender
{
    [NSApp beginSheet:addAlbumWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideAddAlbum:(id)sender
{
    [addAlbumWindow orderOut:nil];
    [NSApp endSheet:addAlbumWindow];     
}

- (IBAction)selectImageDirectory:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [openPanel orderOut:self]; // close panel before we might present an error
            [self exportPhotos:[[openPanel URL] path]];
        }
    }];
}

- (void)exportPhotos:(NSString*)fileNode
{
    cancel = NO;
    
    GalleryAlbum *selectedAlbum;
    selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
    
    
    //First, copy files to temporary directory.  This is not necessary in general, but mimics
    //the behavior of the Aperture and iPhoto plugins.  Also important to support the watermarking
    //feature
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    [fileManager fileExistsAtPath:fileNode isDirectory:&isDirectory];
    if(isDirectory){
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:fileNode error:nil];
        int i;
        for (i = 0; i < [contents count]; i++)
        {
            NSData *fileContents = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", fileNode, [contents objectAtIndex:i]]];
            [fileContents writeToFile:[NSString stringWithFormat:@"%@/%@", tempDirectoryPath, [contents objectAtIndex:i]] atomically:NO];
        }
    }
    else {
        NSData *fileContents = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@", fileNode ]];
        [fileContents writeToFile:[NSString stringWithFormat:@"%@/%@", tempDirectoryPath, [fileNode lastPathComponent]] atomically:NO];
    }
    
    [self watermarkImages];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempDirectoryPath error:nil];
    int i;
    for (i = 0; i < [contents count]; i++)
    {
        NSString *tempFilePath = [NSString stringWithFormat:@"%@/%@", tempDirectoryPath, [contents objectAtIndex:i]];
        AddPhotoQueueItem *item = [[AddPhotoQueueItem alloc] initWithUrl:selectedAlbum.url andPath:tempFilePath 
                                                           andParameters:[NSMutableDictionary 
                                                                          dictionaryWithObjects:[NSArray arrayWithObjects:[tempFilePath lastPathComponent], @"", nil] 
                                                                          forKeys:[NSArray arrayWithObjects:@"title", @"description", nil ]]];
        [addPhotoQueue addObject:item];
        [item release];
    }
    
    [totalProgresssIndicator setMaxValue:[addPhotoQueue count]];
    [NSApp beginSheet:progressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];  
    
    [NSThread detachNewThreadSelector:@selector(startExportInNewThread) toTarget:self withObject:nil];
}

// this is necessary as the NSURLConnection does not work well except in NSDefaultRunLoopMode - which is not the modal panel run mode.
-(void)startExportInNewThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self processAddPhotoQueue];
    running = YES;
    while(running) {
        if( ![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100000]] )
        {
            break;
        }
    }    
    [pool release];    
}



- (void)got:(NSMutableDictionary *)myResults;
{
    if( [[myResults valueForKey:@"HAS_ERROR"] boolValue] )
    {
        if( ( [self.currentItem.uploadAttempts intValue] ) >= [uploadRetries intValue] )
        {
            [errorPhotoQueue addObject:currentItem];
        } 
        else
        {
            currentItem.uploadAttempts = [NSNumber numberWithInt:[currentItem.uploadAttempts intValue] + 1 ];
            [retryPhotoQueue addObject:currentItem];
        }
    }
    else
    {
        [donePhotoQueue addObject:currentItem];
    }
    
    [self processAddPhotoQueue];
}

- (void) updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [currentProgresssIndicator setDoubleValue:((double)totalBytesWritten)/((double)totalBytesExpectedToWrite) ];
    [totalProgresssIndicator setDoubleValue:(double)([donePhotoQueue count] + [errorPhotoQueue count]) + ((double)totalBytesWritten)/((double)totalBytesExpectedToWrite) ];
}

- (void) processAddPhotoQueue
{
    if( !cancel )
    {
        if( [[NSNumber numberWithInteger:[retryPhotoQueue count]] isGreaterThan:[NSNumber numberWithInteger:0]] )
        {
            self.currentItem = [retryPhotoQueue objectAtIndex:0];
            [progress setStringValue:[NSString stringWithFormat:@"Transfering Photo %ld of %ld\n\n%@",
                                      ([donePhotoQueue count] + [errorPhotoQueue count] + 1),
                                      ([addPhotoQueue count] + [retryPhotoQueue count] + [donePhotoQueue count] + [errorPhotoQueue count]),
                                      [self.currentItem.path lastPathComponent] ]];
            [retryPhotoQueue removeObjectAtIndex:0];
            [gallery addPhotoAtPath:self.currentItem.path toUrl:self.currentItem.url withParameters:self.currentItem.parameters];

        }
        else if( [[NSNumber numberWithInteger:[addPhotoQueue count]] isGreaterThan:[NSNumber numberWithInteger:0]] )
        {
            self.currentItem = [addPhotoQueue objectAtIndex:0];
            [progress setStringValue:[NSString stringWithFormat:@"Transfering Photo %lu of %lu\n\n%@",
                                      ([donePhotoQueue count] + [errorPhotoQueue count] + 1), 
                                      ([addPhotoQueue count] + [retryPhotoQueue count] + [donePhotoQueue count] + [errorPhotoQueue count]),
                                      [self.currentItem.path lastPathComponent] ]];
            [addPhotoQueue removeObjectAtIndex:0];
            [gallery addPhotoAtPath:self.currentItem.path toUrl:self.currentItem.url withParameters:self.currentItem.parameters];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:YES];
            running = NO;
        }
    }
}

- (void) done
{    
    AddPhotoQueueItem* info;
    NSMutableArray* errorNames = [NSMutableArray arrayWithCapacity:[errorPhotoQueue count]];

    [progressWindow orderOut:nil];
    [NSApp endSheet:progressWindow];     
    
    GalleryAlbum *selectedAlbum;
    selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
    
    if( [errorPhotoQueue count] > 0 )
    {
        NSEnumerator* enumerator = [errorPhotoQueue objectEnumerator];
        while ((info = [enumerator nextObject])) {
            [errorNames addObject:[info.path lastPathComponent]];
        }
        
        NSString* errorMessage     = [NSString stringWithFormat:@"Failed to upload %ld images:", (unsigned long)[errorPhotoQueue count]];
        NSString* errorDescription = [NSString stringWithFormat:[errorNames componentsJoinedByString:@"\n"]];
        NSAlert* alert = [NSAlert alertWithMessageText:errorMessage  
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil
                             informativeTextWithFormat:errorDescription];
        [alert runModal];
    }
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[selectedAlbum webUrl]]];
    
}

-(IBAction)showAbout:(id)sender
{
    [NSApp beginSheet:aboutWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideAbout:(id)sender
{
    [aboutWindow orderOut:nil];
    [NSApp endSheet:aboutWindow];     
}

- (void) watermarkImages
{
    if( [watermarkMenu indexOfSelectedItem] > 0 )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if( [fileManager fileExistsAtPath:self.waterMarkImageName] )
        {
            NSFileManager *fileManager2 = [NSFileManager defaultManager];
            BOOL isDirectory;
            [fileManager2 fileExistsAtPath:tempDirectoryPath isDirectory:&isDirectory];
            if (isDirectory)
            {
                NSArray *contents = [fileManager2 contentsOfDirectoryAtPath:tempDirectoryPath error:nil];
                for (int i = 0; i < [contents count]; i++)
                {
                    NSString *tempFilePath = [NSString stringWithFormat:@"%@%@", tempDirectoryPath, [contents objectAtIndex:i]];
                    [self.gallery waterMarkImage:tempFilePath with:self.waterMarkImageName andTransformIndex:[watermarkMenu indexOfSelectedItem]];
                }
            }
        }
    }
}

- (IBAction)selectWatermarkImage:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [openPanel orderOut:self]; // close panel before we might present an error
            self.waterMarkImageName = [[openPanel URL] path];
            [waterMarkImageNameTextField setStringValue:self.waterMarkImageName];
            [self savePreferences];
        }
    }];        
}

-(IBAction)selectNoWatermark:(id)sender{[self enableWatermark:NO];}
-(IBAction)selectScaledWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectTopLeftWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectTopCenterWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectTopRightWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectMiddleLeftWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectMiddleCenterWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectMiddleRightWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectBottomLeftWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectBottomCenterWatermark:(id)sender{[self enableWatermark:YES];}
-(IBAction)selectBottomRightWatermark:(id)sender{[self enableWatermark:YES];}

-(void)enableWatermark:(BOOL)bEnable
{
    [waterMarkImageNameTextField setEnabled:bEnable];
    [browseForWaterMarkButton    setEnabled:bEnable];
    [self savePreferences];
}


/************************************************************
 /  Methods to enable the browser
 ************************************************************/
- (id)rootItemForBrowser:(NSBrowser *)browser
{
#pragma unused (browser)
    //        NSLog( @"rootItemForBrowser" );
    if (rootGalleryAlbum == nil) {
        rootGalleryAlbum = [[GalleryAlbum alloc] initWithGallery:gallery andEntityId:[NSNumber numberWithInteger:0]];
    }
    return rootGalleryAlbum;    
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item 
{
#pragma unused (browser)
    //        NSLog( @"browser:numberOfChidrenOfItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return [album numberOfChildren];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
#pragma unused (browser)
    //        NSLog( @"browser:child:index:ofItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return [album.children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
#pragma unused (browser)
    //        NSLog( @"browser:isLeafItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return !album.hasChildren;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
#pragma unused (browser)
    //        NSLog( @"objectValueForItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return album.displayName;
}

- (void)savePreferences {
    [preferences setObject:[NSKeyedArchiver archivedDataWithRootObject:galleryDirectory] forKey:@"GALLERY_DIRECTORY"];    
    [preferences setObject:selectedGalleryIndex forKey:@"SELECTED_GALLERY_INDEX"];
    [preferences setObject:[NSNumber numberWithInteger:[watermarkMenu indexOfSelectedItem]] forKey:@"SELECTED_WATERMARK_MODE"];
    [preferences setObject:[waterMarkImageNameTextField stringValue] forKey:@"SELECTED_WATERMARK_IMAGE"];

    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass: [self class]] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:preferences forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
}

@end
