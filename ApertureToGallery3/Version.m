//
//  Version.m

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

#import "Version.h"

@implementation Version
@synthesize iPhotoToGalleryVersion;
@synthesize RestfulGalleryVersion;
@synthesize AppleToGalleryVersion;
@synthesize ApertureToGalleryVersion;

- (id)init
{
    self = [super init];
    if (self) {
        self.iPhotoToGalleryVersion   = [NSNumber numberWithDouble:1.1];
        self.RestfulGalleryVersion    = [NSNumber numberWithDouble:1.0];
        self.AppleToGalleryVersion    = [NSNumber numberWithDouble:1.1];
        self.ApertureToGalleryVersion = [NSNumber numberWithDouble:1.1];
    }
    
    return self;
}

- (void)dealloc
{
    self.iPhotoToGalleryVersion   = nil;
    self.RestfulGalleryVersion    = nil;
    self.AppleToGalleryVersion    = nil;
    self.ApertureToGalleryVersion = nil;
    [super dealloc];
}

@end
