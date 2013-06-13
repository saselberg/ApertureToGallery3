//
//  GalleryAlbum.m

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

#import "GalleryAlbum.h"


@implementation GalleryAlbum
@synthesize gallery;
@synthesize url;
@synthesize childrenAreStale;
@synthesize dataIsStale;

- (id)initWithGallery:(RestfulGallery *)myGallery andEntityId:(NSNumber *)myEntityId {
    if ((self = [super init])) {
        self.gallery     = myGallery;
        self.url         = [NSString stringWithFormat:@"%@/index.php/rest/item/%@", gallery.url, myEntityId];
        [self initCommon];
        [self loadData];
        
    }
    return self;
}

- (id)initWithGallery:(RestfulGallery *)myGallery andEntityData:(NSMutableDictionary *)myEntityData {
    if ((self = [super init])) {
        info  = [[NSMutableDictionary alloc] initWithCapacity:5];
        [info addEntriesFromDictionary:myEntityData];

        self.gallery     = myGallery;
        self.url         = [info objectForKey:@"url"];
        self.dataIsStale = false;
        [self initCommon];
    }
    return self;
}

- (void) initCommon
{
    formatter  = [[NSNumberFormatter alloc] init];
}

- (void)dealloc {
    self.gallery  = nil;
    self.url  = nil;
    
    [info     release];
    [children release];
    [formatter release];
    
    info = nil;
    children = nil;
    formatter = nil;
    
    [super dealloc];
}

- (void) loadData {
    if ( info == nil || self.dataIsStale) {       
        NSNumber *myEntityId;        
        myEntityId = [self entityId];
        if( [myEntityId integerValue] == 0 ){
            myEntityId = [NSNumber numberWithInteger:1];
        }
        [gallery getInfoForItem:myEntityId];
        [info autorelease];
        info = [gallery.results retain];

        if( [[self entityId] integerValue] == 0 ){
            [info setValue:[NSString stringWithFormat:@"%@/index.php/rest/item/0", gallery.url] forKey:@"url"];
        }

        self.dataIsStale = false;
    }
}

- (void) loadChildren {
    [self loadData];
    if( children == nil || self.childrenAreStale ){    
        NSMutableDictionary *newChildren = [NSMutableDictionary new];
        NSArray *childrenUrls = [info objectForKey:@"members" ];
        if( [[self entityId] integerValue] == 0)
        {
            childrenUrls = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/index.php/rest/item/1", gallery.url], nil];
        }       
        if( childrenUrls.count > 0 )
        {
            [gallery getInfoForItems:childrenUrls];
            for (NSMutableDictionary *child in [gallery.results objectForKey:@"RESULTS"]){
                if( [[[child objectForKey:@"entity"] objectForKey:@"type"] isEqualToString:@"album"] ){
                    if( children != nil ){
                        GalleryAlbum *oldChild = [children objectForKey:[child objectForKey:@"url"]];
                        if( oldChild != nil){
                            [newChildren setObject:oldChild forKey:[child objectForKey:@"url"]];
                            continue;
                        }
                    }
                    
                    GalleryAlbum *node = [[GalleryAlbum alloc] initWithGallery:self.gallery andEntityData:child];
                    [newChildren setObject:node forKey:[child objectForKey:@"url"]];
                    [node release];
                }
            }
        }
        
        [children release];
        children = newChildren;        
        self.childrenAreStale = false;
    }
}

- (void) load {
    [self loadData];
    [self loadChildren];
}

- (BOOL)hasChildren {
    [self loadChildren];
    return ([ self numberOfChildren ] > 0);
}

- (NSInteger)numberOfChildren {
    [self loadChildren];
    return [[children allKeys] count ];
}

- (NSMutableDictionary *) info {
    [self loadData];
    return info;
}

- (NSString *)displayName
{
    [self loadData];
    return [[info objectForKey:@"entity"] objectForKey:@"title"];
    //return [NSString stringWithFormat:@"%@", [[info objectForKey:@"entity"] objectForKey:@"title"]];
}

- (NSString *)description
{
    [self loadData];
    return [[info objectForKey:@"entity"] objectForKey:@"title"];
}

- (NSArray *)children {
    [self loadChildren];
         
     NSArray *result = [children allValues];
         // Sort the children by the display name and return it
         result = [result sortedArrayUsingComparator:^(id obj1, id obj2) {
         NSString *objName = [obj1 displayName];
         NSString *obj2Name = [obj2 displayName];
         NSComparisonResult result = [objName compare:obj2Name options:NSNumericSearch | NSCaseInsensitiveSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch range:NSMakeRange(0, [objName length]) locale:[NSLocale currentLocale]];
         return result;
         }];
         return result;
}

- (NSNumber *) entityId
{
    NSNumber *myId;
    myId = [formatter numberFromString:[self.url lastPathComponent]];
    return myId;
}

- (NSString *) webUrl
{
    return [[info objectForKey:@"entity"] objectForKey:@"web_url"];
}

- (void)invalidateChildren {
    childrenAreStale = true;
    dataIsStale      = true;
    for (GalleryAlbum *child in [children allValues]) {
        [child invalidateChildren];
    }
}

@end