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
    NSMutableURLRequest *browser;
@private
    NSError        *error;
    NSURLResponse  *response;
    NSData         *data;
    NSMutableArray *addPhotoQueue;
}

@property(retain) NSString            *userAgent;
@property(retain) NSString            *url;
@property(retain) NSString            *galleryApiKey;
@property         BOOL                beVerbose;
@property         NSStringEncoding    encoding;
@property(retain) GalleryConnection   *galleryConnection;
@property(retain) NSMutableDictionary *results;


- (void)cancel;
- (void)got:(NSMutableDictionary *)myResults;
- (void)parseSynchronousRequest:(NSData *)myData;
- (void)getApiKeyforUsername:(NSString *)username AndPassword:(NSString *)password;
- (void)getApiKeyforGallery:(NSString *)myGallery AndUsername:(NSString *)username AndPassword:(NSString *)password;
- (void)getInfoForItem:(NSNumber *)restItem;
- (void)getInfoForItems:(NSArray *)urls;
- (void)createAlbumInEntity:(NSNumber *)restItem withParameters:(NSMutableDictionary *)parameters;
- (void)addPhotosAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl;
- (void)addPhotoAtPath:(NSString *)imagePath toEntity:(NSNumber *)restItem withParameters:(NSMutableDictionary *)parameters;
- (void)addPhotoAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters;
- (void) processAddPhotoQueue;

@end
