//
//  TutorialAppDelegate.h
//  Tutorial
//
//  Created by Scott Selberg on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RestfulGallery.h"
#import "GalleryAlbum.h"
#import "GalleryInfo.h"
#import "GalleryDirectoryController.h"

@interface TutorialAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField *entityId;
    IBOutlet NSTextField *albumName;
    IBOutlet NSTextField *albumTitle;
    IBOutlet NSTextField *photoTitle;
    IBOutlet NSTextField *photoDescription;
    IBOutlet NSTextField *newGalleryPassword;

    IBOutlet NSBrowser                  *browser;
    IBOutlet NSTableView                *galleryDirectoryTableView;    
    IBOutlet GalleryDirectoryController *galleryDirectoryController;

@private
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSWindow *manageGalleriesWindow;
    IBOutlet NSWindow *galleryInformationWindow;
    IBOutlet NSWindow *addAlbumWindow;
    IBOutlet NSWindow *testsWindow;
    
    NSMutableDictionary *preferences;
    NSNumber            *selectedGalleryIndex;
    NSDictionary        *userDefaults;
    GalleryAlbum        *selectedGallery;
}

@property (retain) RestfulGallery   *gallery;
@property (retain) GalleryAlbum     *rootGalleryAlbum;
@property (retain) NSMutableArray   *galleryDirectory;
@property (retain) NSString         *galleryApiKey;
@property (retain) NSString         *filePath;


-(IBAction)addPhoto:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)quit:(id)sender;
-(IBAction)getApiKey:(id)sender;
-(IBAction)getAlbums:(id)sender;
-(IBAction)getItems:(id)sender;

-(IBAction)showManageGalleries:(id)sender;
-(IBAction)hideManageGalleries:(id)sender;

-(IBAction)addGalleryInformation:(id)sender;
-(IBAction)showGalleryInformation:(id)sender;
-(IBAction)hideGalleryInformation:(id)sender;

-(IBAction)showAddAlbum:(id)sender;
-(IBAction)hideAddAlbum:(id)sender;

-(IBAction)showTests:(id)sender;
-(IBAction)hideTests:(id)sender;

-(IBAction)test:(id)sender;
-(void) savePreferences;
@end
