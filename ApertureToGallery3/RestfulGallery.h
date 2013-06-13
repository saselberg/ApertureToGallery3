//
//  RestfulGallery.h

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

#import <Foundation/Foundation.h>
#import "SBJSON.h"
#import "GalleryConnection.h"
#import "URLCallDelegate.h"
#import "AddPhotoQueueItem.h"
#import <Quartz/Quartz.h>

@interface RestfulGallery : NSObject <URLCallDelegate> {
    NSError*             _error;
    NSURLResponse*       _response;
    NSData*              _data;
    NSMutableArray*      _addPhotoQueue;
    NSString*            _userAgent;
    NSStringEncoding     _encoding;
    GalleryConnection*   _galleryConnection;
    NSInteger            _standardTimeout;
    NSInteger            _shortTimeout;
    NSString*            url;
    NSString*            galleryApiKey;
    BOOL                 bVerbose;
    NSMutableDictionary* results;
    id <URLCallDelegate> delegate;
    BOOL                 bGalleryValid;
}

@property(retain) NSString             *url;
@property(retain) NSString             *galleryApiKey;
@property         BOOL                 bVerbose;
@property(retain) NSMutableDictionary  *results;
@property(retain) id <URLCallDelegate> delegate;
@property         BOOL                 bGalleryValid;


- (void)cancel;
- (void)got:(NSMutableDictionary *)myResults;
- (void)updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (void)getApiKeyforUsername:(NSString *)username AndPassword:(NSString *)password;
- (void)getApiKeyforGallery:(NSString *)myGallery AndUsername:(NSString *)username AndPassword:(NSString *)password;
- (void)getInfoForItem:(NSNumber *)restItem;
- (void)getInfoForItems:(NSArray *)urls;
- (void)createAlbumInEntity:(NSNumber *)restItem withParameters:(NSMutableDictionary *)parameters;
- (void)addPhotoAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters;
- (void)addMovieAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters;
- (void)addItemIsPhoto:(BOOL)isPhoto AtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters;
- (BOOL)galleryValid;
- (void) waterMarkImage:(NSString *)myBaseImageName with:(NSString *)myWaterMarkImageName andTransformIndex:(NSInteger)indexOfSelectedItem;

@end
