//
//  iPhotoToGallery3ExportBox.h
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/19/11.

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

#import <Cocoa/Cocoa.h>
#import "ExportPluginProtocol.h"
#import "ExportPluginBoxProtocol.h"

@interface iPhotoToGallery3ExportBox : NSBox <ExportPluginBoxProtocol> {
    IBOutlet id <ExportPluginProtocol> mPlugin;
}

- (BOOL)performKeyEquivalent:(NSEvent *)anEvent;

@end
