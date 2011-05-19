//
//  TestHarnessAppDelegate.h
//  TestHarness
//
//  Created by Scott Selberg on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RestfulGallery.h"
#import "GalleryAlbum.h"
#import "GalleryInfo.h"

@interface TestHarnessAppDelegate : NSObject <NSApplicationDelegate, URLCallDelegate> {

    IBOutlet NSTextField         *albumName;
    IBOutlet NSTextField         *albumTitle;
    IBOutlet NSTextField         *newGalleryPassword;
    IBOutlet NSTextField         *progress;
    IBOutlet NSProgressIndicator *currentProgresssIndicator;
    IBOutlet NSProgressIndicator *totalProgresssIndicator;
    
    IBOutlet NSBrowser         *browser;
    IBOutlet NSTableView       *galleryDirectoryTableView;    
    IBOutlet NSArrayController *galleryDirectoryController;
    
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSWindow *manageGalleriesWindow;
    IBOutlet NSWindow *galleryInformationWindow;
    IBOutlet NSWindow *addAlbumWindow;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSWindow *progressWindow;
    
    
    NSNumber            *photoCount; 
    NSNumber            *uploadedPhotos;
    NSMutableDictionary *preferences;
    NSNumber            *selectedGalleryIndex;
    NSDictionary        *userDefaults;
    GalleryAlbum        *selectedGallery;

    NSString *tempDirectoryPath;
    NSMutableArray *exportedImagePaths;
    NSMutableArray *addPhotoQueue;  
}

@property (retain) RestfulGallery   *gallery;
@property (retain) GalleryAlbum     *rootGalleryAlbum;
@property (retain) NSMutableArray   *galleryDirectory;
@property (retain) NSString         *galleryApiKey;

- (void) processAddPhotoQueue;
- (void) got:(NSMutableDictionary *)results;
- (void) updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (IBAction) getApiKey:(id)sender;
- (IBAction)makeAlbum:(id)sender;
- (IBAction)clickDonate:(id)sender;
- (IBAction)clickGoGitHub:(id)sender;

-(IBAction)showManageGalleries:(id)sender;
-(IBAction)hideManageGalleries:(id)sender;

-(IBAction)showAbout:(id)sender;
-(IBAction)hideAbout:(id)sender;

-(IBAction)addGalleryInformation:(id)sender;
-(IBAction)showGalleryInformation:(id)sender;
-(IBAction)hideGalleryInformation:(id)sender;

-(IBAction)showAddAlbum:(id)sender;
-(IBAction)hideAddAlbum:(id)sender;

-(IBAction)quit:(id)sender;
-(IBAction)cancel:(id)sender;
- (void)savePreferences;
-(IBAction)selectImageDirectory:(id)sender;
- (void)exportPhotos:(NSString*)fileNode;

@end

