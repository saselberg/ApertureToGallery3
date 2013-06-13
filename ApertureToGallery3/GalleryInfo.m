//
//  GalleryInfo.m

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
