//
//  iPhotoToGallery3.h
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/19/11.

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
#import <QuickTime/QuickTime.h>
#import "ExportPluginProtocol.h"
#import "GalleryAlbum.h"
#import "GalleryInfo.h"
#import "Version.h"

@interface iPhotoToGallery3 : NSObject <ExportPluginProtocol, URLCallDelegate> {
    id <ExportImageProtocol> _exportManager;

    IBOutlet NSBox <ExportPluginBoxProtocol> *settingsBox;
    IBOutlet NSControl                       *firstView;
    ExportPluginProgress                     _progress;
    NSLock                                   *_progressLock;
    BOOL                                     cancel;

    IBOutlet NSWindow *manageGalleriesWindow;
    IBOutlet NSWindow *galleryInformationWindow;
    IBOutlet NSWindow *addAlbumWindow;
    IBOutlet NSWindow *aboutWindow;

    IBOutlet NSTextField *albumName;
    IBOutlet NSTextField *albumTitle;
    IBOutlet NSTextField *newGalleryPassword;
    IBOutlet NSTextField *versionLabel;
    
    IBOutlet NSBrowser         *browser;
    IBOutlet NSTableView       *galleryDirectoryTableView;    
    IBOutlet NSArrayController *galleryDirectoryController;

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
    
    RestfulGallery *gallery;
    GalleryAlbum   *rootGalleryAlbum;
    NSMutableArray *galleryDirectory;
    NSString       *galleryApiKey;
    BOOL           running;
    
    IBOutlet NSPopUpButton *kindPopupButton;
    IBOutlet NSMenuItem    *kindJpegLow;
    IBOutlet NSMenuItem    *kindJpegMedium;
    IBOutlet NSMenuItem    *kindJpegHigh;
    IBOutlet NSMenuItem    *kindJpegMaximum;
    
    IBOutlet NSPopUpButton *sizePopupButton;
    IBOutlet NSMenuItem    *size320;
    IBOutlet NSMenuItem    *size640;
    IBOutlet NSMenuItem    *size1280;
    IBOutlet NSMenuItem    *sizeQuarter;
    IBOutlet NSMenuItem    *sizeHalf;
    IBOutlet NSMenuItem    *sizeFullSize;
    IBOutlet NSMenuItem    *sizeCustom;
    IBOutlet NSTextField   *maxWidth;
    IBOutlet NSTextField   *maxHeight;
    
    IBOutlet NSPopUpButton *namePopupButton;
    IBOutlet NSMenuItem    *nameTitle;
    IBOutlet NSMenuItem    *nameFilename;
    IBOutlet NSMenuItem    *nameSequential;
    IBOutlet NSTextField   *sequentialPrefix;
    
    IBOutlet NSButton      *includeMetaData;
    IBOutlet NSButton      *showGalleryOnCompletion;
    
    IBOutlet NSPopUpButton *watermarkMenu;
    IBOutlet NSTextField   *waterMarkImageNameTextField;
    NSString               *waterMarkImageName;
    IBOutlet NSButton      *browseForWaterMarkButton;


}

@property (retain) RestfulGallery   *gallery;
@property (retain) GalleryAlbum     *rootGalleryAlbum;
@property (retain) NSMutableArray   *galleryDirectory;
@property (retain) NSString         *galleryApiKey;
@property (retain) AddPhotoQueueItem *currentItem;
@property (retain) NSString          *waterMarkImageName;


// overrides
- (void)awakeFromNib;
- (void)dealloc;

- (void) processAddPhotoQueue;
- (void) got:(NSMutableDictionary *)results;
- (void) updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)savePreferences;
-(void)done;
-(void)startExportInNewThread;

- (IBAction)getApiKey:(id)sender;
- (IBAction)makeAlbum:(id)sender;
- (IBAction)clickDonate:(id)sender;
- (IBAction)clickGoGitHub:(id)sender;


- (IBAction)clickDonate:(id)sender;
- (IBAction)clickGoGitHub:(id)sender;

// Window Methods
-(IBAction)showManageGalleries:(id)sender;
-(IBAction)hideManageGalleries:(id)sender;

-(IBAction)showAbout:(id)sender;
-(IBAction)hideAbout:(id)sender;

-(IBAction)addGalleryInformation:(id)sender;
-(IBAction)showGalleryInformation:(id)sender;
-(IBAction)hideGalleryInformation:(id)sender;

-(IBAction)showAddAlbum:(id)sender;
-(IBAction)hideAddAlbum:(id)sender;


-(IBAction)select320Size:(id)sender;
-(IBAction)select640Size:(id)sender;
-(IBAction)select1280Size:(id)sender;
-(IBAction)selectQuarterSize:(id)sender;
-(IBAction)selectHalfSize:(id)sender;
-(IBAction)selectFullSize:(id)sender;
-(IBAction)selectCustomSize:(id)sender;
-(void)enableCustomSizeSettings:(BOOL)bEnable;


-(IBAction)selectUseTitle:(id)sender;
-(IBAction)selectUseFileName:(id)sender;
-(IBAction)selectUseSequential:(id)sender;
-(void)enableSequentialPrefix:(BOOL)bEnable;

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

@end
