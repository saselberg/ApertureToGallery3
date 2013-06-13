//
//  ApertureToGallery3.m
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/2/11.

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

#import "ApertureToGallery3.h"


@implementation ApertureToGallery3
@synthesize gallery;
@synthesize galleryDirectory;
@synthesize rootGalleryAlbum;
@synthesize galleryApiKey;
@synthesize cancel;
//@synthesize uploadedPhotos;
//@synthesize photoCount;
@synthesize currentItem;
@synthesize waterMarkImageName;

//---------------------------------------------------------
// initWithAPIManager:
//
// This method is called when a plug-in is first loaded, and
// is a good point to conduct any checks for anti-piracy or
// system compatibility. This is also your only chance to
// obtain a reference to Aperture's export manager. If you
// do not obtain a valid reference, you should return nil.
// Returning nil means that a plug-in chooses not to be accessible.
//---------------------------------------------------------

- (id)initWithAPIManager:(id<PROAPIAccessing>)apiManager
{
	if ((self = [super init]))
	{
		_apiManager	= apiManager;
		_exportManager = [[_apiManager apiForProtocol:@protocol(ApertureExportManager)] retain];
		if (!_exportManager)
			return nil;
		
        _progressLock = [[NSLock alloc] init];
		
        // Stuff for the gallery connection
        self.cancel   = false;
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
        
        
        //Stuff for the export
        // Create our temporary directory
		tempDirectoryPath = [[NSString stringWithFormat:@"%@/Gallery3Export/", NSTemporaryDirectory()] retain];
		
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
        
        addPhotoQueue    = [[NSMutableArray alloc] init];
        retryPhotoQueue  = [[NSMutableArray alloc] init];
        donePhotoQueue   = [[NSMutableArray alloc] init];
        errorPhotoQueue  = [[NSMutableArray alloc] init];
        uploadRetries    = [NSNumber numberWithInt:2];
	}	
    
	return self;
}

- (void)dealloc
{
    // Release the top-level objects from the nib.
	[_topLevelNibObjects makeObjectsPerformSelector:@selector(release)];
	[_topLevelNibObjects release];
	
	
    self.gallery                  = nil;
    self.rootGalleryAlbum         = nil;
    self.galleryApiKey            = nil;
    self.galleryDirectory         = nil;
    self.currentItem              = nil;
    self.waterMarkImageName       = nil;
//    self.photoCount               = nil;
//    self.uploadedPhotos           = nil;
    [addPhotoQueue release];
    [retryPhotoQueue release];
    [donePhotoQueue release];
    [errorPhotoQueue release];
    
    [preferences release];
    preferences = nil;
    
    // Clean up the temporary files
    [[NSFileManager defaultManager] removeItemAtPath:tempDirectoryPath error:nil];
	[tempDirectoryPath release];
    
    [exportProgress.message autorelease];
    
	[_progressLock release];
	[_exportManager release];
    
	[super dealloc];
}


#pragma mark -
// UI Methods
#pragma mark UI Methods

- (NSView *)settingsView
{
	if (nil == settingsView)
	{
		// Load the nib using NSNib, and retain the array of top-level objects so we can release
		// them properly in dealloc
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"ApertureToGallery3" bundle:myBundle];
		if ([myNib instantiateNibWithOwner:self topLevelObjects:&_topLevelNibObjects])
		{
			[_topLevelNibObjects retain];
            if( [galleryDirectory count] > 0 )
            {
                [galleryDirectoryController setSelectionIndex:[selectedGalleryIndex integerValue]];
                selectedGallery            = [[galleryDirectoryController selectedObjects] objectAtIndex:0];
                self.gallery.galleryApiKey = selectedGallery.key;
                self.gallery.url           = selectedGallery.url;
                self.gallery.bGalleryValid = false;
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
                                          [versionTracker.ApertureToGalleryVersion doubleValue], 
                                          [versionTracker.RestfulGalleryVersion doubleValue] ] ];
        }
        [myNib release];        
	}
	
	return settingsView;
}

- (NSView *)firstView
{
	return firstView;
}

- (NSView *)lastView
{
	return lastView;
}

- (void)willBeActivated
{
}

- (void)willBeDeactivated
{
}

#pragma mark
// Aperture UI Controls
#pragma mark Aperture UI Controls

- (BOOL)allowsOnlyPlugInPresets
{
	return NO;	
}

- (BOOL)allowsMasterExport
{
	return YES;	
}

