//
//  GalleryInfo.m
//  Tutorial
//
//  Created by Scott Selberg on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GalleryInfo.h"


@implementation GalleryInfo
@synthesize url;
@synthesize name;
@synthesize key;
@synthesize username;

- (id)initWithName:(NSString*)myName andUrl:(NSString*)myUrl andUsername:(NSString*)myUsername andKey:(NSString*)myKey
{
    self = [super init];
    if (self) {
        self.url      = myUrl;
        self.name     = myName;
        self.key      = myKey;
        self.username = myUsername;
    }
    return self;
    
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super init];
    self.url      = [coder decodeObjectForKey:@"url"];
    self.name     = [coder decodeObjectForKey:@"name"];
    self.key      = [coder decodeObjectForKey:@"key"];
    self.username = [coder decodeObjectForKey:@"username"];
    return self;
}

- (void)dealloc
{
    self.url      = nil;
    self.name     = nil;
    self.key      = nil;
    self.username = nil;
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.url      forKey:@"url"];
    [coder encodeObject:self.name     forKey:@"name"];
    [coder encodeObject:self.key      forKey:@"key"];
    [coder encodeObject:self.username forKey:@"username"];
}

@end
