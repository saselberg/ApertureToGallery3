//
//  iPhotoToGallery3ExportBox.m
//  ApertureToGallery3
//

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

#import "iPhotoToGallery3ExportBox.h"


@implementation iPhotoToGallery3ExportBox

- (BOOL)performKeyEquivalent:(NSEvent *)anEvent
{
    NSString *keyString = [anEvent charactersIgnoringModifiers];
    unichar keyChar = [keyString characterAtIndex:0];
    switch (keyChar)
    {
        case NSFormFeedCharacter:
        case NSNewlineCharacter:
        case NSCarriageReturnCharacter:
        case NSEnterCharacter:
        {
            [mPlugin clickExport];
            return(YES);
        }
        default:
            break;
    }
    return([super performKeyEquivalent:anEvent]);
}
@end
