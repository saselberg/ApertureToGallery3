//
//  RestfulGallery.h
//  Tutorial
//
//  Created by Scott Selberg on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "GalleryConnection.h"
#import "URLCallDelegate.h"
#import "AddPhotoQueueItem.h"

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
@end