- (BOOL)allowsVersionExport
{
	return YES;	
}

- (BOOL)wantsFileNamingControls
{
	return YES;	
}

- (void)exportManagerExportTypeDidChange
{
	// Nothing to do here - this plug-in doesn't show the user any information about the selected images,
	// so there's no need to see if the count or properties changed here.
}


#pragma mark -
// Save Path Methods
#pragma mark Save/Path Methods

- (BOOL)wantsDestinationPathPrompt
{
	// We have already destermined a temporary destination for our images and we delete them as soon as
	// we're done with them, so the user should not select a location.
	return NO;
}

- (NSString *)destinationPath
{
	return tempDirectoryPath;
}

- (NSString *)defaultDirectory
{
	// Since this plug-in is not asking Aperture to present an open/save dialog,
	// this method should never be called.
	return nil;
}


#pragma mark -
// Export Process Methods
#pragma mark Export Process Methods

- (void)exportManagerShouldBeginExport
{
	// Before telling Aperture to begin generating image data, test the connection using the user-entered values
    if( gallery.bGalleryValid )
    {
        self.cancel = false;
        [self lockProgress];
        exportProgress.totalValue = [_exportManager imageCount];
        exportProgress.currentValue = 1;
        exportProgress.indeterminateProgress = NO;
        [exportProgress.message autorelease];
        exportProgress.message = [[NSString stringWithFormat:@"Step 1 of 2: Preparing Images..."] retain];
        [self unlockProgress];
                
        // The test was successful, we have set the progress correctly, and are ready for Aperture to begin generating image data.
        [_exportManager shouldBeginExport];
    }
}

- (void)exportManagerWillBeginExportToPath:(NSString *)path
{
	// Nothing to do here. We could test the path argument and confirm that it's the same path we passed, but that's not really necessary.
}

- (BOOL)exportManagerShouldExportImageAtIndex:(unsigned)index
{
	// This plug-in doesn't exclude any images for any reason, so it always returns YES here.
	return YES;
}

- (void)exportManagerWillExportImageAtIndex:(unsigned)index
{
	// Nothing to do here - this is just a confirmation that we returned YES above. We could
	// check to make sure we get confirmation messages for every image.
}

- (BOOL)exportManagerShouldWriteImageData:(NSData *)imageData toRelativePath:(NSString *)path forImageAtIndex:(unsigned)index
{
	return YES;	
}

