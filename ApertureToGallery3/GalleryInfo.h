//
//  GalleryInfo.h

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


@interface GalleryInfo : NSObject {
    NSString *name;
    NSString *url;
    NSString *key;
    NSString *username;
}

- (id)initWithName:(NSString*)myName andUrl:(NSString*)myUrl andUsername:(NSString*)myUsername andKey:(NSString*)myKey;

@property(retain) NSString *name;
@property(retain) NSString *url;
@property(retain) NSString *key;
@property(retain) NSString *username;

@end
