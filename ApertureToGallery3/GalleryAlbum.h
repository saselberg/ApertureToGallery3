//
//  GalleryAlbum.h
//  Tutorial
//
//  Created by Scott Selberg on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestfulGallery.h"

@interface GalleryAlbum : NSObject {
@private
    NSMutableDictionary *info;
    NSMutableDictionary *children;
    NSNumberFormatter   *formatter;
}

- (id)initWithGallery:(RestfulGallery *)myGallery andEntityId:(NSNumber *)myEntityId;
- (id)initWithGallery:(RestfulGallery *)myGallery andEntityData:(NSMutableDictionary *)myEntityData;
- (void) initCommon;

@property(retain) RestfulGallery      *gallery;
@property(retain) NSString            *url;
@property         BOOL                dataIsStale;
@property         BOOL                childrenAreStale;

- (BOOL)hasChildren;
- (NSArray *)children;
- (NSMutableDictionary *) info;

- (NSArray *)children;
- (NSString *)displayName;
- (NSString *)description;
- (NSInteger)numberOfChildren;
- (void)invalidateChildren;
    
- (void) loadData;
- (void) loadChildren;
- (void) load;
- (NSNumber *) entityId;

@end