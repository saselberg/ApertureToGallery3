//
//  Version.h

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


@interface Version : NSObject {
    NSNumber* RestfulGalleryVersion;
    NSNumber* ApertureToGalleryVersion;
    NSNumber* iPhotoToGalleryVersion;
    NSNumber* AppleToGalleryVersion;
}

@property (retain) NSNumber* RestfulGalleryVersion;
@property (retain) NSNumber* ApertureToGalleryVersion;
@property (retain) NSNumber* iPhotoToGalleryVersion;
@property (retain) NSNumber* AppleToGalleryVersion;

@end