- (void)exportManagerDidWriteImageDataToRelativePath:(NSString *)relativePath forImageAtIndex:(unsigned)index
{
    if (!exportedImagePaths)
	{
		exportedImagePaths = [[NSMutableArray alloc] initWithCapacity:[_exportManager imageCount]];
	}
	
	// Save the paths of all the images that Aperture has exported
	NSString *imagePath = [NSString stringWithFormat:@"%@%@", tempDirectoryPath, relativePath];
	[exportedImagePaths addObject:imagePath];
	
	// Increment the current progress
	[self lockProgress];
	exportProgress.currentValue++;
	[self unlockProgress];    
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
- (void)exportManagerDidFinishExport
{
    // You must call [_exportManager shouldFinishExport] before Aperture will put away the progress window and complete the export.
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling. 
    
    [self watermarkImages];
    
    GalleryAlbum *selectedAlbum;
    selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    [fileManager fileExistsAtPath:tempDirectoryPath isDirectory:&isDirectory];
    if (isDirectory)
    {
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempDirectoryPath error:nil];
        int i;
        for (i = 0; i < [contents count]; i++)
        {
            NSString *tempFilePath = [NSString stringWithFormat:@"%@%@", tempDirectoryPath, [contents objectAtIndex:i]];
            AddPhotoQueueItem *item = [[AddPhotoQueueItem alloc] initWithUrl:selectedAlbum.url andPath:tempFilePath 
                                                                 andParameters:[NSMutableDictionary 
                                                                              dictionaryWithObjects:[NSArray arrayWithObjects:[tempFilePath lastPathComponent], @"", nil] 
                                                                              forKeys:[NSArray arrayWithObjects:@"title", @"description", nil ]]];
            [addPhotoQueue addObject:item];
            [item release];
        }
//        [NSThread detachNewThreadSelector:@selector(startExportInNewThread) toTarget:self withObject:nil];
        [self processAddPhotoQueue];
    }
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

- (void)exportManagerShouldCancelExport
{
	// You must call [_exportManager shouldCancelExport] here or elsewhere before Aperture will cancel the export process
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up		
	// any callbacks or running threads before calling.
  
    self.cancel = true;
    [gallery cancel];    
    [_exportManager shouldCancelExport];
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
            self.currentItem.uploadAttempts = [NSNumber numberWithInt:[self.currentItem.uploadAttempts intValue] + 1 ];
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
    [self lockProgress];
	exportProgress.currentValue = totalBytesWritten;
	exportProgress.totalValue = totalBytesExpectedToWrite;
	[self unlockProgress];
}

- (void) processAddPhotoQueue
{
    if( !self.cancel )
    {
        if( [[NSNumber numberWithInteger:[retryPhotoQueue count]] isGreaterThan:[NSNumber numberWithInteger:0]] )
        {
            [self lockProgress];
            exportProgress.currentValue = 0;
            [exportProgress.message autorelease];
            exportProgress.message = [[NSString stringWithFormat:@"Step 2 of 2: Uploading Image %ld of %ld (retry %d)", 
                                       [donePhotoQueue count] + [errorPhotoQueue count] + 1,
                                       [addPhotoQueue count]  + [retryPhotoQueue count] 
                                       + [donePhotoQueue count] + [errorPhotoQueue count],
                                       + [currentItem.uploadAttempts intValue] ] retain];
            [self unlockProgress];
            
            self.currentItem = [retryPhotoQueue objectAtIndex:0];
            [retryPhotoQueue removeObjectAtIndex:0];
            [gallery addPhotoAtPath:self.currentItem.path toUrl:self.currentItem.url withParameters:self.currentItem.parameters];
        }
        else if( [[NSNumber numberWithInteger:[addPhotoQueue count]] isGreaterThan:[NSNumber numberWithInteger:0]] )
        {
            [self lockProgress];
            exportProgress.currentValue = 0;
            [exportProgress.message autorelease];
            exportProgress.message = [[NSString stringWithFormat:@"Step 2 of 2: Uploading Image %ld of %ld", 
                                       [donePhotoQueue count] + [errorPhotoQueue count] + 1, 
                                       [addPhotoQueue count]  + [retryPhotoQueue count] 
                                       + [donePhotoQueue count] + [errorPhotoQueue count]] retain];
            [self unlockProgress];

            self.currentItem = [addPhotoQueue objectAtIndex:0];
            [addPhotoQueue removeObjectAtIndex:0];
            [gallery addPhotoAtPath:self.currentItem.path toUrl:self.currentItem.url withParameters:self.currentItem.parameters];
        }
        else
        {
//            [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:YES];
            [self done];
            running = NO;
        }
    }
}

- (void) done
{
    AddPhotoQueueItem* info;
    NSMutableArray* errorNames = [NSMutableArray arrayWithCapacity:[errorPhotoQueue count]];
    
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
    [_exportManager shouldFinishExport];        
    
}

#pragma mark -
// Progress Methods
#pragma mark Progress Methods

- (ApertureExportProgress *)progress
{
	return &exportProgress;
}

- (void)lockProgress
{
	
	if (!_progressLock)
		_progressLock = [[NSLock alloc] init];
    
	[_progressLock lock];
}

- (void)unlockProgress
{
	[_progressLock unlock];
}

/************************************************************
 / Gallery actions
 ************************************************************/

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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8XJS7R8SCZMVU"]];
}

- (IBAction)clickGoGitHub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://saselberg.github.com/ApertureToGallery3"]];
}

- (IBAction)selectWatermarkImage:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTreatsFilePackagesAsDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel beginSheetModalForWindow:[_exportManager window] completionHandler:^(NSInteger result) {
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
 /  Manage window sheets
 ************************************************************/
-(IBAction)showManageGalleries:(id)sender
{
    [NSApp beginSheet:manageGalleriesWindow modalForWindow:[_exportManager window] modalDelegate:self didEndSelector:NULL contextInfo:nil];    
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
    [NSApp beginSheet:addAlbumWindow modalForWindow:[_exportManager window] modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideAddAlbum:(id)sender
{
    [addAlbumWindow orderOut:nil];
    [NSApp endSheet:addAlbumWindow];     
}

-(IBAction)showAbout:(id)sender
{
    [NSApp beginSheet:aboutWindow modalForWindow:[_exportManager window] modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideAbout:(id)sender
{
    [aboutWindow orderOut:nil];
    [NSApp endSheet:aboutWindow];     
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
