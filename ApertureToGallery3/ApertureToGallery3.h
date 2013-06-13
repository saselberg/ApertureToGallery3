//
//  ApertureToGallery3.h
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

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ApertureExportManager.h"
#import "ApertureExportPlugIn.h"
#import "GalleryAlbum.h"
#import "GalleryInfo.h"
#import "RestfulGallery.h"
#import "AddPhotoQueueItem.h"
#import "Version.h"

@interface ApertureToGallery3 : NSObject <ApertureExportPlugIn, URLCallDelegate>
{
        // The cached API Manager object, as passed to the -initWithAPIManager: method.
        id _apiManager; 
        
        // The cached Aperture Export Manager object - you should fetch this from the API Manager during -initWithAPIManager:
        NSObject<ApertureExportManager, PROAPIObject> *_exportManager; 
        
        // The lock used to protect all access to the ApertureExportProgress structure
        NSLock *_progressLock;
        
        // Top-level objects in the nib are automatically retained - this array
        // tracks those, and releases them
        NSArray *_topLevelNibObjects;
        
        // The structure used to pass all progress information back to Aperture
        ApertureExportProgress exportProgress;
        
        // Outlets to your plug-ins user interface
        IBOutlet NSView *settingsView;
        IBOutlet NSView *firstView;
        IBOutlet NSView *lastView;
    
    IBOutlet NSTextField *albumName;
    IBOutlet NSTextField *albumTitle;
    IBOutlet NSTextField *newGalleryPassword;
    IBOutlet NSTextField *versionLabel;
    
    IBOutlet NSBrowser         *browser;
    IBOutlet NSTableView       *galleryDirectoryTableView;    
    IBOutlet NSArrayController *galleryDirectoryController;

    IBOutlet NSWindow *manageGalleriesWindow;
    IBOutlet NSWindow *galleryInformationWindow;
    IBOutlet NSWindow *addAlbumWindow;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSWindow *progressWindow;
    
    RestfulGallery *gallery;
    NSMutableArray *galleryDirectory;
    GalleryAlbum   *rootGalleryAlbum;
    NSString       *galleryApiKey;
    BOOL           cancel;
    
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

   	// For measuring progress - as Aperture writes data to disk, keep count of the bytes we need to upload.
//    NSNumber            *photoCount; 
//    NSNumber            *uploadedPhotos;
    BOOL                running;
}

@property (retain) RestfulGallery    *gallery;
@property (retain) GalleryAlbum      *rootGalleryAlbum;
@property (retain) AddPhotoQueueItem *currentItem;
@property (retain) NSMutableArray    *galleryDirectory;
@property (retain) NSString          *galleryApiKey;
//@property (retain) NSNumber          *photoCount;
//@property (retain) NSNumber          *uploadedPhotos;
@property          BOOL              cancel;
@property (retain) NSString          *waterMarkImageName;



-(IBAction)makeAlbum:(id)sender;
-(IBAction)getApiKey:(id)sender;
-(IBAction)clickDonate:(id)sender;
-(IBAction)clickGoGitHub:(id)sender;

-(IBAction)showManageGalleries:(id)sender;
-(IBAction)hideManageGalleries:(id)sender;

-(IBAction)showAbout:(id)sender;
-(IBAction)hideAbout:(id)sender;

-(IBAction)addGalleryInformation:(id)sender;
-(IBAction)showGalleryInformation:(id)sender;
-(IBAction)hideGalleryInformation:(id)sender;

-(IBAction)showAddAlbum:(id)sender;
-(IBAction)hideAddAlbum:(id)sender;

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
-(void)enableWatermark:(BOOL)bEnable;


-(void)savePreferences;
-(void)got:(NSMutableDictionary *)myResults;
-(void)updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
-(void)processAddPhotoQueue;
-(void)startExportInNewThread;
-(void)done;
-(void)watermarkImages;



@end

