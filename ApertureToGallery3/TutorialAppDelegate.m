//
//  TutorialAppDelegate.m
//  Tutorial
//
//  Created by Scott Selberg on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TutorialAppDelegate.h"

@implementation TutorialAppDelegate
@synthesize gallery;
@synthesize galleryDirectory;
@synthesize rootGalleryAlbum;
@synthesize galleryApiKey;
@synthesize filePath;

- (id)init
{
    self = [super init];
    if( self )
    { 
        self.gallery  = [[RestfulGallery alloc] init];
        self.filePath = @"/Users/scott/Desktop/craiglist/fileCabinet/";
        
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
            self.galleryDirectory = [NSMutableArray arrayWithCapacity:5];            
            selectedGalleryIndex = [NSNumber numberWithInteger:0];
        }
    }
    return self;
}

- (void)awakeFromNib {
//    [browser setTarget:self];
//    [browser setCellClass:[GalleryAlbumBrowserCell class]];

    [galleryDirectoryController setSelectionIndex:[selectedGalleryIndex integerValue]];
    selectedGallery            = [[galleryDirectoryController selectedObjects] objectAtIndex:0];
    self.gallery.galleryApiKey = selectedGallery.key;
    self.gallery.url           = selectedGallery.url;
}

- (void)dealloc
{
    self.gallery                  = nil;
    self.rootGalleryAlbum         = nil;
    self.galleryApiKey            = nil;
    self.galleryDirectory         = nil;
    
    [preferences release];
    preferences = nil;
    
    [super dealloc];
}

/************************************************************
/ Gallery actions
************************************************************/

- (IBAction)getAlbums:(id)sender
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [gallery getInfoForItem:[formatter numberFromString:[entityId stringValue]]];
}

- (IBAction)getItems:(id)sender
{
    NSArray *items = [NSArray arrayWithObjects:@"https://selberg.homedns.org/gallery3/index.php/rest/item/1",
                       @"https://selberg.homedns.org/gallery3/index.php/rest/item/2",
                       @"https://selberg.homedns.org/gallery3/index.php/rest/item/3",
                       nil];
    [gallery getInfoForItems:items];
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
        NSLog( @"%d:%@ => %@", i, newColumn, album.url );
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

-(IBAction)test:(id)sender
{    
    //    GalleryAlbum *node = [[GalleryAlbum alloc] initWithGallery:gallery andEntityId:[NSNumber numberWithInteger:1]];
    //    [node release];
    NSLog( @"%@", preferences);
    NSLog( @"%@", selectedGalleryIndex );
}

- (IBAction)cancel:(id)sender
{
    [gallery cancel];
    
}
- (IBAction)quit:(id)sender
{
    exit(0);
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

-(IBAction)showTests:(id)sender
{
    [NSApp beginSheet:testsWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];    
}
-(IBAction)hideTests:(id)sender
{
    [testsWindow orderOut:nil];
    [NSApp endSheet:testsWindow];     
}


/************************************************************
/  Methods to enable the browser
************************************************************/


- (id)rootItemForBrowser:(NSBrowser *)browser
{
#pragma unused (browser)
//    NSLog( @"rootItemForBrowser" );
    if (rootGalleryAlbum == nil) {
        rootGalleryAlbum = [[GalleryAlbum alloc] initWithGallery:gallery andEntityId:[NSNumber numberWithInteger:0]];
    }
    return rootGalleryAlbum;    
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item 
{
#pragma unused (browser)
//    NSLog( @"browser:numberOfChidrenOfItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return [album numberOfChildren];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
#pragma unused (browser)
//    NSLog( @"browser:child:index:ofItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return [album.children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
#pragma unused (browser)
//    NSLog( @"browser:isLeafItem" );
    GalleryAlbum *album = (GalleryAlbum *)item;
    return !album.hasChildren;
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
#pragma unused (browser)
//    NSLog( @"objectValueForItem" );
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
