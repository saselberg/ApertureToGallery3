//
//  TestHarnessAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "RestfulGallery.h"
#import "GalleryAlbum.h"
#import "GalleryInfo.h"
#import "Version.h"

@interface AppleToGallery3AppDelegate : NSObject <NSApplicationDelegate, URLCallDelegate> {
    
    IBOutlet NSTextField *albumName;
    IBOutlet NSTextField *albumTitle;
    IBOutlet NSTextField *newGalleryPassword;
    IBOutlet NSTextField *progress;
    IBOutlet NSTextField *versionLabel;

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
    
    IBOutlet NSPopUpButton *watermarkMenu;
    IBOutlet NSTextField   *waterMarkImageNameTextField;
    NSString               *waterMarkImageName;
    IBOutlet NSButton      *browseForWaterMarkButton;

    NSMutableDictionary *preferences;
    NSNumber            *selectedGalleryIndex;
    NSDictionary        *userDefaults;
    GalleryAlbum        *selectedGallery;
    
    NSString *tempDirectoryPath;
    NSMutableArray *exportedImagePaths;
    NSMutableArray *addPhotoQueue;  
    NSMutableArray *retryPhotoQueue;
    NSMutableArray *donePhotoQueue;
    NSMutableArray *errorPhotoQueue;
    NSNumber       *uploadRetries;
    AddPhotoQueueItem *currentItem;

    BOOL           running;
    BOOL           cancel;
    
    RestfulGallery  *gallery;
    GalleryAlbum    *rootGalleryAlbum;
    NSMutableArray  *galleryDirectory;
    NSString        *galleryApiKey;
}

@property (retain) RestfulGallery   *gallery;
@property (retain) GalleryAlbum     *rootGalleryAlbum;
@property (retain) NSMutableArray   *galleryDirectory;
@property (retain) NSString         *galleryApiKey;
@property (retain) AddPhotoQueueItem *currentItem;
@property (retain) NSString          *waterMarkImageName;

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
-(IBAction)selectImageDirectory:(id)sender;
-(IBAction)selectWatermarkImage:(id)sender;
-(IBAction)selectNoWatermark:(id)sender;
-(IBAction)selectScaledWatermark:(id)sender;
-(IBAction)selectTopLeftWatermark:(id)sender;
-(IBAction)selectTopCenterWatermark:(id)sender;
-(IBAction)selectTopRightWatermark:(id)sender;
-(IBAction)selectMiddleLeftWatermark:(id)sender;
-(IBAction)selectMiddleCenterWatermark:(id)sender;
-(IBAction)selectMiddleRightWatermark:(id)sender;
-(IBAction)selectBottomLeftWatermark:(id)sender;
-(IBAction)selectBottomCenterWatermark:(id)sender;
-(IBAction)selectBottomRightWatermark:(id)sender;

- (void)savePreferences;
- (void)exportPhotos:(NSString*)fileNode;
- (void)done;
- (void)startExportInNewThread;
- (void)watermarkImages;
- (void)enableWatermark:(BOOL)bEnable;




@end

