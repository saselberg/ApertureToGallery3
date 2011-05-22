//
//  TestHarnessAppDelegate.m
//  TestHarness
//
//  Created by Scott Selberg on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestHarnessAppDelegate.h"

@implementation TestHarnessAppDelegate
@synthesize gallery;
@synthesize galleryDirectory;
@synthesize rootGalleryAlbum;
@synthesize galleryApiKey;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (id)init
{
    self = [super init];
    if( self )
    { 

        addPhotoQueue = [[NSMutableArray alloc] init];
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
    }
    return self;
}

- (void)dealloc
{
		
    self.gallery                  = nil;
    self.rootGalleryAlbum         = nil;
    self.galleryApiKey            = nil;
    self.galleryDirectory         = nil;
    [addPhotoQueue release];
    
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
}


- (IBAction)quit:(id)sender
{
    exit(0);
}

- (IBAction)cancel:(id)sender
{
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
            [self exportPhotos:[openPanel filename]];
        }
    }];
}

- (void)exportPhotos:(NSString*)fileNode
{
    GalleryAlbum *selectedAlbum;
    selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    [fileManager fileExistsAtPath:fileNode isDirectory:&isDirectory];
    
    if(isDirectory){
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:fileNode error:nil];
        int i;
        for (i = 0; i < [contents count]; i++)
        {
            NSString *tempFilePath = [NSString stringWithFormat:@"%@/%@", fileNode, [contents objectAtIndex:i]];
            AddPhotoQueueItem *item = [[AddPhotoQueueItem alloc] initWithUrl:selectedAlbum.url andPath:tempFilePath 
                                                               andParameters:[NSMutableDictionary 
                                                                              dictionaryWithObjects:[NSArray arrayWithObjects:[tempFilePath lastPathComponent], @"", nil] 
                                                                              forKeys:[NSArray arrayWithObjects:@"title", @"description", nil ]]];
            [addPhotoQueue addObject:item];
            [item release];
        }
    }
    else {
        AddPhotoQueueItem *item = [[AddPhotoQueueItem alloc] initWithUrl:selectedAlbum.url andPath:fileNode 
                                                           andParameters:[NSMutableDictionary 
                                                                          dictionaryWithObjects:[NSArray arrayWithObjects:[fileNode lastPathComponent], @"", nil] 
                                                                          forKeys:[NSArray arrayWithObjects:@"title", @"description", nil ]]];
        [addPhotoQueue addObject:item];
        [item release];
    }
    
    photoCount = [NSNumber numberWithInteger:[addPhotoQueue count]];
    uploadedPhotos = [NSNumber numberWithInteger:0];
    [totalProgresssIndicator setMaxValue:[photoCount doubleValue]];
    [NSApp beginSheet:progressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
    [self processAddPhotoQueue];
}

- (void)got:(NSMutableDictionary *)myResults;
{
    //    NSLog( @"%@",myResults );
    //    NSLog( @"Done!" );
    uploadedPhotos = [NSNumber numberWithInteger:1+[uploadedPhotos integerValue]];
    [self processAddPhotoQueue];
}

- (void) updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [currentProgresssIndicator setDoubleValue:((double)totalBytesWritten)/((double)totalBytesExpectedToWrite) ];
    [totalProgresssIndicator setDoubleValue:[uploadedPhotos doubleValue] + ((double)totalBytesWritten)/((double)totalBytesExpectedToWrite) ];
}

- (void) processAddPhotoQueue
{
    if( [[NSNumber numberWithInteger:[addPhotoQueue count]] isGreaterThan:[NSNumber numberWithInteger:0]] )
    {
        AddPhotoQueueItem *currentItem = [[[addPhotoQueue objectAtIndex:0] retain] autorelease];
        [addPhotoQueue removeObjectAtIndex:0];
        [progress setStringValue:[NSString stringWithFormat:@"Transfering Photo %d of %d\n\n%@", ([photoCount intValue]- [addPhotoQueue count]), [photoCount intValue], currentItem.path ]];
        [gallery addPhotoAtPath:currentItem.path toUrl:currentItem.url withParameters:currentItem.parameters];
    }
    else
    {
        [progressWindow orderOut:nil];
        [NSApp endSheet:progressWindow];     

        GalleryAlbum *selectedAlbum;
        selectedAlbum = (GalleryAlbum *)[browser itemAtIndexPath:[browser selectionIndexPath]];
        
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[selectedAlbum webUrl]]];
    }
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
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle bundleForClass: [self class]] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:preferences forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
}

@end
