//
//  GalleryAlbum.h

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
#import "RestfulGallery.h"

@interface GalleryAlbum : NSObject {
    RestfulGallery *gallery;
    NSString       *url;
    BOOL           dataIsStale;
    BOOL           childrenAreStale;

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
- (NSString *) webUrl;

@end